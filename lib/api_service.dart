import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  // Helper function to get Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // AUTH: Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Connection error: Check if backend is running"};
    }
  }

  // AUTH: Register
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {"message": "Connection error: Check if backend is running"};
    }
  }

  // EXPENSES: Get All
  static Future<List<dynamic>> getExpenses() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/expenses"),
      headers: {"Authorization": "Bearer $token"},
    );
    final data = jsonDecode(response.body);
    return data['expenses'] ?? [];
  }

  // AUTH: Get User Profile
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/auth/profile"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(response.body);
  }

  // EXPENSES: Add
  static Future<Map<String, dynamic>> addExpense(Map<String, dynamic> expenseData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/expenses"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(expenseData),
    );
    return jsonDecode(response.body);
  }

  // EXPENSES: Delete
  static Future<Map<String, dynamic>> deleteExpense(String id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/expenses/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(response.body);
  }

  // INCOME: Get All
  static Future<List<dynamic>> getIncome() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/income"),
      headers: {"Authorization": "Bearer $token"},
    );
    final data = jsonDecode(response.body);
    return data['incomes'] ?? [];
  }

  // INCOME: Add
  static Future<Map<String, dynamic>> addIncome(Map<String, dynamic> incomeData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/income"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(incomeData),
    );
    return jsonDecode(response.body);
  }

  // INCOME: Delete
  static Future<Map<String, dynamic>> deleteIncome(String id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/income/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(response.body);
  }

  // DASHBOARD DATA
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/dashboard"),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));
      
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Dashboard API Error: $e");
      return {};
    }
  }

  // AI ADVISOR (Backend uses POST /advice)
  static Future<Map<String, dynamic>> getAIAdvice({String? question}) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/ai-advisor/advice"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"question": question}),
    );
    return jsonDecode(response.body);
  }

  // REPORTS (Backend uses GET /api/reports?timeframe=...)
  static Future<Map<String, dynamic>> getReports(String timeframe) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/reports?timeframe=$timeframe"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(response.body);
  }
}
