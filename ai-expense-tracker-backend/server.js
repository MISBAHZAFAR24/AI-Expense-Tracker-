const express = require("express");
const cors = require("cors");
require("dotenv").config();
const connectDB = require("./src/config/db");

const authRoutes = require("./src/routes/authRoutes");
const dashboardRoutes = require("./src/routes/dashboardRoutes");
const incomeRoutes = require("./src/routes/incomeRoutes");
const reportRoutes = require("./src/routes/reportRoutes");
const aiAdvisorRoutes = require("./src/routes/aiAdvisorRoutes");
const expenseRoutes = require("./src/routes/expenseRoutes");

const app = express();
const PORT = process.env.PORT || 5000;

// Connect to Database
connectDB();

// Middleware
app.use(cors());
app.use(express.json());

// Logging Middleware (For debugging Vercel issues)
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Home API
app.get("/", (req, res) => {
    res.json({
        message: "AI Expense Tracker Backend is running successfully!",
        status: "Online",
        timestamp: new Date().toISOString(),
        mongoStatus: require("mongoose").connection.readyState === 1 ? "Connected" : "Disconnected"
    });
});

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/income", incomeRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/ai-advisor", aiAdvisorRoutes);
app.use("/api/expenses", expenseRoutes);

// Error Handling Middleware
app.use((err, req, res, next) => {
    console.error("Global Error Handler:", err.stack);
    res.status(500).json({
        message: "Something went wrong on the server!",
        error: process.env.NODE_ENV === "development" ? err.message : "Internal Server Error"
    });
});

// For local development
if (process.env.NODE_ENV !== "production") {
    app.listen(PORT, () => {
        console.log(`Server running locally on port ${PORT}`);
    });
}

module.exports = app;
