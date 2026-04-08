import '../../../core/services/api_service.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  final ApiService _api = ApiService();

  Future<bool> saveMealLog(Map<String, dynamic> mealData) async {
    try {
      final response = await _api.post('/logs/meals', mealData);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveWorkoutLog(Map<String, dynamic> workoutData) async {
    try {
      final response = await _api.post('/logs/workouts', workoutData);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveBurnLog(Map<String, dynamic> burnData) async {
    try {
      final response = await _api.post('/logs/burns', burnData);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveWorkoutPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _api.post('/logs/plans', planData);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
