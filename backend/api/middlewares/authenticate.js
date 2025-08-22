"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class Authenticate {
    constructor(jwt) {
        this.jwt = jwt;
    }
    authenticateToken(req, res, next) {
        const authHeader = req.headers["authorization"];
        const token = authHeader && authHeader.split(" ")[1];
        if (!token) {
            return res.status(401).json({ message: "Token is required" });
        }
        const decoded = this.jwt.verifyAccessToken(token);
        if (!decoded) {
            return res.status(403).json({ message: "Invalid or expired token" });
        }
        // Attach the decoded token to req.user
        req.user = decoded;
        // Type guard: Check if req.user is defined before accessing _id
        if (!req.user || !req.user._id) {
            return res.status(403).json({ message: "User information is missing" });
        }
        next(); // Proceed if the user is authenticated
    }
}
exports.default = Authenticate;
