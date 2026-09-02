const Expense = require("../models/expense");
const Income = require("../models/Income");
const mongoose = require("mongoose");

/**
 * @desc    Generate Financial Reports (Daily, Weekly, Monthly, Yearly)
 * @route   GET /api/reports
 * @access  Private
 */
const getReports = async (req, res) => {
    try {
        const userId = new mongoose.Types.ObjectId(req.user.userId);
        const { timeframe = 'monthly' } = req.query;

        const now = new Date();
        let startDate = new Date();

        // 1. Timeframe Logic (Daily, Weekly, Monthly, Yearly)
        if (timeframe === 'daily') {
            startDate.setHours(0, 0, 0, 0);
        } else if (timeframe === 'weekly') {
            startDate.setDate(now.getDate() - 7);
        } else if (timeframe === 'yearly') {
            startDate.setFullYear(now.getFullYear() - 1);
        } else { // default: monthly (Last 30 days)
            startDate.setDate(now.getDate() - 30);
        }

        const matchQuery = { user: userId, date: { $gte: startDate } };

        // 2. Parallel Calculations
        const [expenseTotalData, incomeTotalData, categoryAnalysis, trendData] = await Promise.all([
            // Total Expense in period
            Expense.aggregate([
                { $match: matchQuery },
                { $group: { _id: null, total: { $sum: "$amount" } } }
            ]),
            // Total Income in period
            Income.aggregate([
                { $match: matchQuery },
                { $group: { _id: null, total: { $sum: "$amount" } } }
            ]),
            // Category Analysis (Expenses)
            Expense.aggregate([
                { $match: matchQuery },
                { $group: { _id: "$category", amount: { $sum: "$amount" }, count: { $sum: 1 } } },
                { $sort: { amount: -1 } }
            ]),
            // Spending Trend
            Expense.aggregate([
                { $match: matchQuery },
                {
                    $group: {
                        _id: { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
                        amount: { $sum: "$amount" }
                    }
                },
                { $sort: { "_id": 1 } }
            ]),
        ]);

        const totalExpense = expenseTotalData[0]?.total || 0;
        const totalIncome = incomeTotalData[0]?.total || 0;

        res.status(200).json({
            status: "success",
            timeframe,
            data: {
                summary: {
                    totalIncome,
                    totalExpense,
                    incomeVsExpense: totalIncome - totalExpense,
                    savings: totalIncome - totalExpense,
                    savingsRate: totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome * 100).toFixed(2) + "%" : "0%"
                },
                categoryAnalysis,
                spendingTrend: trendData
            }
        });

    } catch (error) {
        console.error("Report Error:", error);
        res.status(500).json({ status: "error", message: "Report generation failed" });
    }
};

module.exports = { getReports };
