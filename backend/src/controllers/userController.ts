import { inject, injectable } from "tsyringe";
import AsyncHandler from "../services/asyncHandlerService";
import { NextFunction, Request, Response } from "express-serve-static-core";
import { UserServices } from "../services/userService";
import Jwt from "../services/jsonwebservices";

@injectable()
export default class PropertyController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private userService: UserServices,
    private jsonwebtokenservices: Jwt
  ) {}

  authenticate = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const authHeader = req.headers.authorization;
      const token = authHeader?.split(" ")[1];

      if (!token) return res.sendStatus(401);

      const isValidToken = this.jsonwebtokenservices.verifyAccessToken(token);

      if(!isValidToken){
        
      }

      return res.json();
    }
  );
}
