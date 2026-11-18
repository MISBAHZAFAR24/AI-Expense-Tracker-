const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "dummy_key");

const MODEL_CANDIDATES = [
    "gemini-1.5-flash",
    "gemini-2.0-flash",
    "gemini-1.5-pro"
];

// Smart Financial Intelligence Engine (Instant 100% Reliable Fallback Engine)
const generateSmartAdvice = (data) => {
    const { totalIncome, totalExpense, balance, categoryExpenses, question } = data;

    let response = "";

    // 1. Direct Question Handler if user asked a specific question
    if (question && String(question).trim().length > 0) {
        const q = String(question).toLowerCase();

        // Extract numbers in question (e.g. "phone for 15000")
        const amountMatch = String(question).match(/\b\d+\b/);
        const itemAmount = amountMatch ? parseInt(amountMatch[0], 10) : null;

        if (q.includes("phone") || q.includes("buy") || q.includes("afford") || q.includes("car") || q.includes("trip") || q.includes("laptop")) {
            if (itemAmount) {
                if (balance >= itemAmount) {
                    const remaining = balance - itemAmount;
                    response += `YES! You can afford this purchase of ₹${itemAmount}.\n\n- Current Balance: ₹${balance}\n- Remaining Buffer after purchase: ₹${remaining}\n\nRecommendation: You have enough balance, but keep at least ₹${Math.round(totalIncome * 0.2)} saved for emergencies!`;
                } else {
                    const diff = itemAmount - balance;
                    response += `NO, it is NOT recommended right now.\n\n- Purchase Cost: ₹${itemAmount}\n- Current Balance: ₹${balance}\n- Shortfall: ₹${diff}\n\nRecommendation: You need ₹${diff} more in savings before making this purchase. Try reducing non-essential expenses for the next few weeks.`;
                }
            } else {
                if (balance > totalIncome * 0.3) {
                    response += `Based on your current balance of ₹${balance} and expenses of ₹${totalExpense}, you have a good financial cushion. Make sure any major purchase stays under ₹${Math.round(balance * 0.5)}!`;
                } else {
                    response += `Your current balance is ₹${balance}. It is safer to hold off on major non-essential purchases until your emergency savings grow.`;
                }
            }
            return response;
        }

        if (q.includes("save") || q.includes("saving") || q.includes("money")) {
            response += `💡 Smart Saving Strategy for You:\n\n1. Target the 50/30/20 Rule: Allocate 50% for Needs, 30% for Wants, and 20% directly into Savings.\n2. Your Current Savings Ratio: ${totalIncome > 0 ? Math.round((balance / totalIncome) * 100) : 0}%\n3. Practical Step: Set aside ₹${Math.round(totalIncome * 0.2)} at the beginning of the month before making discretionary expenses!`;
            return response;
        }

        if (q.includes("food") || q.includes("eat") || q.includes("restaurant")) {
            const foodSpend = categoryExpenses?.Food || categoryExpenses?.food || 0;
            response += `🍕 Food Expense Analysis:\n\n- You have spent ₹${foodSpend} on Food.\n- Food Share of Income: ${totalIncome > 0 ? Math.round((foodSpend / totalIncome) * 100) : 0}%\n\nTip: Cooking at home or meal prepping on weekends can save you up to 40% on monthly food costs!`;
            return response;
        }

        if (q.includes("top") || q.includes("highest") || q.includes("summary") || q.includes("analyze")) {
            const topCategoryEntry = Object.entries(categoryExpenses || {}).sort((a, b) => b[1] - a[1])[0];
            const topName = topCategoryEntry ? topCategoryEntry[0] : "General";
            const topAmount = topCategoryEntry ? topCategoryEntry[1] : 0;
            response += `📊 Spending Analysis:\n\n- Highest Spending Area: ${topName} (₹${topAmount})\n- Total Expenses: ₹${totalExpense}\n- Remaining Income: ₹${balance}\n\nActionable Advice: Reducing ${topName} expenses by 15% will save you ₹${Math.round(topAmount * 0.15)} next month!`;
            return response;
        }

        // Generic user question answer fallback
        response += `💡 Financial Answer to "${question}":\n\n- Current Earnings: ₹${totalIncome}\n- Total Expenses: ₹${totalExpense}\n- Available Balance: ₹${balance}\n\nAdvice: Focus on maintaining your emergency savings buffer of at least 3 months of expenses (₹${totalExpense * 3}).`;
        return response;
    }

    // Default Comprehensive Financial Advice Analysis
    const topCategoryEntry = Object.entries(categoryExpenses || {}).sort((a, b) => b[1] - a[1])[0];
    const topCatName = topCategoryEntry ? topCategoryEntry[0] : "General";
    const topCatVal = topCategoryEntry ? topCategoryEntry[1] : 0;
    const savingsRatio = totalIncome > 0 ? Math.round((balance / totalIncome) * 100) : 0;

    response += `📊 Financial Health Assessment:\n\n1. Income vs Expense:\n- Total Earnings: ₹${totalIncome}\n- Total Spending: ₹${totalExpense}\n- Net Balance: ₹${balance} (${savingsRatio}% savings rate)\n\n2. Primary Cost Driver:\n- Highest Category: ${topCatName} at ₹${topCatVal}\n\n3. Actionable Advice:\n- Keep your essential living expenses under 60% of earnings.\n- Try saving at least ₹${Math.round(totalIncome * 0.2)} at the start of each month!`;

    return response;
};

const generateWithRetry = async (prompt) => {
    let lastError = null;

    for (const modelName of MODEL_CANDIDATES) {
        try {
            console.log(`Trying AI Model: ${modelName}`);
            const model = genAI.getGenerativeModel({ model: modelName });

            // 4-Second Timeout to ensure fast responses
            const timeoutPromise = new Promise((_, reject) =>
                setTimeout(() => reject(new Error("Gemini API request timed out (4s limit)")), 4000)
            );

            const apiPromise = model.generateContent(prompt).then(res => res.response.text());
            const text = await Promise.race([apiPromise, timeoutPromise]);

            if (text && text.trim().length > 0) {
                console.log(`AI Success with model: ${modelName}`);
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
        console.error("Gemini API Error, switching to Smart Financial Intelligence Engine:", error.message);
        // Instant 100% reliable fallback answer
        return generateSmartAdvice(financialData);
    }
};

module.exports = {
    getFinancialAdvice
};
