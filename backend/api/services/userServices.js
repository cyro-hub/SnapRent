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
exports.UserServices = void 0;
const tsyringe_1 = require("tsyringe");
const services_1 = require("./services");
const user_1 = __importDefault(require("../models/user"));
const apiResponse_1 = __importDefault(require("../utils/apiResponse"));
const bcrypt_1 = require("../utils/bcrypt");
const jwt_1 = __importDefault(require("../utils/jwt"));
const user_2 = require("../dtos/user");
const customError_1 = __importDefault(require("../utils/customError"));
const selectRoleDto_1 = require("../dtos/selectRoleDto");
let UserServices = class UserServices extends services_1.Services {
    constructor(response, codec, jwt) {
        super(response, user_1.default);
        this.response = response;
        this.codec = codec;
        this.jwt = jwt;
        this.createUser = (args) => __awaiter(this, void 0, void 0, function* () {
            // validating user request object
            yield this.validateInput(user_2.CreateUserDto, args);
            args.password = yield this.codec.hash(args.password);
            const newUser = yield this.createDoc(args);
            const { accessToken, refreshToken } = this.createToken(newUser._id, newUser.selectedRole);
            newUser.refreshToken = refreshToken;
            yield newUser.save();
            this.message = "Successful.";
            this.data = Object.assign(Object.assign({}, newUser.toObject()), { password: "", refreshToken: "" });
            this.response.setSuccessfulResponse(this.message, this.data);
            return {
                user: newUser,
                response: this.response.toJSON(),
                accessToken,
                refreshToken,
            };
        });
        this.loginUser = (args) => __awaiter(this, void 0, void 0, function* () {
            // validating user request object
            yield this.validateInput(user_2.CreateUserDto, args);
            const { email } = args;
            const user = yield this.getDoc({ email });
            if (!(yield this.codec.compare(args.password, user.password))) {
                throw new customError_1.default("Invalid credentials.", { statusCode: 400 });
            }
            const { accessToken, refreshToken } = this.createToken(user._id, user.selectedRole);
            user.refreshToken = refreshToken;
            yield user.save();
            this.message = "Successful.";
            this.data = Object.assign(Object.assign({}, user.toObject()), { password: "", refreshToken: "" });
            this.response.setSuccessfulResponse(this.message, this.data);
            return {
                user: user,
                response: this.response.toJSON(),
                accessToken,
                refreshToken,
            };
        });
        this.selectRole = (role, token) => __awaiter(this, void 0, void 0, function* () {
            const authToken = token.split(" ")[1];
            yield this.validateInput(selectRoleDto_1.SelectRoleDto, { role, token: authToken });
            const decodedToken = this.jwt.verifyAccessToken(authToken);
            if (typeof decodedToken !== "object" || !decodedToken) {
                throw new customError_1.default("Invalid token.", { statusCode: 400 });
            }
            const { _id, selectedRole } = decodedToken;
            const user = yield this.getDoc({ _id });
            if (!user) {
                throw new customError_1.default("Invalid user.", { statusCode: 404 });
            }
            const roleExists = user.roles.some((userRole) => userRole.roleName === role);
            if (!roleExists) {
                throw new customError_1.default("Invalid role selection.", {
                    statusCode: 400,
                });
            }
            const { accessToken, refreshToken } = this.createToken(_id, role);
            user.refreshToken = refreshToken;
            user.selectedRole = role;
            yield user.save();
            this.message = "Successful.";
            this.data = Object.assign(Object.assign({}, user.toObject()), { password: "", refreshToken: "" });
            this.response.setSuccessfulResponse(this.message, this.data);
            return {
                user: user,
                response: this.response.toJSON(),
                accessToken,
                refreshToken,
            };
        });
    }
    createToken(_id, selectedRole) {
        const accessToken = this.jwt.generateAccessToken(_id, selectedRole);
        const refreshToken = this.jwt.generateRefreshToken(_id, selectedRole);
        return { accessToken, refreshToken };
    }
};
exports.UserServices = UserServices;
exports.UserServices = UserServices = __decorate([
    (0, tsyringe_1.injectable)(),
    __metadata("design:paramtypes", [apiResponse_1.default,
        bcrypt_1.Bcrypt,
        jwt_1.default])
], UserServices);
