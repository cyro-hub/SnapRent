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
const express_1 = __importDefault(require("express"));
require("reflect-metadata"); // Required for tsyringe
const tsyringe_1 = require("tsyringe");
const indexRouter_1 = __importDefault(require("./routes/indexRouter"));
const mongoose_1 = __importDefault(require("mongoose"));
let App = class App {
    constructor(appRouter) {
        this.appRouter = appRouter;
        this.app = (0, express_1.default)();
        this.initializeMiddleware();
        this.initializeRoutes();
        this.connectDB();
    }
    initializeMiddleware() {
        this.app.use(express_1.default.json());
        this.app.use(express_1.default.urlencoded({ extended: true }));
    }
    initializeRoutes() {
        // Use the appRouter's routes
        this.app.use("/api/v1", this.appRouter.appRouter);
    }
    connectDB() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const conn = yield mongoose_1.default.connect(process.env.MONGO_URI || "mongodb://localhost:27017/yourdbname");
                console.log(`mongoDB Connected`);
            }
            catch (error) {
                console.error(`Error: ${error.message}`);
                process.exit(1); // Exit the process on connection failure
            }
        });
    }
    start(port = 3000) {
        this.app.listen(port, () => {
            console.log(`Server is running on port ${port}`);
        });
    }
};
App = __decorate([
    (0, tsyringe_1.injectable)(),
    __metadata("design:paramtypes", [indexRouter_1.default])
], App);
exports.default = App;
