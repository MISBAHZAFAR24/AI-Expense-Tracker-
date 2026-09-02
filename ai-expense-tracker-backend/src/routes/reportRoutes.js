const express = require("express");
const router = express.Router();
const { getReports } = require("../controllers/reportControllers");
const protect = require("../middleware/authMiddleware");

// @route   GET /api/reports
// @desc    Get financial reports (daily, weekly, monthly, yearly)
// @access  Private
router.get("/", protect, getReports);

module.exports = router;
