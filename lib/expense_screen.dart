import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';
import 'add_expense_screen.dart';

IconData getCategoryIcon(String category) {
  switch (category) {
    case "Food":
      return Icons.restaurant;

    case "Shopping":
      return Icons.shopping_cart;

    case "Transport":
      return Icons.directions_car;

    case "Medical":
      return Icons.medical_services;

    case "Education":
      return Icons.school;

    case "Bills":
      return Icons.receipt_long;

    case "Entertainment":
      return Icons.movie;

    default:
      return Icons.receipt_long;
  }
}

class ExpenseScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const ExpenseScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expensesList = expenseProvider.expenses;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (onBack != null) {
              onBack!();
            }
          },
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Expenses",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Total Expenses Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              "Total Expenses: ₹${expenseProvider.totalExpense.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Expenses List or Empty State
          Expanded(
            child: expensesList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 70,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "No Expenses Yet",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Add your first expense\nto start tracking.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddExpenseScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Expense"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: expensesList.length,
                    itemBuilder: (context, index) {
                      // Showing newest first
                      final actualIndex = expensesList.length - 1 - index;
                      final expense = expensesList[actualIndex];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF10B981).withOpacity(0.1),
                            child: Icon(
                              getCategoryIcon(expense.category),
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          title: Text(
                            expense.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${expense.category}  "
                            "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "-₹${expense.amount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (expense.id != null) {
                                    expenseProvider.deleteExpense(expense.id!);
                                  }
                                },
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddExpenseScreen(
                                        expenseToEdit: expense,
                                        editIndex: actualIndex,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
