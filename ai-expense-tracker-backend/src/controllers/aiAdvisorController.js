const mongoose = require("mongoose");
const Expense = require("../models/expense");
const Income = require("../models/Income");
const { getFinancialAdvice } = require("../services/aiAdvisorService");

const getAIAdvice = async (req, res) => {
    try {
        if (!req.user || !req.user.userId) {
            return res.status(401).json({
                status: "error",
                message: "User not authenticated"
            });
        }

        const userIdStr = String(req.user.userId);
        const userIdObj = mongoose.Types.ObjectId.isValid(userIdStr)
            ? new mongoose.Types.ObjectId(userIdStr)
            : userIdStr;
        const { question } = req.body;

        // GET USER DATA - Querying both ObjectId and String formats for 100% database match
        const [expenses, incomes] = await Promise.all([
            Expense.find({ user: { $in: [userIdStr, userIdObj] } }),
            Income.find({ user: { $in: [userIdStr, userIdObj] } })
        ]);

        const totalExpense = expenses.reduce(
            (total, ex) => total + (Number(ex.amount) || 0),
            0
        );

        const totalIncome = incomes.reduce(
            (total, inc) => total + (Number(inc.amount) || 0),
            0
        );

        const balance = totalIncome - totalExpense;

        const categoryExpenses = {};

        expenses.forEach((ex) => {
            if (ex.category) {
                categoryExpenses[ex.category] =
                    (categoryExpenses[ex.category] || 0) + (Number(ex.amount) || 0);
            }
        });

        const financialData = {
            totalIncome,
            totalExpense,
            balance,
            categoryExpenses,
            monthlyExpenses: expenses.map((ex) => ({
                amount: ex.amount,
                date: ex.date
            })),
            question
        };

        const advice = await getFinancialAdvice(financialData);

        res.status(200).json({
            status: "success",
            data: {
                totalIncome,
                totalExpense,
                balance,
                advice
            }
        });

    } catch (error) {
        console.error("AI Controller Error:", error);

        res.status(500).json({
            status: "error",
            message: error.message
        });
    }
};

module.exports = {
    getAIAdvice
};
