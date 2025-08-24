import { Router } from "express";
import { injectable } from "tsyringe";
import PropertyController from "../controllers/propertyController";
import AuthController from "../controllers/authController";

@injectable()
export default class PropertyRouter {
  public propertyRouter: Router;
  constructor(
    private propertyController: PropertyController,
    private authController: AuthController
  ) {
    this.propertyRouter = Router();
    this.initRoutes();
  }

  private initRoutes(): void {
    this.propertyRouter
      .route("/")
      .post(
        this.authController.authenticate,
        this.propertyController.createProperty
      );

    this.propertyRouter
      .route("/")
      .put(
        this.authController.authenticate,
        this.propertyController.updateProperty
      );

    this.propertyRouter
      .route("/")
      .get(this.authController.getUserId, this.propertyController.getProperty);

    this.propertyRouter
      .route("/owner")
      .get(
        this.authController.authenticate,
        this.propertyController.getOwnersProperties
      );

    this.propertyRouter
      .route("/get-access")
      .get(
        this.authController.authenticate,
        this.authController.checkPropertyAccess,
        this.propertyController.givePropertyAccess
      );

    this.propertyRouter
      .route("/search")
      .get(
        this.authController.getUserId,
        this.propertyController.searchPropertiesWithFilters
      );

    this.propertyRouter
      .route("/explore")
      .get(
        this.authController.getUserId,
        this.propertyController.searchPropertiesWithGeospatial
      );

    this.propertyRouter
      .route("/token")
      .get(
        this.authController.authenticate,
        this.propertyController.getUserTokenProperties
      );
  }
}
