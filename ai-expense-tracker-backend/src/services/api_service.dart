import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl =
      "https://ai-expense-tracker-i8t1.vercel.app/api/auth/login";

  // LOGIN API
  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  // DASHBOARD API
  static Future<Map<String, dynamic>?> getDashboard() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      throw Exception("Authentication token is required");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("Dashboard Status: ${response.statusCode}");
    debugPrint("Dashboard Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Dashboard request failed");
  }
  // ai advisor
  static Future<Map<String, dynamic>?> getAIAdvice({
    String? question,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        throw Exception("Authentication token is required");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/ai/advice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "question": question,
        }),
      );

      debugPrint("AI Status: ${response.statusCode}");
      debugPrint("AI Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("AI API Error: $e");
      rethrow;
    }
  }
}