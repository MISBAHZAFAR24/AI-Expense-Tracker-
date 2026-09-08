const User = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt  = require("jsonwebtoken");

const registerUser = async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // Check required fields
        if (!name || !email || !password) {
            return res.status(400).json({
                message: "Name, email and password are required"
            });
        }

        // Check if user already exists
        const existingUser = await User.findOne({ email });

        if (existingUser) {
            return res.status(400).json({
                message: "User already exists"
            });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create user
        const user = await User.create({
            name,
            email,
            password: hashedPassword
        });

        // Create JWT for automatic login after signup
        const token = jwt.sign(
            { userId: user._id },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        res.status(201).json({
            message: "User registered successfully",
            token: token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email
            }
        });

    } catch (error) {
        res.status(500).json({
            message: "Registration failed",
            error: error.message
        });
    }
};

const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check fields
        if (!email || !password) {
            return res.status(400).json({
                message: "Email and password are required"
            });
        }

        // Find user
        const loginUser = async (req, res) => {
            try {
                const start = Date.now();

                const { email, password } = req.body;

                console.log("Login request received");

                // Find user
                const dbStart = Date.now();
                const user = await User.findOne({ email });

                console.log(
                    "MongoDB findOne time:",
                    Date.now() - dbStart,
                    "ms"
                );

                if (!user) {
                    return res.status(401).json({
                        message: "Invalid email or password"
                    });
                }

                // Check password
                const bcryptStart = Date.now();

                const isPasswordCorrect = await bcrypt.compare(
                    password,
                    user.password
                );

                console.log(
                    "Bcrypt compare time:",
                    Date.now() - bcryptStart,
                    "ms"
                );

                if (!isPasswordCorrect) {
                    return res.status(401).json({
                        message: "Invalid email or password"
                    });
                }

                // Create JWT
                const jwtStart = Date.now();

                const token = jwt.sign(
                    { userId: user._id },
                    process.env.JWT_SECRET,
                    { expiresIn: "7d" }
                );

                console.log(
                    "JWT time:",
                    Date.now() - jwtStart,
                    "ms"
                );

                console.log(
                    "Total login time:",
                    Date.now() - start,
                    "ms"
                );

                res.status(200).json({
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

                res.status(500).json({
                    message: "Login failed",
                    error: error.message
                });
            }
        };

module.exports = {registerUser, loginUser, getProfile};