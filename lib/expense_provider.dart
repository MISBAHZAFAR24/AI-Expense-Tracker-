import 'package:flutter/material.dart';
import 'expense_model.dart';
import 'api_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  double get totalExpense {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }

  // API से खर्चे लोड करें
  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getExpenses();
      _expenses = data.map((e) => Expense.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching expenses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // API में नया खर्चा जोड़ें
  Future<void> addExpense(Expense expense) async {
    try {
      final result = await ApiService.addExpense({
        "title": expense.title,
        "amount": expense.amount,
        "category": expense.category,
        "description": expense.description ?? "",
        "date": expense.date.toIso8601String(),
      });
      // Backend returns 'message' and 'expense' object on success
      if (result["expense"] != null || result["message"] != null) {
        await fetchExpenses(); // लिस्ट रिफ्रेश करें
      }
    } catch (e) {
      debugPrint("Error adding expense: $e");
    }
  }

  // Delete expense from API
  Future<void> deleteExpense(String id) async {
    try {
      final result = await ApiService.deleteExpense(id);
      if (result["message"] != null) {
        await fetchExpenses();
      }
    } catch (e) {
      debugPrint("Error deleting expense: $e");
    }
  }

  // Update expense (Placeholder - can be implemented if API supports PUT)
  void updateExpense(int index, Expense updatedExpense) {
    _expenses[index] = updatedExpense;
    notifyListeners();
  }
}
