import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../models/ai_workout_plan.dart';

class AiWorkoutService {
  final ApiService _api = ApiService();

  Future<AiWeeklyWorkoutPlan?> generateMyPlan(Map<String, dynamic> userProfile) async {
    try {
      final response = await _api.post('/ai/workout-plan', userProfile);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint('Raw AI Workout Plan JSON: $json');
        return AiWeeklyWorkoutPlan.fromJson(json);
      } else {
        debugPrint('Server error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Network error generating plan: $e');
      return null;
    }
  }
}
