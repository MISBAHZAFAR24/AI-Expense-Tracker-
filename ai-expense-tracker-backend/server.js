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

// Middleware
app.use(cors());
app.use(express.json());

// Connect to Database
connectDB();

// Home API
app.get("/", (req, res) => {
    res.json({
        message: "AI Expense Tracker Backend is running successfully!",
        status: "Online",
        timestamp: new Date().toISOString()
    });
});

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/income", incomeRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/ai-advisor", aiAdvisorRoutes);
app.use("/api/expenses", expenseRoutes);

// Error Handling Middleware (Optional but recommended)
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: "Something went wrong!", error: err.message });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
