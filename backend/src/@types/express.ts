import { IUser } from "../models/user";
import { Request } from "express";

export default interface RequestCustom extends Request {
  user?: Partial<IUser> & { _id: string };
}
