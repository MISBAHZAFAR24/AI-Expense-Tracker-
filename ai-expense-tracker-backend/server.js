const express = require("express");
const app = express();
require("dotenv").config();
const connectDB = require("./src/config/db");
const PORT = process.env.PORT || 5000;
const Expense = require("./src/models/expense");
const ExpenseController = require("./src/controllers/expenseControllers");
const authRoutes = require("./src/routes/authRoutes");
const dashboardRoutes = require("./src/routes/dashboardRoutes");
const incomeRoutes = require("./src/routes/incomeRoutes");
const reportRoutes = require("./src/routes/reportRoutes");
const aiAdvisorRoutes = require("./src/routes/aiAdvisorRoutes");
const expenseRoutes = require("./src/routes/expenseRoutes");

// Middleware
app.use(express.json());

// Connect to Database
connectDB();

// Home API
app.get("/", (req, res) => {
    res.json({
        message: "ai expense tracker backend is running "
    });
});
app.use("/api/expenses", expenseRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/income", incomeRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/ai-advisor", aiAdvisorRoutes);


app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
