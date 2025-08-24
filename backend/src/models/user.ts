import mongoose, { Document, Schema, model, Types } from "mongoose";
import bcrypt from "bcryptjs";

export interface UserDocument extends Document {
  _id: string;
  email: string;
  password: string;
  fullName: string;
  uploadedProperties: Types.ObjectId[];
  isActive: boolean;
  provider: "google" | "local";
  refreshToken?: string;
  isVerified: boolean;
  comparePassword(password: string): Promise<boolean>;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<UserDocument>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
    },
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
    refreshToken: {
      type: String,
    },
    uploadedProperties: [
      {
        type: Schema.Types.ObjectId,
        ref: "Property", // assuming you have a Property model
      },
    ],
    isActive: {
      type: Boolean,
      default: true,
    },
    isVerified: {
      type: Boolean,
      default: true,
    },
    provider: { type: String, enum: ["google", "local"], required: true },
  },
  {
    timestamps: true,
  }
);

userSchema.methods.comparePassword = function (
  password: string
): Promise<boolean> {
  return bcrypt.compare(password, this.password);
};

export const User = model<UserDocument>("User", userSchema);
