import 'package:flutter/material.dart';
import 'api_service.dart';

class DashboardProvider with ChangeNotifier {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.getDashboard();
      if (response != null && response['dashboard'] != null) {
        _dashboardData = response['dashboard'];
        debugPrint("Dashboard loaded successfully");
      } else {
        _error = response?['message'] ?? "No data found";
      }
    } catch (e) {
      _error = "Connection failed";
      debugPrint("Error fetching dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
