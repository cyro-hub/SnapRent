"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = require("mongoose");
const AddressSchema = new mongoose_1.Schema({
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    postalCode: { type: String, required: true },
    country: { type: String, required: true },
});
const PropertySchema = new mongoose_1.Schema({
    propertyName: { type: String, required: true },
    propertyType: {
        type: String,
        enum: ["Residential", "Commercial"],
        required: true,
    },
    businessId: { type: mongoose_1.Schema.Types.ObjectId, ref: "Owner", required: true },
    address: { type: AddressSchema, required: true },
    sizeInSqFt: { type: Number },
    numberOfUnits: { type: Number },
    owner: { type: mongoose_1.Schema.Types.ObjectId, ref: "Owner", required: true },
    caretaker: { type: mongoose_1.Schema.Types.ObjectId, ref: "Caretaker" },
    tenantIds: [{ type: mongoose_1.Schema.Types.ObjectId, ref: "Tenant" }],
    isActive: { type: Boolean, default: true },
}, { timestamps: true } // Automatically adds `createdAt` and `updatedAt`
);
exports.default = (0, mongoose_1.model)("Property", PropertySchema);
