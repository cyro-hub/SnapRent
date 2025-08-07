"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
const app_1 = __importDefault(require("./app"));
const tsyringe_1 = require("tsyringe");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const app = tsyringe_1.container.resolve(app_1.default);
const PORT = process.env.PORT || 3000;
app.start(PORT);
