const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(
    process.env.GEMINI_API_KEY
);

const model = genAI.getGenerativeModel({
    model: "gemini-3.6-flash"
});

// Retry function
const generateWithRetry = async (prompt, retries = 3) => {

    for (let attempt = 1; attempt <= retries; attempt++) {

        try {
            console.log(`AI Request Attempt ${attempt}`);

            const result = await model.generateContent(prompt);

            return result.response.text();

        } catch (error) {

            console.error(
                `AI Request Attempt ${attempt} failed:`,
                error.message
            );

            // Last attempt -> throw error
            if (attempt === retries) {
                throw error;
            }

            // Wait before retry
            const delay = attempt * 3000;

            console.log(
                `Retrying AI request in ${delay / 1000} seconds...`
            );

            await new Promise((resolve) =>
                setTimeout(resolve, delay)
            );
        }
    }
};


const getFinancialAdvice = async (financialData) => {

    try {

        const userQuestion = financialData.question
            ? `\nUser's specific question: ${financialData.question}`
            : "";

        const prompt = `
You are a personal finance advisor.

Analyze the following user's financial data:

Total Income: ₹${financialData.totalIncome}
Total Expense: ₹${financialData.totalExpense}
Balance: ₹${financialData.balance}

Category-wise Expenses:
${JSON.stringify(financialData.categoryExpenses)}

Monthly Expenses:
${JSON.stringify(financialData.monthlyExpenses)}
${userQuestion}

Give simple and practical financial advice.

If the user asked a specific question, answer it first using the data provided.
Otherwise, include:
1. Spending analysis
2. Highest spending category
3. Saving suggestions
4. One or two practical actions for next month

Keep the response short and easy to understand.
`;

        // Generate AI response with retry
        const response = await generateWithRetry(prompt);

        return response;

    } catch (error) {

        console.error("AI Service Error:", error.message);

        throw error;
    }
};


module.exports = {
    getFinancialAdvice
};