import passport from "passport";
import { injectable } from "tsyringe";
import { Request, Response, NextFunction } from "express";
import AsyncHandler from "../services/asyncHandlerService";
import { User } from "../models/user";
import Jwt from "../services/jsonwebservices";
import "../config/passport";

@injectable()
export default class AuthController {
  constructor(private readonly asyncHandler: AsyncHandler, private jwt: Jwt) {}

  register = this.asyncHandler.handler(async (req: Request, res: Response) => {
    const { email, password, fullName } = req.body;

    if (!email || !password) {
      return res
        .status(400)
        .json({ message: "Email and password are required" });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ message: "User already exists" });
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
      id: newUser.id,
      email: newUser.email,
    });

    const refreshToken = this.jwt.generateRefreshToken({ id: newUser.id });

    res.status(201).json({
      message: "User registered successfully",
      accessToken,
      refreshToken,
      tokenType: "Bearer",
      expiresIn: "1h",
      user: {
        id: newUser.id,
        email: newUser.email,
        fullName: newUser.fullName,
      },
    });
  });

  login = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      passport.authenticate(
        "local",
        { session: false },
        (err: any, user: any, info: any) => {
          if (err) return next(err);
          if (!user)
            return res
              .status(401)
              .json({ message: info?.message || "Unauthorized" });

          const accessToken = this.jwt.generateAccessToken({
            id: user.id,
            email: user.email,
          });

          const refreshToken = this.jwt.generateRefreshToken({
            id: user.id,
          });

          res.status(200).json({
            message: "Login successful",
            accessToken,
            refreshToken,
            tokenType: "Bearer",
            expiresIn: "15m",
            user: {
              email: user.email,
              id: user.id,
            },
          });
        }
      )(req, res, next);
    }
  );

  refreshToken = this.asyncHandler.handler(
    async (req: Request, res: Response) => {
      const { refreshToken } = req.body;

      if (!refreshToken)
        return res.status(401).json({ message: "Refresh token required" });

      try {
        const decoded = this.jwt.verifyRefreshToken(refreshToken);

        if (
          decoded === null ||
          typeof decoded === "string" ||
          !decoded.id ||
          !decoded.email
        ) {
          return res.status(403).json({ message: "Invalid token payload" });
        }

        const accessToken = this.jwt.generateAccessToken({
          id: decoded.id,
          email: decoded.email,
        });

        const newRefreshToken = this.jwt.generateRefreshToken({
          id: decoded.id,
        });

        return res.status(200).json({
          accessToken,
          refreshToken: newRefreshToken,
          tokenType: "Bearer",
          expiresIn: "15m",
        });
      } catch (err) {
        return res
          .status(403)
          .json({ message: "Invalid or expired refresh token" });
      }
    }
  );
}
