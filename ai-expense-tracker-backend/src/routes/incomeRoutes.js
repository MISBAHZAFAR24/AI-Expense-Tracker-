const express = require("express");

const {
    createIncome,
    getIncomes,
    getIncomeById,
    updateIncome,
    deleteIncome
} = require("../controllers/incomeControllers");

const protect = require("../middleware/authMiddleware");

const router = express.Router();


// CREATE
router.post("/", protect, createIncome);


// GET ALL
router.get("/", protect, getIncomes);


// GET SINGLE
router.get("/:id", protect, getIncomeById);


// UPDATE
router.put("/:id", protect, updateIncome);


// DELETE
router.delete("/:id", protect, deleteIncome);


module.exports = router;;