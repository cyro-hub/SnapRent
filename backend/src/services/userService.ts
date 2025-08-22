import { injectable } from "tsyringe";
import { Services } from "./services";
import { User, UserDocument } from "../models/user";

@injectable()
export class UserServices extends Services<UserDocument> {
  constructor() {
    super(User);
  }

  public getAccessiblePropertyIds(user: UserDocument) {
    const now = new Date();

    const ids = user.tokenPackages
      .filter((pkg) => !pkg.isExpired && pkg.expiresAt > now)
      .flatMap((pkg) =>
        pkg.accessedProperties.map((ap) => ap.propertyId.toString())
      );

    return [...new Set(ids)];
  }
}
