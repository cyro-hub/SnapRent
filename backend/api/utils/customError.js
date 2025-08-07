"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class CustomError extends Error {
    constructor(message, details) {
        super(message);
        this.details = details;
        this.name = "CustomError";
    }
}
exports.default = CustomError;
