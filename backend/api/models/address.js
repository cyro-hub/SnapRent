"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AddressSchema = void 0;
const mongoose_1 = require("mongoose");
// Address Schema
exports.AddressSchema = new mongoose_1.Schema({
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    postalCode: { type: String, required: true },
    country: { type: String, required: true },
});
