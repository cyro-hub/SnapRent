import { Router } from "express";
import { injectable } from "tsyringe";
import PropertyController from "../controllers/propertyController";

@injectable()
export default class PropertyRouter {
  public propertyRouter: Router;
  constructor(private propertyController: PropertyController) {
    this.propertyRouter = Router();
    this.initRoutes();
  }

  private initRoutes(): void {
    this.propertyRouter.route("/").post(this.propertyController.createProperty);
    this.propertyRouter.route("/").put(this.propertyController.updateProperty);
    this.propertyRouter.route("/").get(this.propertyController.getProperty);
    this.propertyRouter
      .route("/owner")
      .get(this.propertyController.getOwnersProperties);
    this.propertyRouter
      .route("/get-access")
      .get(this.propertyController.getPropertyAccess);
    this.propertyRouter
      .route("/search")
      .get(this.propertyController.searchPropertiesWithFilters);
  }
}
