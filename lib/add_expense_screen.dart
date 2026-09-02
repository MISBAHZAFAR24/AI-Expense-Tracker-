import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_model.dart';
import 'expense_provider.dart';
import 'dashboard_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;
  final int? editIndex;

  const AddExpenseScreen({super.key, this.expenseToEdit, this.editIndex});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late DateTime selectedDate;
  String? selectedCategory;
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.expenseToEdit?.date ?? DateTime.now();
    selectedCategory = widget.expenseToEdit?.category;
    titleController = TextEditingController(text: widget.expenseToEdit?.title ?? "");
    amountController = TextEditingController(
      text: widget.expenseToEdit?.amount != null
          ? widget.expenseToEdit!.amount.toString()
          : "",
    );
    descriptionController = TextEditingController(text: widget.expenseToEdit?.description ?? "");
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final amount = double.tryParse(amountController.text);
    if (titleController.text.isEmpty || amount == null || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final expense = Expense(
      title: titleController.text,
      amount: amount,
      category: selectedCategory!,
      description: descriptionController.text,
      date: selectedDate,
    );

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      if (widget.expenseToEdit != null) {
        // Update logic (can be added if needed)
      } else {
        await provider.addExpense(expense);
      }
      if (mounted) {
        // Refresh Dashboard Data immediately
        await Provider.of<DashboardProvider>(context, listen: false).fetchDashboardData();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        title: Text(widget.expenseToEdit != null ? "Edit Expense" : "Add Expense",
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "Enter title",
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                hintText: "Enter amount",
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                hintText: "Select Category",
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                ),
              ),
              items: ["Food", "Transport", "Rent", "Shopping", "Entertainment", "Health", "Others"]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Enter description",
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Expense",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
