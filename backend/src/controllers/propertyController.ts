import { inject, injectable } from "tsyringe";
import AsyncHandler from "../services/asyncHandlerService";
import { NextFunction, Request, Response } from "express-serve-static-core";
import { PropertyServices } from "../services/propertyService";

@injectable()
export default class PropertyController {
  constructor(
    private readonly asyncHandler: AsyncHandler,
    private propertyService: PropertyServices
  ) {}

  createProperty = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const property = await this.propertyService.createProperty(req.body);
      return res.json(property);
    }
  );

  updateProperty = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const property = await this.propertyService.updateProperty(
        req.query._id as string,
        req.body
      );

      return res.json(property);
    }
  );

  getProperty = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const property = await this.propertyService.getProperty(
        req.query._id as string,
        "6892751ad61a1f3fc5ff01e6"
      );
      return res.json(property);
    }
  );

  getOwnersProperties = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const limit = Number(req.query.limit);

      const query = {
        userId: req.query.ownerId as string,
        page: Number(req.query.page) || 1,
        limit: limit || 10,
      };

      const properties = await this.propertyService.getOwnersProperties(query);

      return res.json(properties);
    }
  );

  getPropertyAccess = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const property = await this.propertyService.getPropertyAccess(
        req.query._id as string
      );
      return res.json(property);
    }
  );

  searchPropertiesWithFilters = this.asyncHandler.handler(
    async (req: Request, res: Response, next: NextFunction) => {
      const limit = Number(req.query.limit);

      const query = {
        ...req.query,
        limit: limit || 10,
        userId: "68907552c62c4e5d0f9bff56",
      };

      const results = await this.propertyService.searchPropertiesWithFilters(
        query
      );

      res.json(results);
    }
  );
}
