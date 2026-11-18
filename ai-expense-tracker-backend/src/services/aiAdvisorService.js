const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "dummy_key");

// Valid official Google Gemini Flash models
const MODEL_CANDIDATES = [
    "gemini-1.5-flash",
    "gemini-2.0-flash",
    "gemini-1.5-pro"
];

// Smart Universal AI Engine (Handles Hindi/English, Greetings, Purchases, EMI, Category Queries & Investment)
const generateSmartAdvice = (data) => {
    const { totalIncome, totalExpense, balance, categoryExpenses, question } = data;

    if (!question || String(question).trim().length === 0) {
        const topCategoryEntry = Object.entries(categoryExpenses || {}).sort((a, b) => b[1] - a[1])[0];
        const topCatName = topCategoryEntry ? topCategoryEntry[0] : "General";
        const topCatVal = topCategoryEntry ? topCategoryEntry[1] : 0;
        const savingsRatio = totalIncome > 0 ? Math.round((balance / totalIncome) * 100) : 0;

        return `📊 Financial Health Assessment:\n\n1. Income vs Expense:\n- Total Earnings: ₹${totalIncome}\n- Total Spending: ₹${totalExpense}\n- Net Balance: ₹${balance} (${savingsRatio}% savings rate)\n\n2. Primary Cost Driver:\n- Highest Category: ${topCatName} at ₹${topCatVal}\n\n3. Actionable Advice:\n- Keep your essential living expenses under 60% of earnings.\n- Try saving at least ₹${Math.round(totalIncome * 0.2)} at the start of each month!`;
    }

    const q = String(question).toLowerCase().trim();

    // 1. Greetings & Casual Chat
    if (q === "hi" || q === "hello" || q === "hey" || q.includes("kaise ho") || q.includes("kya hal") || q.includes("kya haal")) {
        return `Hello! 👋 Main FinWise AI Smart Assistant hu. Main badiya hu! Aap bataiye, aaj mai aapki budget, savings, ya expense tracking me kya help kar sakta hu?`;
    }

    if (q.includes("who are you") || q.includes("kon ho") || q.includes("kaun ho") || q.includes("namaste") || q.includes("name")) {
        return `Namaste! 🙏 Main FinWise AI Assistant hu. Main aapke real-time income, expenses, aur balance ko analyze karke smart money saving tips aur purchase guidance deta hu!`;
    }

    // Number extraction helper
    const amountMatch = String(question).match(/\b\d+\b/);
    const itemAmount = amountMatch ? parseInt(amountMatch[0], 10) : null;

    // 2. Universal Dynamic Category Query Matcher (Checks ALL user categories in database)
    const categoryKeys = Object.keys(categoryExpenses || {});
    for (const catKey of categoryKeys) {
        if (q.includes(catKey.toLowerCase())) {
            const amt = Number(categoryExpenses[catKey]) || 0;
            const share = totalIncome > 0 ? Math.round((amt / totalIncome) * 100) : 0;
            return `🏷️ Category Analysis for "${catKey}":\n\n- Total Spent on ${catKey}: ₹${amt}\n- Share of Monthly Income: ${share}%\n\nInsight: ${amt > 0 ? `Aapne ${catKey} par ₹${amt} kharch kiye hain (${share}% of earnings). Is category ko budget range me rakhna balance maintain karne me madad karega!` : `${catKey} category me abhi koi kharcha record nahi hua hai.`}`;
        }
    }

    // 3. EMI / Loan / Credit Card Affordability
    if (q.includes("emi") || q.includes("loan") || q.includes("kist") || q.includes("installment") || q.includes("credit card")) {
        if (itemAmount) {
            const maxSafeEmi = Math.round(totalIncome * 0.15); // Max 15% of income safe for EMI
            if (itemAmount <= maxSafeEmi && balance > itemAmount * 2) {
                return `YES! ₹${itemAmount}/month ki EMI aapke budget me safe hai. ✅\n\n- Monthly Safe EMI Target (15% Income): ₹${maxSafeEmi}\n- Total Balance: ₹${balance}\n\nTip: EMI chalu hone ke baad bhi kam se kam ₹${Math.round(totalIncome * 0.2)} monthly savings maintain rakhein!`;
            } else {
                return `NO! ₹${itemAmount}/month ki EMI aapke budget par pressure daal sakti hai. ⚠️\n\n- Safe Monthly EMI Limit: ₹${maxSafeEmi}\n- Available Balance: ₹${balance}\n\nTip: High EMI lene ke bajaye pehle down payment badhayein ya chota tenure select karein.`;
            }
        } else {
            const safeEmi = Math.round(totalIncome * 0.15);
            return `💳 EMI & Loan Guidance:\n\n- Aapki monthly income (₹${totalIncome}) ke hisab se maximum safe EMI **₹${safeEmi}/month** honi chahiye.\n- Total EMIs aapki income ka 20% se zyada kabhi nahi honi chahiye!`;
        }
    }

    // 4. Emergency Fund Calculation
    if (q.includes("emergency") || q.includes("fund") || q.includes("crisis") || q.includes("survive")) {
        const targetEmergencyFund = Math.round(totalExpense * 3);
        const fundStatus = balance >= targetEmergencyFund ? "Achieved 🎉" : "Building Phase ⏳";
        return `🛡️ Emergency Fund Advisor:\n\n- Target Emergency Fund (3 Months Expenses): ₹${targetEmergencyFund}\n- Current Available Balance: ₹${balance}\n- Status: ${fundStatus}\n\nRule: Emergency fund ko hamesha high-liquidity Savings Account ya Liquid Mutual Fund me rakhein taaki zaroorat padne par instant withdraw kar sakein!`;
    }

    // 5. Daily Spending Allowance / Daily Limit
    if (q.includes("daily") || q.includes("per day") || q.includes("roz") || q.includes("rozaana") || q.includes("aaj")) {
        const remainingDays = 15; // Average days left buffer
        const safeDailyLimit = balance > 0 ? Math.round(balance / remainingDays) : 0;
        return `📅 Daily Spending Allowance:\n\n- Available Balance: ₹${balance}\n- Estimated Safe Daily Spending Limit: **₹${safeDailyLimit}/day**\n\nTip: Agar aap aaj ₹${safeDailyLimit} se kam kharch karte hain, toh bacha hua amount aapki monthly savings me add ho jayega!`;
    }

    // 6. Investment & Wealth Guidance (SIP, FD, Mutual Funds)
    if (q.includes("invest") || q.includes("sip") || q.includes("fd") || q.includes("mutual fund") || q.includes("stock")) {
        const suggestedSip = Math.round(balance * 0.3);
        return `📈 Smart Wealth & Investment Plan:\n\n- Current Balance: ₹${balance}\n- Recommended Monthly SIP Amount: **₹${suggestedSip > 0 ? suggestedSip : 1000}**\n\nStrategy:\n1. Emergency Fund (₹${Math.round(totalExpense * 2)}) pehle alag rakhein.\n2. Bacha hua surplus amount Index Mutual Funds ya Nifty 50 SIP me long term ke liye invest karein!`;
    }

    // 7. Rent & Essential Bills Check
    if (q.includes("rent") || q.includes("bills") || q.includes("kiraya") || q.includes("electric")) {
        const rentSpend = categoryExpenses?.Rent || categoryExpenses?.rent || categoryExpenses?.Bills || 0;
        return `🏠 Rent & Bills Breakdown:\n\n- Total Rent/Bills Recorded: ₹${rentSpend}\n- Share of Monthly Earnings: ${totalIncome > 0 ? Math.round((rentSpend / totalIncome) * 100) : 0}%\n\nStandard Rule: Essential fixed costs (Rent + Utility Bills) aapki gross income ka 30-35% se zyada nahi hona chahiye.`;
    }

    // 8. Number extraction for purchases
    if (q.includes("phone") || q.includes("buy") || q.includes("afford") || q.includes("car") || q.includes("trip") || q.includes("laptop") || q.includes("khareed") || q.includes("khared") || q.includes("lenu")) {
        if (itemAmount) {
            if (balance >= itemAmount) {
                const remaining = balance - itemAmount;
                return `YES! Aap ₹${itemAmount} ka ye purchase afford kar sakte hain. 🎉\n\n- Current Balance: ₹${balance}\n- Purchase ke baad bacha Balance: ₹${remaining}\n\nRecommendation: Transaction ke baad bhi aapke paas emergency buffer bacha rahega!`;
            } else {
                const diff = itemAmount - balance;
                return `NO! Abhi ye khareedna recommended nahi hai. ⚠️\n\n- Purchase Cost: ₹${itemAmount}\n- Current Balance: ₹${balance}\n- Shortfall (Kami): ₹${diff}\n\nRecommendation: Is purchase ke liye aapko ₹${diff} aur save karne ki zaroorat hai. Pehle balance grow hone dein!`;
            }
        } else {
            if (balance > totalIncome * 0.3) {
                return `Aapka current balance ₹${balance} hai aur total expense ₹${totalExpense} hai. Aap safe zone me hain! Kisi bhi major purchase ka cost ₹${Math.round(balance * 0.5)} se zyada nahi hona chahiye.`;
            } else {
                return `Aapka current balance ₹${balance} hai. Unnecessary expenses ko pause karein aur emergency fund build karein!`;
            }
        }
    }

    // 9. Savings & Money Advice
    if (q.includes("save") || q.includes("saving") || q.includes("paisa") || q.includes("bacha") || q.includes("money")) {
        const savingsRatio = totalIncome > 0 ? Math.round((balance / totalIncome) * 100) : 0;
        return `💡 Smart Saving Formula:\n\n1. 50/30/20 Rule Follow Karein:\n   - 50% Needs (Rent, Bills)\n   - 30% Wants (Shopping, Outing)\n   - 20% Direct Savings!\n2. Aapka Current Savings Rate: ${savingsRatio}%\n3. Tip: Har mahine ki shuruaat me kam se kam ₹${Math.round(totalIncome * 0.2)} pehle save karein, phir bacha hua amount kharch karein!`;
    }

    // 10. Food / Outing Category
    if (q.includes("food") || q.includes("khana") || q.includes("eat") || q.includes("restaurant") || q.includes("swiggy") || q.includes("zomato")) {
        const foodSpend = categoryExpenses?.Food || categoryExpenses?.food || 0;
        return `🍕 Food Expense Analysis:\n\n- Total Food Expense: ₹${foodSpend}\n- Income Share: ${totalIncome > 0 ? Math.round((foodSpend / totalIncome) * 100) : 0}%\n\nTip: Home cooking aur weekend meal prep se aap monthly food bill par 30-40% tak save kar sakte hain!`;
    }

    // 11. Category Breakdown / Top Expense
    if (q.includes("top") || q.includes("highest") || q.includes("summary") || q.includes("kharcha") || q.includes("analyze")) {
        const topCategoryEntry = Object.entries(categoryExpenses || {}).sort((a, b) => b[1] - a[1])[0];
        const topName = topCategoryEntry ? topCategoryEntry[0] : "General";
        const topAmount = topCategoryEntry ? topCategoryEntry[1] : 0;
        return `📊 Spending Analysis:\n\n- Sabse Zyada Kharcha: ${topName} (₹${topAmount})\n- Total Expense: ₹${totalExpense}\n- Available Balance: ₹${balance}\n\nTip: Agar aap ${topName} category me 15% reduction karenge, toh agle month ₹${Math.round(topAmount * 0.15)} extra save ho jayenge!`;
    }

    // 12. Universal Question Answer Fallback
    return `💡 Answer for "${question}":\n\n- Total Earnings: ₹${totalIncome}\n- Total Expenses: ₹${totalExpense}\n- Available Balance: ₹${balance}\n\nAdvice: FinWise AI recommends keeping an emergency buffer of 3 months expenses (approx ₹${totalExpense * 3}). Any decision that keeps your balance positive is a smart move!`;
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
        console.error("Gemini API Error, switching to Universal Smart Financial Engine:", error.message);
        // Instant 100% reliable fallback answer
        return generateSmartAdvice(financialData);
    }
};

module.exports = {
    getFinancialAdvice
};
