"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TenantRoleSchema = exports.CareTakerRoleSchema = exports.OwnerRoleSchema = exports.GuestRoleSchema = exports.acceptedRoleNames = void 0;
const mongoose_1 = require("mongoose");
exports.acceptedRoleNames = {
    Owner: "Owner",
    CareTaker: "Care-taker",
    Tenant: "Tenant",
    Guest: "Guest",
};
const OwnerRoleSchema = new mongoose_1.Schema({
    roleName: {
        type: String,
        required: true,
        default: exports.acceptedRoleNames.Owner,
        enum: Object.values(exports.acceptedRoleNames),
    },
    businesses: [{ type: mongoose_1.Schema.Types.ObjectId, ref: "Business" }], // Reference array of ObjectIds for businesses
    properties: [
        {
            type: mongoose_1.Schema.Types.ObjectId,
            ref: "Property",
            required: true, // Ensure properties are required
        },
    ],
});
exports.OwnerRoleSchema = OwnerRoleSchema;
const CareTakerRoleSchema = new mongoose_1.Schema({
    roleName: {
        type: String,
        required: true,
        default: exports.acceptedRoleNames.CareTaker,
        enum: Object.values(exports.acceptedRoleNames),
    },
    properties: [
        {
            propertyId: {
                type: mongoose_1.Schema.Types.ObjectId,
                ref: "Property",
                required: true,
            },
            BusinessId: {
                type: mongoose_1.Schema.Types.ObjectId,
                ref: "Business",
                required: true,
            },
        },
    ],
});
exports.CareTakerRoleSchema = CareTakerRoleSchema;
const TenantRoleSchema = new mongoose_1.Schema({
    roleName: {
        type: String,
        required: true,
        default: exports.acceptedRoleNames.Tenant,
        enum: Object.values(exports.acceptedRoleNames),
    },
    properties: [
        {
            propertyId: {
                type: mongoose_1.Schema.Types.ObjectId,
                ref: "Property",
                required: true,
            },
            BusinessId: {
                type: mongoose_1.Schema.Types.ObjectId,
                ref: "Business",
                required: true,
            },
        },
    ],
});
exports.TenantRoleSchema = TenantRoleSchema;
const GuestRoleSchema = new mongoose_1.Schema({
    roleName: {
        type: String,
        required: true,
        default: exports.acceptedRoleNames.Guest,
        enum: Object.values(exports.acceptedRoleNames),
    },
});
exports.GuestRoleSchema = GuestRoleSchema;
