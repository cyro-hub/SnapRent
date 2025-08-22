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
exports.Services = void 0;
const tsyringe_1 = require("tsyringe");
const mongoose_1 = require("mongoose");
const apiResponse_1 = __importDefault(require("../utils/apiResponse"));
const customError_1 = __importDefault(require("../utils/customError"));
const class_transformer_1 = require("class-transformer");
const class_validator_1 = require("class-validator");
let Services = class Services {
    constructor(response, model) {
        this.response = response;
        this.message = "No message provided.";
        this.data = {};
        this.createDoc = (args) => __awaiter(this, void 0, void 0, function* () {
            const newDoc = new this.model(args);
            yield newDoc.save();
            return newDoc;
        });
        this.getDoc = (args) => __awaiter(this, void 0, void 0, function* () {
            const doc = yield this.model.findOne(args);
            if (!doc) {
                throw new customError_1.default(`${this.getModelName()} not found.`, {
                    statusCode: 404,
                });
            }
            return doc;
        });
        this.getDocs = (args) => __awaiter(this, void 0, void 0, function* () {
            const docs = yield this.model.find(args);
            return docs;
        });
        this.validateInput = (dtoClass, args) => __awaiter(this, void 0, void 0, function* () {
            // Convert plain object to class instance
            const createDto = (0, class_transformer_1.plainToInstance)(dtoClass, args);
            // Validate the DTO object
            const errors = yield (0, class_validator_1.validate)(createDto);
            // If there are validation errors
            if (errors.length > 0) {
                const validationErrors = errors.map((error) => ({
                    field: error.property,
                    messages: Object.values(error.constraints || {}),
                }));
                // Throw a custom error with validation details
                throw new customError_1.default("Validation failed.", {
                    statusCode: 400,
                    validationError: validationErrors,
                });
            }
            return;
        });
        this.model = model;
    }
    getModelName() {
        return this.model.modelName; // Gets the model name automatically
    }
};
exports.Services = Services;
exports.Services = Services = __decorate([
    (0, tsyringe_1.injectable)(),
    __metadata("design:paramtypes", [apiResponse_1.default, mongoose_1.Model])
], Services);
