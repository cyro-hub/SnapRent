"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
const tsyringe_1 = require("tsyringe");
let ApiResponse = class ApiResponse {
    constructor() {
        this.state = false;
        this.data = undefined;
        this.message = "Ok";
    }
    setFailedResponse(message, error = []) {
        this.state = false;
        this.message = message;
        this.validationErrorResponse = error;
    }
    setSuccessfulResponse(message, data) {
        this.state = true;
        this.message = message;
        this.data = data;
    }
    setSuccessfulPageResponse(message, data, page, pageSize, totalPages) {
        this.state = true;
        this.message = message;
        this.data = data;
        this.page = page;
        this.pageSize = pageSize;
        this.totalPages = totalPages;
        this.hasNextPage = page < totalPages;
    }
    toJSON() {
        return {
            state: this.state,
            data: this.data,
            message: this.message,
            page: this.page,
            pageSize: this.pageSize,
            totalPages: this.totalPages,
            hasNextPage: this.hasNextPage,
            validationErrorResponse: this.validationErrorResponse,
        };
    }
};
ApiResponse = __decorate([
    (0, tsyringe_1.injectable)()
], ApiResponse);
exports.default = ApiResponse;
