const mongoose = require("mongoose");
const dns = require("dns");

// Force Google DNS to resolve MongoDB Atlas SRV records
// This often fixes "querySrv ECONNREFUSED" errors
try {
    dns.setServers([
        "8.8.8.8",
        "8.8.4.4"
    ]);
} catch (e) {
    console.log("DNS setServers failed, skipping...");
}

const connectDB = async () => {
    try {
        if (!process.env.MONGO_URI) {
            console.error("Error: MONGO_URI is not defined in environment variables");
            return;
        }

        console.log("Connecting to MongoDB...");

        // Standard Mongoose connection with timeout to prevent hanging
        await mongoose.connect(process.env.MONGO_URI, {
            serverSelectionTimeoutMS: 5000, // 5 seconds mein fail ho jaye agar connect na ho
            connectTimeoutMS: 10000,
        });

        console.log("✅ MongoDB connected successfully");

    } catch (error) {
        console.error("❌ MongoDB connection failed:", error.message);

        if (error.message.includes("ECONNREFUSED")) {
            console.error("TIP: Apne internet connection check karein ya DNS setting change karein.");
            console.error("TIP: Agar SRV error hai, toh MongoDB Atlas ka 'Standard Connection String' use karein.");
        }
    }
};

module.exports = connectDB;
