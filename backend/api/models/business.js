"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Business = void 0;
const mongoose_1 = require("mongoose");
const address_1 = require("./address");
// Business Schema
const BusinessSchema = new mongoose_1.Schema({
    businessName: { type: String, required: true },
    businessAddress: { type: address_1.AddressSchema, required: true },
    bankAccountDetails: {
        accountNumber: { type: String, required: true },
        bankName: { type: String, required: true },
        routingNumber: { type: String, required: true },
    },
    owner: { type: mongoose_1.Schema.Types.ObjectId, ref: "Owner", required: true }, // Foreign key reference to Owner
}, { timestamps: true } // Automatically add createdAt and updatedAt timestamps
);
// Create and export the Business model
exports.Business = (0, mongoose_1.model)("Business", BusinessSchema);
