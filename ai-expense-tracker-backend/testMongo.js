require("dotenv").config();
const mongoose = require("mongoose");

console.log("Trying MongoDB connection...");

mongoose.connect(process.env.MONGO_URI)
    .then((connection) => {
        console.log("SUCCESS!");
        console.log("Host:", connection.connection.host);
        process.exit(0);
    })
    .catch((error) => {
        console.error("FAILED!");
        console.error(error);
        process.exit(1);
    });