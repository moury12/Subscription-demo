import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_burn_model.dart';

class AiBurnService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/ai';
    return 'http://10.0.2.2:3000/api/ai';
  }

  Future<AiBurnAnalysisResult?> analyzeActivity(String description) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-burn'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'activityDescription': description}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return AiBurnAnalysisResult.fromJson(json);
      } else {
        debugPrint('Server error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Network error analyzing burn: $e');
      return null;
    }
  }
}
