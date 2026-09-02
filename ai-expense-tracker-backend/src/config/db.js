const mongoose = require("mongoose");
const connectDB = async () => {
    try {
        if (!process.env.MONGO_URI) {
            console.error("Error: MONGO_URI is not defined in environment variables");
            return;
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log("MongoDB connected successfully");
    } catch (error) {
        console.error("MongoDB connection failed:", error.message);
        // On Vercel, we don't want to exit the process, just log the error
    }
};
module.exports = connectDB;
