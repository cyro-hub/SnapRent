import { inject, injectable } from "tsyringe";
import AsyncHandler from "../services/utils/asyncHandlerService";
import { NextFunction, Request, Response } from "express-serve-static-core";
import { UserServices } from "../services/userService";
import Jwt from "../services/utils/jsonwebservices";

@injectable()
export default class PropertyController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private userService: UserServices,
    private jsonwebtokenservices: Jwt
  ) {}
}
