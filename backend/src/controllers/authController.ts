import passport from "passport";
import { injectable } from "tsyringe";
import { Request, Response, NextFunction } from "express";
import AsyncHandler from "../services/utils/asyncHandlerService";
import { User } from "../models/user";
import Jwt from "../services/utils/jsonwebservices";
import "../config/passport";
import ApiResponse from "../services/utils/apiResponseService";
import { Types } from "mongoose";
import { Token } from "../models/token";

@injectable()
export default class AuthController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private jwt: Jwt,
    private apiResponse: ApiResponse
  ) {}

  register = this.asyncHandler.handler(async (req: Request, res: Response) => {
    const { email, password, fullName } = req.body;

    if (!email || !password) {
      return this.apiResponse
        .error("Email and password are required")
        .send(res, 400);
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return this.apiResponse.error("User already exists").send(res, 409);
    }

    const bcrypt = await import("bcryptjs");
    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await User.create({
      email,
      password: hashedPassword,
      isVerified: true,
      provider: "local",
      fullName,
    });

    const accessToken = this.jwt.generateAccessToken({
      _id: newUser.id,
      email: newUser.email,
    });

    const refreshToken = this.jwt.generateRefreshToken({ _id: newUser.id });

    return this.apiResponse
      .auth(
        "User registered successfully",
        { accessToken, refreshToken, tokenType: "Bearer", expiresIn: "15m" },
        {
          _id: newUser._id,
          email: newUser.email,
          fullName: newUser.fullName,
        }
      )
      .send(res, 201);
  });

  login = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      passport.authenticate(
        "local",
        { session: false },
        (err: any, user: any, info: any) => {
          if (err) return next(err);

          if (!user) {
            return this.apiResponse
              .error(info?.message || "Unauthorized")
              .send(res, 401);
          }

          const accessToken = this.jwt.generateAccessToken({
            _id: user.id,
            email: user.email,
          });

          const refreshToken = this.jwt.generateRefreshToken({ _id: user.id });

          return this.apiResponse
            .auth(
              "Login successful",
              {
                accessToken,
                refreshToken,
                tokenType: "Bearer",
                expiresIn: "15m",
              },
              {
                _id: user._id,
                email: user.email,
                fullName: user.fullName,
              }
            )
            .send(res, 200);
        }
      )(req, res, next);
    }
  );

  authenticate = this.asyncHandler.handler(
    (req: Request, res: Response, next: NextFunction) => {
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(" ")[1];

      if (!token) {
        return this.apiResponse.error("No token provided").send(res, 401);
      }

      const result = this.jwt.verifyAccessToken(token);
      console.log(result);

      if (!result.valid) {
        const statusCode = result.expired ? 401 : 403; // 401 = Unauthorized (expired)
        return this.apiResponse
          .error(result.expired ? "Token expired" : "Invalid token")
          .send(res, statusCode);
      }

      // Attach user info to request
      req.user = result.payload;

      next();
    }
  );

  refreshToken = this.asyncHandler.handler(
    async (req: Request, res: Response) => {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        return this.apiResponse.error("Refresh token required").send(res, 401);
      }

      const result = this.jwt.verifyRefreshToken(refreshToken);

      if (!result.valid || !result.payload) {
        return this.apiResponse
          .error(
            result.expired ? "Refresh token expired" : "Invalid refresh token"
          )
          .send(res, 403);
      }

      // Notice: payload has { id, jti }
      const user = await User.findById(result.payload._id);
      if (!user) {
        return this.apiResponse.error("User not found").send(res, 404);
      }

      const newAccessToken = this.jwt.generateAccessToken({
        _id: user.id,
        email: user.email,
      });

      const newRefreshToken = this.jwt.generateRefreshToken({ _id: user.id });

      return this.apiResponse
        .success("Token refreshed successfully", {
          tokens: {
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            tokenType: "Bearer",
            expiresIn: "15m",
          },
          user: {
            _id: user._id,
            email: user.email,
            fullName: user.fullName,
          },
        })
        .send(res, 200);
    }
  );

  getUserId = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(" ")[1];

      if (!token) return next();

      const result = this.jwt.verifyAccessToken(token);

      if (result.valid) {
        req.user = result.payload;
      }

      next();
    }
  );

  checkPropertyAccess = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      if (!req.user) {
        return this.apiResponse.error("User not authenticated").send(res, 401);
      }

      const userId = (req.user as any)?._id;
      const propertyId = req.query._id as string;
      const now = new Date();

      const user = await User.findById(userId);
      if (!user) return this.apiResponse.error("User not found").send(res, 404);

      // 1. Check if property is uploaded by user
      if (user.uploadedProperties.some((p) => p.toString() === propertyId)) {
        return next();
      }

      // 2. Check accessedProperties in non-expired tokens
      const tokens = await Token.find({
        userId,
        isExpired: false,
        expiresAt: { $gt: now },
      });

      const tokenWithProperty = tokens.find((token) =>
        token.accessedProperties.some((ap) => ap.propertyId === propertyId)
      );

      if (tokenWithProperty) {
        return next();
      }

      // 3. Find a token package with available usage
      const availableToken = tokens.find(
        (token) => token.quantity - token.used > 0
      );

      if (!availableToken) {
        return this.apiResponse
          .error("No available token to access this property")
          .send(res, 403);
      }

      // 4. Consume the token
      availableToken.used += 1;
      availableToken.accessedProperties.push({
        _id: new Types.ObjectId().toString(),
        propertyId,
        accessedAt: now,
      });

      await availableToken.save();

      next(); // Access granted
    }
  );
}
