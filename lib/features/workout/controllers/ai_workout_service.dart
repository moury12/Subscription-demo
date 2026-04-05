import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_workout_plan.dart';

class AiWorkoutService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/ai';
    return 'http://10.0.2.2:3000/api/ai';
  }

  Future<AiWeeklyWorkoutPlan?> generateMyPlan(Map<String, dynamic> userProfile) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workout-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userProfile),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
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
