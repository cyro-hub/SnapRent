import passport from "passport";
import { Strategy as LocalStrategy } from "passport-local";
import { Strategy as JwtStrategy, ExtractJwt } from "passport-jwt";
import { User } from "../models/user";

passport.use(
  new LocalStrategy(
    { usernameField: "email" },
    async (email, password, done) => {
      try {
        const user = await User.findOne({ email });
        if (!user) return done(null, false, { message: "User not found" });
        // if (!user.isVerified)
        //   return done(null, false, { message: "Email not verified" });

        const isMatch = await user.comparePassword(password);
        if (!isMatch) return done(null, false, { message: "Invalid password" });

        return done(null, user);
      } catch (err) {
        return done(err);
      }
    }
  )
);

// JWT Strategy for protecting routes
passport.use(
  new JwtStrategy(
    {
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.JWT_ACCESS_SECRET! || "hjhjghgfdssasdsdfdg",
    },
    async (payload, done) => {
      try {
        const user = await User.findById(payload.id);
        if (!user) return done(null, false);
        done(null, user);
      } catch (err) {
        done(err, false);
      }
    }
  )
);

export default passport;
