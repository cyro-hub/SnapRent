"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const role_1 = require("../models/role");
class Jwt {
    constructor() {
        this.accessSecret = process.env.ACCESS_TOKEN_SECRET || "youraccesstokensecret";
        this.refreshSecret = process.env.REFRESH_TOKEN_SECRET || "yourrefreshtokensecret";
        this.rolesTokenExpiry = {
            [role_1.acceptedRoleNames.Owner]: {
                accessExpire: "15m",
                refreshExpire: "1d",
            },
            [role_1.acceptedRoleNames.CareTaker]: {
                accessExpire: "1h",
                refreshExpire: "1d",
            },
            [role_1.acceptedRoleNames.Tenant]: {
                accessExpire: "2h",
                refreshExpire: "3d",
            },
            [role_1.acceptedRoleNames.Guest]: {
                accessExpire: "1d",
                refreshExpire: "7d",
            },
        };
    }
    generateAccessToken(_id, selectedRole) {
        if (selectedRole === role_1.acceptedRoleNames.Owner)
            return jsonwebtoken_1.default.sign({ _id, selectedRole }, this.accessSecret, {
                expiresIn: this.rolesTokenExpiry.Owner.accessExpire,
            });
        if (selectedRole === role_1.acceptedRoleNames.CareTaker)
            return jsonwebtoken_1.default.sign({ _id, selectedRole }, this.accessSecret, {
                expiresIn: this.rolesTokenExpiry["Care-taker"].accessExpire,
            });
        if (selectedRole === role_1.acceptedRoleNames.Tenant)
            return jsonwebtoken_1.default.sign({ _id, selectedRole }, this.accessSecret, {
                expiresIn: this.rolesTokenExpiry.Tenant.accessExpire,
            });
        return jsonwebtoken_1.default.sign({ _id, selectedRole }, this.accessSecret, {
            expiresIn: this.rolesTokenExpiry.Owner.accessExpire,
        });
    }
    generateRefreshToken(_id, selectedRole) {
        if (selectedRole === role_1.acceptedRoleNames.Owner)
            return jsonwebtoken_1.default.sign({ _id, selectedRole }, this.refreshSecret, {
                expiresIn: this.rolesTokenExpiry.Owner.refreshExpire,
            });
        if (selectedRole === role_1.acceptedRoleNames.CareTaker)
            return jsonwebtoken_1.default.sign({ _id, selectedRole }, this.refreshSecret, {
                expiresIn: this.rolesTokenExpiry["Care-taker"].refreshExpire,
            });
        if (selectedRole === role_1.acceptedRoleNames.Tenant)
            return jsonwebtoken_1.default.sign({ _id, selectedRole }, this.refreshSecret, {
                expiresIn: this.rolesTokenExpiry.Tenant.refreshExpire,
            });
        return jsonwebtoken_1.default.sign({ _id, selectedRole }, this.refreshSecret, {
            expiresIn: this.rolesTokenExpiry.Owner.refreshExpire,
        });
    }
    verifyRefreshToken(token) {
        try {
            return jsonwebtoken_1.default.verify(token, this.refreshSecret);
        }
        catch (error) {
            return null;
        }
    }
    verifyAccessToken(token) {
        try {
            return jsonwebtoken_1.default.verify(token, this.accessSecret);
        }
        catch (error) {
            return null;
        }
    }
}
exports.default = Jwt;
