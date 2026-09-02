import 'package:flutter/material.dart';
import 'income_model.dart';
import 'api_service.dart';

class IncomeProvider with ChangeNotifier {
  List<Income> _incomes = [];
  bool _isLoading = false;

  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;

  double get totalIncome {
    return _incomes.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> fetchIncomes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getIncome();
      _incomes = data.map((e) => Income.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching income: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addIncome(Income income) async {
    try {
      final result = await ApiService.addIncome({
        "title": income.title,
        "amount": income.amount,
        "category": income.category,
        "date": income.date.toIso8601String(),
      });
      // Backend returns 'income' object on success
      if (result["income"] != null || result["message"] != null) {
        await fetchIncomes();
      }
    } catch (e) {
      debugPrint("Error adding income: $e");
    }
  }

  // Delete income from API
  Future<void> deleteIncome(String id) async {
    try {
      final result = await ApiService.deleteIncome(id);
      if (result["message"] != null) {
        await fetchIncomes();
      }
    } catch (e) {
      debugPrint("Error deleting income: $e");
    }
  }

  void updateIncome(int index, Income income) {
    _incomes[index] = income;
    notifyListeners();
  }
}
