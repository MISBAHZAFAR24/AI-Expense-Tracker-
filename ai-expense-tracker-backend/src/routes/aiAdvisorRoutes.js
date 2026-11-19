const express = require("express");

const {
    getAIAdvice,
    scanReceipt,
    predictNextMonthExpenses
} = require("../controllers/aiAdvisorController");

const protect = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/advice", protect, getAIAdvice);
router.post("/scan-receipt", protect, scanReceipt);
router.post("/predict-expenses", protect, predictNextMonthExpenses);

module.exports = router;
