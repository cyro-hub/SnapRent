import { injectable } from "tsyringe";
import { Router } from "express";
import PropertyRouter from "./propertyRouter";
import AuthRouter from "./authRouter";

@injectable()
export default class AppRouter {
  public appRouter: Router;

  constructor(
    private propertyRouter: PropertyRouter,
    private authRouter: AuthRouter
  ) {
    this.appRouter = Router();
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.appRouter.use("/properties", this.propertyRouter.propertyRouter);
    this.appRouter.use("/auth", this.authRouter.authRouter);
  }
}
