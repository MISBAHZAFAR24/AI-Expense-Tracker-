const Income = require("../models/Income");

// GET ALL INCOMES WITH PAGINATION, SEARCH, AND FILTERS
const getIncomes = async (req, res) => {
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

        const incomes = await Income.find(query)
            .sort({ date: -1 })
            .skip(skip)
            .limit(parseInt(limit));

        const total = await Income.countDocuments(query);

        res.status(200).json({
            message: "Incomes fetched successfully",
            pagination: {
                total,
                page: parseInt(page),
                limit: parseInt(limit),
                totalPages: Math.ceil(total / limit)
            },
            incomes
        });
    } catch (error) {
        res.status(500).json({ message: "Error fetching incomes", error: error.message });
    }
};

// CRUD Operations
const createIncome = async (req, res) => {
    try {
        const income = await Income.create({ ...req.body, user: req.user.userId });
        res.status(201).json({ message: "Income created successfully", income });
    } catch (error) {
        res.status(500).json({ message: "Error creating income", error: error.message });
    }
};

const getIncomeById = async (req, res) => {
    try {
        const income = await Income.findOne({ _id: req.params.id, user: req.user.userId });
        if (!income) return res.status(404).json({ message: "Income not found" });
        res.status(200).json(income);
    } catch (error) {
        res.status(500).json({ message: "Error fetching income", error: error.message });
    }
};

const updateIncome = async (req, res) => {
    try {
        const income = await Income.findOneAndUpdate(
            { _id: req.params.id, user: req.user.userId },
            req.body,
            { new: true }
        );
        if (!income) return res.status(404).json({ message: "Income not found" });
        res.status(200).json({ message: "Income updated successfully", income });
    } catch (error) {
        res.status(500).json({ message: "Error updating income", error: error.message });
    }
};

const deleteIncome = async (req, res) => {
    try {
        const income = await Income.findOneAndDelete({ _id: req.params.id, user: req.user.userId });
        if (!income) return res.status(404).json({ message: "Income not found" });
        res.status(200).json({ message: "Income deleted successfully" });
    } catch (error) {
        res.status(500).json({ message: "Error deleting income", error: error.message });
    }
};

module.exports = { createIncome, getIncomes, getIncomeById, updateIncome, deleteIncome };
