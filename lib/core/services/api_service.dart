import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    // 10.0.2.2 is the special IP for Android emulator to access host machine localhost
    return 'http://10.0.2.2:3000/api';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> post(String endpoint, dynamic data, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final body = jsonEncode(data);

    debugPrint('[API POST] $url');
    final response = await http.post(url, headers: headers, body: body);
    _logResponse(response);
    return response;
  }

  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    debugPrint('[API GET] $url');
    final response = await http.get(url, headers: headers);
    _logResponse(response);
    return response;
  }

  Future<http.Response> put(String endpoint, dynamic data, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final body = jsonEncode(data);

    debugPrint('[API PUT] $url');
    final response = await http.put(url, headers: headers, body: body);
    _logResponse(response);
    return response;
  }

  void _logResponse(http.Response response) {
    debugPrint('[API Response] ${response.statusCode} | ${response.body.length} bytes');
    if (response.statusCode >= 400) {
      debugPrint('[API Error] ${response.body}');
    }
  }
}
