const mongoose = require("mongoose");
const dns = require("dns");

// Google DNS use karo MongoDB Atlas SRV lookup ke liye
dns.setServers([
    "8.8.8.8",
    "8.8.4.4"
]);

const connectDB = async () => {
    try {
        if (!process.env.MONGO_URI) {
            console.error(
                "Error: MONGO_URI is not defined in environment variables"
            );
            return;
        }

        await mongoose.connect(process.env.MONGO_URI);

        console.log("MongoDB connected successfully");

    } catch (error) {
        console.error(
            "MongoDB connection failed:",
            error.message
        );
    }
};

module.exports = connectDB;