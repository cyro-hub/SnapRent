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
const mongodb_1 = require("mongodb");
const apiResponse_1 = __importDefault(require("./apiResponse"));
const customError_1 = __importDefault(require("./customError"));
let AsyncHandler = class AsyncHandler {
    constructor(response) {
        this.response = response;
    }
    handleDuplicate(error) {
        const errorMessage = error.errmsg;
        const collectionRegex = /collection: (\S+)/;
        const match = errorMessage.match(collectionRegex);
        if (match && match[1]) {
            if (match[1].split(".")[1] === "users") {
                this.response.setFailedResponse("Invalid user credentials.", []);
            }
            else {
                const key = Object.keys(error.keyValue)[0];
                const value = error.keyValue[key];
                this.response.setFailedResponse(`${value} already exists in ${match[1].split(".")[1]}`, []);
            }
        }
        else {
            this.response.setFailedResponse("Collection name not found in error message.", []);
        }
        return this.response.toJSON();
    }
    handleOtherCustomError(error) {
        const { validationError } = error.details;
        this.response.setFailedResponse(error.message, validationError);
        return this.response.toJSON();
    }
    handleOtherError(error) {
        this.response.setFailedResponse(error.message, []);
        return this.response.toJSON();
    }
    handler(fn) {
        return (req, res, next) => __awaiter(this, void 0, void 0, function* () {
            try {
                yield fn(req, res, next);
            }
            catch (error) {
                if (error.name === "CastError") {
                    this.response.setFailedResponse("Invalid request type.", []);
                    return res.status(400).json(this.response.toJSON());
                }
                if (error instanceof mongodb_1.MongoServerError && error.code === 11000) {
                    return res.status(409).json(this.handleDuplicate(error));
                }
                if (error instanceof customError_1.default) {
                    const { statusCode, validationError } = error.details;
                    return res
                        .status(statusCode)
                        .json(this.handleOtherCustomError(error));
                }
                if (error instanceof Error) {
                    return res.status(500).json(this.handleOtherError(error));
                }
                return res.status(500).json({ message: "Internal server error." });
            }
        });
    }
};
AsyncHandler = __decorate([
    (0, tsyringe_1.injectable)(),
    __metadata("design:paramtypes", [apiResponse_1.default])
], AsyncHandler);
exports.default = AsyncHandler;
