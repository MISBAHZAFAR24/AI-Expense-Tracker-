const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Valid Google Gemini models with fallback fallback chain
const MODEL_CANDIDATES = [
    "gemini-3.6-flash",
    "gemini-1.5-flash",
    "gemini-2.0-flash",
    "gemini-1.5-pro"
];

const generateWithRetry = async (prompt) => {
    let lastError = null;

    for (const modelName of MODEL_CANDIDATES) {
        try {
            console.log(`Trying AI Model: ${modelName}`);
            const model = genAI.getGenerativeModel({ model: modelName });
            const result = await model.generateContent(prompt);
            const text = result.response.text();
            if (text && text.trim().length > 0) {
                return text;
            }
        } catch (error) {
            console.error(`AI Model ${modelName} failed:`, error.message);
            lastError = error;
        }
    }

    throw lastError || new Error("All AI model candidates failed.");
};

const getFinancialAdvice = async (financialData) => {
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

    try {
        const response = await generateWithRetry(prompt);
        return response;
    } catch (error) {
        console.error("AI Service Error:", error.message);

        // Fallback response if Google Gemini API experiences high demand (503 Service Unavailable)
        const topCategoryEntry = Object.entries(financialData.categoryExpenses || {})
            .sort((a, b) => b[1] - a[1])[0];

        const topCategoryText = topCategoryEntry
            ? `Your highest expense category is ${topCategoryEntry[0]} (₹${topCategoryEntry[1]}).`
            : "Keep tracking your daily expenses!";

        return `📊 Financial Summary:\n- Total Income: ₹${financialData.totalIncome}\n- Total Expense: ₹${financialData.totalExpense}\n- Current Balance: ₹${financialData.balance}\n\n💡 Insight:\n${topCategoryText}\n\n(Note: Google Gemini API is experiencing high demand right now. Here is your automated budget breakdown!)`;
    }
};

module.exports = {
    getFinancialAdvice
};
