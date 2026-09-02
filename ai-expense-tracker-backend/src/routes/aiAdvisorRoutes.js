const express = require("express");

const {
    getAIAdvice
} = require("../controllers/aiAdvisorController");

const protect = require("../middleware/authMiddleware");

const router = express.Router();


router.post("/advice", protect, getAIAdvice);


module.exports = router;