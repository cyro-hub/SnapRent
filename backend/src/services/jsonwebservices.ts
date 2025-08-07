import jwt from "jsonwebtoken";
import { injectable } from "tsyringe";

@injectable()
export default class Jwt {
  private accessSecret: string =
    process.env.JWT_ACCESS_SECRET || "youraccesstokensecret";

  private refreshSecret: string =
    process.env.JWT_REFRESH_SECRET || "yourrefreshtokensecret";

  private accessTokenExpiresAt: string =
    process.env.ACCESS_TOKEN_EXPIRES_IN || "1h";

  private refreshTokenExpiresAt: string =
    process.env.REFRESH_TOKEN_EXPIRES_IN || "7d";

  constructor() {}

  public generateAccessToken(payload: { id: string; email: string }) {
    return jwt.sign(payload, this.accessSecret!, {
      expiresIn: this.accessTokenExpiresAt,
    });
  }

  public generateRefreshToken(payload: { id: string }) {
    return jwt.sign(payload, this.refreshSecret!, {
      expiresIn: this.refreshTokenExpiresAt,
    });
  }

  public verifyRefreshToken(token: string) {
    try {
      return jwt.verify(token, this.refreshSecret);
    } catch (error) {
      return null;
    }
  }

  public verifyAccessToken(token: string) {
    try {
      return jwt.verify(token, this.accessSecret);
    } catch (error) {
      return null;
    }
  }
}
