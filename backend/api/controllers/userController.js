"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const tsyringe_1 = require("tsyringe");
const userServices_1 = require("../services/userServices");
const asyncHandler_1 = __importDefault(require("../utils/asyncHandler"));
const customError_1 = __importDefault(require("../utils/customError"));
let UserController = class UserController {
    constructor(userServices, asyncHandler) {
        this.userServices = userServices;
        this.asyncHandler = asyncHandler;
        this.createUser = this.asyncHandler.handler((req, res, next) => __awaiter(this, void 0, void 0, function* () {
            const userAgent = req.headers["user-agent"];
            const { response, accessToken, refreshToken } = yield this.userServices.createUser(Object.assign(Object.assign({}, req.body), { userAgent }));
            if (!refreshToken || !accessToken) {
                throw new customError_1.default("Unable to create user.", {
                    statusCode: 400,
                });
            }
            res.cookie("refreshToken", refreshToken, {
                httpOnly: true,
                secure: true,
            });
            // Call res.status(...), but do not return it
            res.status(201).json({ accessToken, response });
        }));
        this.loginUser = this.asyncHandler.handler((req, res, next) => __awaiter(this, void 0, void 0, function* () {
            const userAgent = req.headers["user-agent"];
            const { response, accessToken, refreshToken } = yield this.userServices.loginUser(Object.assign(Object.assign({}, req.body), { userAgent }));
            if (!refreshToken || !accessToken) {
                throw new customError_1.default("Unable to create user.", {
                    statusCode: 400,
                });
            }
            res.cookie("refreshToken", refreshToken, {
                httpOnly: true,
                secure: true,
            });
            // Call res.status(...), but do not return it
            res.status(201).json({ accessToken, response });
        }));
        this.selectUserRole = this.asyncHandler.handler((req, res, next) => __awaiter(this, void 0, void 0, function* () {
            const token = req.headers["authorization"];
            const { role } = req.body;
            if (!token || typeof token !== "string") {
                throw new customError_1.default("No token.", { statusCode: 400 });
            }
            const { response, accessToken, refreshToken } = yield this.userServices.selectRole(role, token);
            if (!refreshToken || !accessToken) {
                throw new customError_1.default("Unable to select user role.", {
                    statusCode: 400,
                });
            }
            res.cookie("refreshToken", refreshToken, {
                httpOnly: true,
                secure: true,
            });
            // Call res.status(...), but do not return it
            res.status(201).json({ accessToken, response });
        }));
    }
};
UserController = __decorate([
    (0, tsyringe_1.injectable)(),
    __metadata("design:paramtypes", [userServices_1.UserServices,
        asyncHandler_1.default])
], UserController);
exports.default = UserController;
