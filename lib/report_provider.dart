import 'package:flutter/material.dart';
import 'api_service.dart';

class ReportProvider with ChangeNotifier {
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  Map<String, dynamic>? get reportData => _reportData;
  bool get isLoading => _isLoading;

  Future<void> fetchReportData(String timeframe) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.getReports(timeframe);
      if (response != null && response['status'] == 'success') {
        _reportData = response['data'];
      }
    } catch (e) {
      debugPrint("Error fetching reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
