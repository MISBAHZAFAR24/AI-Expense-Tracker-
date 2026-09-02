const express = require("express");

const {
    getDashboard
} = require("../controllers/dashboardcontrollers");

const protect = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", protect, getDashboard);

module.exports = router;