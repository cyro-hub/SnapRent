import "reflect-metadata";
import App from "./app";
import { container } from "tsyringe";
import dotenv from "dotenv";

dotenv.config();

const app = container.resolve(App);

const PORT = process.env.PORT || 3000;

app.start(PORT);
