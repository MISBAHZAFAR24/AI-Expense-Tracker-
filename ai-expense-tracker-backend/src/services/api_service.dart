import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // BASE URL


  static const String baseUrl =
      "https://ai-expense-tracker-ij23.onrender.com/api";


  // TIMEOUT


  static const Duration _timeoutDuration =
  Duration(seconds: 30);


  // LOGIN API


  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    try {
      debugPrint("LOGIN REQUEST STARTED");

      final response = await http
          .post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      )
          .timeout(_timeoutDuration);

      debugPrint("LOGIN STATUS: ${response.statusCode}");
      debugPrint("LOGIN RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      return data;
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");

      throw Exception(
        "Server taking too long to respond. Please try again.",
      );
    }
  }


  // DASHBOARD API


  static Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        throw Exception(
          "Authentication token is required",
        );
      }

      debugPrint("DASHBOARD REQUEST STARTED");

      final response = await http
          .get(
        Uri.parse("$baseUrl/dashboard"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      )
          .timeout(_timeoutDuration);

      debugPrint(
        "DASHBOARD STATUS: ${response.statusCode}",
      );

      debugPrint(
        "DASHBOARD RESPONSE: ${response.body}",
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(
        data["message"] ??
            "Dashboard request failed",
      );
    } on Exception catch (e) {
      debugPrint(
        "DASHBOARD ERROR: $e",
      );

      rethrow;
    } catch (e) {
      debugPrint(
        "DASHBOARD UNKNOWN ERROR: $e",
      );

      throw Exception(
        "Unable to load dashboard",
      );
    }
  }


  // AI ADVISOR API


  static Future<Map<String, dynamic>?> getAIAdvice({
    String? question,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        throw Exception(
          "Authentication token is required",
        );
      }

      debugPrint("AI REQUEST STARTED");

      debugPrint(
        "AI QUESTION: $question",
      );

      final response = await http
          .post(
        Uri.parse("$baseUrl/ai/advice"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "question": question ?? "",
        }),
      )
          .timeout(_timeoutDuration);

      debugPrint(
        "AI STATUS: ${response.statusCode}",
      );

      debugPrint(
        "AI RESPONSE: ${response.body}",
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(
        data["message"] ??
            "AI advice request failed",
      );
    } on Exception catch (e) {
      debugPrint(
        "AI API ERROR: $e",
      );

      rethrow;
    } catch (e) {
      debugPrint(
        "AI UNKNOWN ERROR: $e",
      );

      throw Exception(
        "Unable to get AI advice",
      );
    }
  }
}