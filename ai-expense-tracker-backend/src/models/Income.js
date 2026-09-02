const mongoose = require("mongoose");

const incomeSchema = new mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },
        title: {
            type: String,
            required: [true, "Title is required"],
            trim: true
        },
        amount: {
            type: Number,
            required: [true, "Amount is required"],
            min: [1, "Amount must be greater than 0"]
        },
        category: {
            type: String,
            required: [true, "Category is required"],
            trim: true
        },
        description: {
            type: String,
            trim: true
        },
        date: {
            type: Date,
            default: Date.now
        }
    },
    {
        timestamps: true
    }
);

// Prevent OverwriteModelError
module.exports = mongoose.models.Income || mongoose.model("Income", incomeSchema);
