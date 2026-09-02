const mongoose = require("mongoose");
const Expense = require("../models/expense");
const Income = require("../models/Income");

const getDashboard = async (req, res) => {
    try {
        if (!req.user || !req.user.userId) {
            return res.status(401).json({ message: "User not authenticated" });
        }

        const userId = new mongoose.Types.ObjectId(req.user.userId);
        console.log("Fetching dashboard for User ID:", userId);

        // 1. TOTAL EXPENSE
        const expenseResult = await Expense.aggregate([
            { $match: { user: userId } },
            { $group: { _id: null, totalExpense: { $sum: "$amount" } } }
        ]);
        const totalExpense = expenseResult.length > 0 ? expenseResult[0].totalExpense : 0;

        // 2. TOTAL INCOME
        const incomeResult = await Income.aggregate([
            { $match: { user: userId } },
            { $group: { _id: null, totalIncome: { $sum: "$amount" } } }
        ]);
        const totalIncome = incomeResult.length > 0 ? incomeResult[0].totalIncome : 0;

        // 3. BALANCE
        const balance = totalIncome - totalExpense;

        // 4. TRANSACTIONS COUNT (Renamed to avoid conflict)
        const totalExpenseCount = await Expense.countDocuments({ user: userId });
        const totalIncomeCount = await Income.countDocuments({ user: userId });
        const totalTransactions = totalExpenseCount + totalIncomeCount;

        // 5. TODAY EXPENSE
        const startOfToday = new Date();
        startOfToday.setHours(0, 0, 0, 0);
        const endOfToday = new Date();
        endOfToday.setHours(23, 59, 59, 999);

        const todayExpenseResult = await Expense.aggregate([
            { $match: { user: userId, date: { $gte: startOfToday, $lte: endOfToday } } },
            { $group: { _id: null, todayExpense: { $sum: "$amount" } } }
        ]);
        const todayExpense = todayExpenseResult.length > 0 ? todayExpenseResult[0].todayExpense : 0;

        // 6. THIS MONTH EXPENSE
        const startOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1);
        const endOfMonth = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0, 23, 59, 59, 999);

        const monthExpenseResult = await Expense.aggregate([
            { $match: { user: userId, date: { $gte: startOfMonth, $lte: endOfMonth } } },
            { $group: { _id: null, monthExpense: { $sum: "$amount" } } }
        ]);
        const monthExpense = monthExpenseResult.length > 0 ? monthExpenseResult[0].monthExpense : 0;

        // 7. CATEGORY-WISE EXPENSE
        const categoryExpenses = await Expense.aggregate([
            { $match: { user: userId } },
            { $group: { _id: "$category", totalAmount: { $sum: "$amount" } } },
            { $sort: { totalAmount: -1 } }
        ]);

        // 8. MONTHLY EXPENSE DATA
        const monthlyExpenses = await Expense.aggregate([
            { $match: { user: userId } },
            {
                $group: {
                    _id: { year: { $year: "$date" }, month: { $month: "$date" } },
                    totalAmount: { $sum: "$amount" }
                }
            },
            { $sort: { "_id.year": 1, "_id.month": 1 } }
        ]);

        console.log(`Dashboard Stats for ${userId}: Income: ${totalIncome}, Expense: ${totalExpense}, Balance: ${balance}`);

        // 9. RECENT TRANSACTIONS (Combining Income and Expense)
        const recentIncomeData = await Income.find({ user: userId }).sort({ date: -1 }).limit(5);
        const recentExpenseData = await Expense.find({ user: userId }).sort({ date: -1 }).limit(5);

        const formattedIncomes = recentIncomeData.map((item) => ({
            _id: item._id,
            title: item.title,
            amount: item.amount,
            category: item.category,
            date: item.date,
            type: "income"
        }));

        const formattedExpenses = recentExpenseData.map((item) => ({
            _id: item._id,
            title: item.title,
            amount: item.amount,
            category: item.category,
            date: item.date,
            type: "expense"
        }));

        const allRecent = [...formattedIncomes, ...formattedExpenses]
            .sort((a, b) => new Date(b.date) - new Date(a.date))
            .slice(0, 5);

        // FINAL RESPONSE
        res.status(200).json({
            message: "Dashboard data fetched successfully",
            dashboard: {
                totalIncome,
                totalExpense,
                balance,
                totalTransactions,
                todayExpense,
                monthExpense,
                categoryExpenses,
                monthlyExpenses,
                recentTransactions: allRecent
            }
        });

    } catch (error) {
        res.status(500).json({
            message: "Failed to fetch dashboard data",
            error: error.message
        });
    }
};

module.exports = { getDashboard };
