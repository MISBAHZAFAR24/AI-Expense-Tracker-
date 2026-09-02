const Expense = require("../models/Expense");

// GET ALL EXPENSES WITH PAGINATION, SEARCH, AND FILTERS
const getExpenses = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { search, category, startDate, endDate, page = 1, limit = 10 } = req.query;

        // Build Filter Object
        let query = { user: userId };

        // Search by Title (Case-insensitive)
        if (search) {
            query.title = { $regex: search, $options: "i" };
        }

        // Filter by Category
        if (category) {
            query.category = category;
        }

        // Filter by Date Range
        if (startDate || endDate) {
            query.date = {};
            if (startDate) query.date.$gte = new Date(startDate);
            if (endDate) query.date.$lte = new Date(endDate);
        }

        // Pagination Logic
        const skip = (parseInt(page) - 1) * parseInt(limit);

        const expenses = await Expense.find(query)
            .sort({ date: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Expense.countDocuments(query);

        res.status(200).json({
            message: "Expenses fetched successfully",
            pagination: {
                total,
                page: parseInt(page),
                limit: parseInt(limit),
                totalPages: Math.ceil(total / limit)
            },
            expenses
        });
    } catch (error) {
        res.status(500).json({ message: "Error fetching expenses", error: error.message });
    }
};

// CRUD Operations
const createExpense = async (req, res) => {
    try {
        const expense = await Expense.create({ ...req.body, user: req.user.userId });
        res.status(201).json({ message: "Expense created successfully", expense });
    } catch (error) {
        res.status(500).json({ message: "Error creating expense", error: error.message });
    }
};

const getExpenseById = async (req, res) => {
    try {
        const expense = await Expense.findOne({ _id: req.params.id, user: req.user.userId });
        if (!expense) return res.status(404).json({ message: "Expense not found" });
        res.status(200).json(expense);
    } catch (error) {
        res.status(500).json({ message: "Error fetching expense", error: error.message });
    }
};

const updateExpense = async (req, res) => {
    try {
        const expense = await Expense.findOneAndUpdate(
            { _id: req.params.id, user: req.user.userId },
            req.body,
            { new: true }
        );
        if (!expense) return res.status(404).json({ message: "Expense not found" });
        res.status(200).json({ message: "Expense updated successfully", expense });
    } catch (error) {
        res.status(500).json({ message: "Error updating expense", error: error.message });
    }
};

const deleteExpense = async (req, res) => {
    try {
        const expense = await Expense.findOneAndDelete({ _id: req.params.id, user: req.user.userId });
        if (!expense) return res.status(404).json({ message: "Expense not found" });
        res.status(200).json({ message: "Expense deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: "Error deleting expense", error: error.message });
    }
};

module.exports = { createExpense, getExpenses, getExpenseById, updateExpense, deleteExpense };
