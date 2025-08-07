import { injectable } from "tsyringe";
import { NextFunction, Request, Response } from "express-serve-static-core";
import { MongoServerError } from "mongodb";
import ApiResponse from "./apiResponseService";
import CustomError from "./errorService";

@injectable()
export default class AsyncHandler {
  constructor(private response: ApiResponse<null>) {}

  private handleDuplicate(error: MongoServerError) {
    const errorMessage = error.errmsg;
    const collectionRegex = /collection: (\S+)/;
    const match = errorMessage.match(collectionRegex);

    if (match && match[1]) {
      if (match[1].split(".")[1] === "users") {
        this.response.setFailedResponse("Invalid user credentials.", []);
      } else {
        const key = Object.keys(error.keyValue)[0];
        const value = error.keyValue[key];
        this.response.setFailedResponse(
          `${value} already exists in ${match[1].split(".")[1]}`,
          []
        );
      }
    } else {
      this.response.setFailedResponse(
        "Collection name not found in error message.",
        []
      );
    }

    return this.response.toJSON();
  }

  private handleOtherCustomError(error: CustomError) {
    const { validationError } = error.details;
    this.response.setFailedResponse(error.message, validationError);

    return this.response.toJSON();
  }

  private handleOtherError(error: Error) {
    this.response.setFailedResponse(error.message, []);
    return this.response.toJSON();
  }

  handler(
    fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
  ) {
    return async (req: Request, res: Response, next: NextFunction) => {
      try {
        await fn(req, res, next);
      } catch (error) {
        if ((error as Error).name === "CastError") {
          this.response.setFailedResponse("Invalid request type.", []);
          return res.status(400).json(this.response.toJSON());
        }

        if (error instanceof MongoServerError && error.code === 11000) {
          return res.status(409).json(this.handleDuplicate(error));
        }

        if (error instanceof CustomError) {
          const { statusCode, validationError } = error.details;
          return res
            .status(statusCode)
            .json(this.handleOtherCustomError(error));
        }

        if (error instanceof Error) {
          return res.status(500).json(this.handleOtherError(error));
        }

        return res.status(500).json({ message: "Internal server error." });
      }
    };
  }
}
