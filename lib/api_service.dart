import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://ai-expense-tracker-i8t1.vercel.app/api";

  // Helper function to get Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Helper function to handle common response logic
  static dynamic _processResponse(http.Response response, String functionName) {
    debugPrint("$functionName Status: ${response.statusCode}");
    debugPrint("$functionName Response: ${response.body}");

    if (response.body.startsWith("<!DOCTYPE html>")) {
      throw Exception("Server Error: Vercel returned HTML instead of JSON. Check backend logs.");
    }

    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw Exception(data['message'] ?? "Request failed with status: ${response.statusCode}");
    }
    return data;
  }

  // AUTH: Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response, "Login");
    } catch (e) {
      debugPrint("Login Error: $e");
      return {"message": e.toString()};
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

      return _processResponse(response, "Register");
    } catch (e) {
      debugPrint("Register Error: $e");
      return {"message": e.toString()};
    }
  }

  // EXPENSES: Get All
  static Future<List<dynamic>> getExpenses() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/expenses"),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      final data = _processResponse(response, "GetExpenses");
      return data['expenses'] ?? [];
    } catch (e) {
      debugPrint("GetExpenses Error: $e");
      return [];
    }
  }

  // AUTH: Get User Profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response, "GetProfile");
    } catch (e) {
      debugPrint("GetProfile Error: $e");
      return {"message": e.toString()};
    }
  }

  // EXPENSES: Add
  static Future<Map<String, dynamic>> addExpense(Map<String, dynamic> expenseData) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/expenses"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(expenseData),
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response, "AddExpense");
    } catch (e) {
      debugPrint("AddExpense Error: $e");
      return {"message": e.toString()};
    }
  }

  // EXPENSES: Delete
  static Future<Map<String, dynamic>> deleteExpense(String id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse("$baseUrl/expenses/$id"),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response, "DeleteExpense");
    } catch (e) {
      debugPrint("DeleteExpense Error: $e");
      return {"message": e.toString()};
    }
  }

  // INCOME: Get All
  static Future<List<dynamic>> getIncome() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/income"),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      final data = _processResponse(response, "GetIncome");
      return data['incomes'] ?? [];
    } catch (e) {
      debugPrint("GetIncome Error: $e");
      return [];
    }
  }

  // INCOME: Add
  static Future<Map<String, dynamic>> addIncome(Map<String, dynamic> incomeData) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/income"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(incomeData),
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response, "AddIncome");
    } catch (e) {
      debugPrint("AddIncome Error: $e");
      return {"message": e.toString()};
    }
  }

  // INCOME: Delete
  static Future<Map<String, dynamic>> deleteIncome(String id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse("$baseUrl/income/$id"),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response, "DeleteIncome");
    } catch (e) {
      debugPrint("DeleteIncome Error: $e");
      return {"message": e.toString()};
    }
  }

  // DASHBOARD DATA
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/dashboard"),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));
      
      return _processResponse(response, "GetDashboard");
    } catch (e) {
      debugPrint("Dashboard API Error: $e");
      return {};
    }
  }

  // AI ADVISOR (Backend uses POST /advice)
  static Future<Map<String, dynamic>> getAIAdvice({String? question}) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/ai-advisor/advice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"question": question}),
      ).timeout(const Duration(seconds: 15));

      return _processResponse(response, "GetAIAdvice");
    } catch (e) {
      debugPrint("AI Advisor Error: $e");
      return {"message": e.toString()};
    }
  }

  // REPORTS (Backend uses GET /api/reports?timeframe=...)
  static Future<Map<String, dynamic>> getReports(String timeframe) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/reports?timeframe=$timeframe"),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response, "GetReports");
    } catch (e) {
      debugPrint("GetReports Error: $e");
      return {"message": e.toString()};
    }
  }
}
