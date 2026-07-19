import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static String get baseUrl {
    // Deployed AWS Backend
    return 'http://98.85.34.11:5000/api';
    
    /* Local Development fallbacks:
    if (kReleaseMode) {
      return 'http://98.85.34.11:5000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
    */
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get current language code from shared preferences
  Future<String> _getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_language') ?? 'en';
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
    
    // Add language to request body if it's a Map
    dynamic requestBody = data;
    if (data is Map) {
      requestBody = Map.from(data);
      if (requestBody['language'] == null) {
        requestBody['language'] = await _getLanguage();
      }
    }
    
    final body = jsonEncode(requestBody);

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
    
    // Add language to request body if it's a Map
    dynamic requestBody = data;
    if (data is Map) {
      requestBody = Map.from(data);
      if (requestBody['language'] == null) {
        requestBody['language'] = await _getLanguage();
      }
    }
    
    final body = jsonEncode(requestBody);

    debugPrint('[API PUT] $url');
    final response = await http.put(url, headers: headers, body: body);
    _logResponse(response);
    return response;
  }

  Future<http.Response> patch(String endpoint, dynamic data, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);

    dynamic requestBody = data ?? {};
    if (data is Map) {
      requestBody = Map.from(data);
    }
    final body = jsonEncode(requestBody);

    debugPrint('[API PATCH] $url');
    final response = await http.patch(url, headers: headers, body: body);
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
