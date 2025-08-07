import mongoose, { Document, Schema, model, Types } from "mongoose";
import bcrypt from "bcryptjs";

export interface AccessedProperty {
  _id: string;
  propertyId: string;
  accessedAt: Date;
}

export interface TokenPackage {
  _id: string;
  quantity: number;
  used: number;
  accessedProperties: AccessedProperty[];
  purchasedAt: Date;
  expiresAt: Date;
  isExpired: boolean;
}

export interface UserDocument extends Document {
  _id: string;
  email: string;
  password: string;
  fullName: string;
  tokenPackages: TokenPackage[];
  uploadedProperties: Types.ObjectId[];
  isActive: boolean;
  provider: "google" | "local";
  refreshToken?: string;
  isVerified: boolean;
  comparePassword(password: string): Promise<boolean>;
  createdAt: Date;
  updatedAt: Date;
}

const AccessedPropertySchema = new Schema({
  propertyId: {
    type: Schema.Types.ObjectId,
    ref: "Property",
    required: true,
  },
  accessedAt: { type: Date, required: true },
});

const TokenPackageSchema = new Schema({
  quantity: { type: Number, required: true },
  used: { type: Number, required: true, default: 0 },
  accessedProperties: [AccessedPropertySchema],
  purchasedAt: { type: Date, required: true },
  expiresAt: { type: Date, required: true },
  isExpired: { type: Boolean, required: true, default: false },
});

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
    tokenPackages: [TokenPackageSchema],
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
