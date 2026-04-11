import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../models/ai_burn_model.dart';

class AiBurnService {
  final ApiService _api = ApiService();

  Future<AiBurnAnalysisResult?> analyzeActivity(String description) async {
    try {
      final response = await _api.post(
        '/ai/analyze-burn',
        {'activityDescription': description},
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
