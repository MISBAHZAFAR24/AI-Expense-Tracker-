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

        const userId = new mongoose.Types.ObjectId(req.user.userId);
        const { question } = req.body;

        // GET USER DATA
        const [expenses, incomes] = await Promise.all([
            Expense.find({ user: userId }),
            Income.find({ user: userId })
        ]);

        const totalExpense = expenses.reduce(
            (total, ex) => total + (ex.amount || 0),
            0
        );

        const totalIncome = incomes.reduce(
            (total, inc) => total + (inc.amount || 0),
            0
        );

        const balance = totalIncome - totalExpense;

        const categoryExpenses = {};

        expenses.forEach((ex) => {
            categoryExpenses[ex.category] =
                (categoryExpenses[ex.category] || 0) + ex.amount;
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