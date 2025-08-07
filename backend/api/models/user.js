"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importStar(require("mongoose"));
const role_1 = require("./role");
const UserSchema = new mongoose_1.Schema({
    name: { type: String },
    email: { type: String, required: true, unique: true },
    phone: { type: String },
    password: { type: String, required: true },
    googleId: { type: String },
    facebookId: { type: String },
    userAgent: { type: String },
    refreshToken: { type: String },
    address: {
        street: { type: String },
        city: { type: String },
        state: { type: String },
        zipCode: { type: String },
        block: { type: String },
    },
    profilePicture: { type: String },
    emergencyContact: {
        name: { type: String },
        relation: { type: String },
        phone: { type: String },
    },
    selectedRole: {
        type: String,
        enum: ["Owner", "Care-taker", "Tenant", "Guest"],
        default: role_1.acceptedRoleNames.Guest,
    },
    roles: [{ type: mongoose_1.Schema.Types.Mixed }],
    createdDate: { type: Date, default: Date.now },
    lastUpdated: { type: Date, default: Date.now },
});
UserSchema.pre("save", function (next) {
    if (!this.roles || this.roles.length === 0) {
        this.roles = [{ roleName: role_1.acceptedRoleNames.Guest }];
    }
    this.lastUpdated = new Date();
    next();
});
exports.default = mongoose_1.default.model("User", UserSchema);
