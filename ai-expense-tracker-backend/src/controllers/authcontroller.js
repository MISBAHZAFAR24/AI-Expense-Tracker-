const User = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// REGISTER USER
const registerUser = async (req, res) => {
    try {
        const { name, email, password } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({
                message: "Name, email and password are required"
            });
        }

        const existingUser = await User.findOne({ email });

        if (existingUser) {
            return res.status(400).json({
                message: "User already exists"
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await User.create({
            name,
            email,
            password: hashedPassword
        });

        const token = jwt.sign(
            { userId: user._id },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        return res.status(201).json({
            message: "User registered successfully",
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email
            }
        });

    } catch (error) {
        console.error("Registration Error:", error);
        return res.status(500).json({
            message: "Registration failed",
            error: error.message
        });
    }
};

// LOGIN USER
const loginUser = async (req, res) => {
    try {
        const start = Date.now();
        const { email, password } = req.body;

        console.log("Login request received");

        if (!email || !password) {
            return res.status(400).json({
                message: "Email and password are required"
            });
        }

        const dbStart = Date.now();
        const user = await User.findOne({ email });

        console.log("MongoDB findOne time:", Date.now() - dbStart, "ms");

        if (!user) {
            return res.status(401).json({
                message: "Invalid email or password"
            });
        }

        const bcryptStart = Date.now();
        const isPasswordCorrect = await bcrypt.compare(password, user.password);

        console.log("Bcrypt compare time:", Date.now() - bcryptStart, "ms");

        if (!isPasswordCorrect) {
            return res.status(401).json({
                message: "Invalid email or password"
            });
        }

        const token = jwt.sign(
            { userId: user._id },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        console.log("Total login time:", Date.now() - start, "ms");

        return res.status(200).json({
            message: "Login successful",
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email
            }
        });

    } catch (error) {
        console.error("Login Error:", error);
        return res.status(500).json({
            message: "Login failed",
            error: error.message
        });
    }
};

// GET PROFILE
const getProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user.userId).select("-password");

        if (!user) {
            return res.status(404).json({
                message: "User not found"
            });
        }

        return res.status(200).json({
            status: "success",
            data: user
        });

    } catch (error) {
        console.error("Profile Error:", error);
        return res.status(500).json({
            message: "Error fetching profile",
            error: error.message
        });
    }
};

module.exports = {
    registerUser,
    loginUser,
    getProfile
};
