import 'package:flutter/foundation.dart';
import '../app_settings.dart';
import '../services/log_service.dart';
import '../services/reminder_scheduler.dart';
import '../services/localization_service.dart';
import '../../features/workout/models/ai_workout_plan.dart';
import '../../features/nutrition/controllers/nutrition_controller.dart';
import '../../features/progress/controllers/burn_history_controller.dart';
import '../../features/progress/controllers/weight_history_controller.dart';
import '../../features/workout/controllers/workout_controller.dart';
import '../../features/profile/services/profile_service.dart';

/// Loads all persisted user data from the backend after login or app restart.
class UserDataSync {
  static Future<void> loadAll() async {
    await Future.wait([
      _loadWorkoutPlans(),
      _loadProfileAndLanguage(),
      NutritionController().loadFromDatabase(),
      BurnHistoryController().loadFromDatabase(),
      WorkoutController().loadFromDatabase(),
      WeightHistoryController().loadFromDatabase(),
    ]);
    debugPrint('[SYNC] All user data loaded from database');

    // Schedule notifications based on today's existing logs
    ReminderScheduler().scheduleTodayNotifications();
  }

  static Future<void> _loadProfileAndLanguage() async {
    try {
      final profile = await ProfileService().getProfile();
      if (profile != null && profile.containsKey('language')) {
        final languageName = profile['language'] as String;
        // Map language name back to code
        String? langCode;
        final names = LocalizationService().languageNames;
        names.forEach((code, name) {
          if (name.toLowerCase() == languageName.toLowerCase()) {
            langCode = code;
          }
        });

        if (langCode != null) {
          await LocalizationService().setLanguage(langCode!);
          debugPrint('[SYNC] Set language from profile: $langCode');
        }
      }
    } catch (e) {
      debugPrint('[SYNC] Error loading profile language: $e');
    }
  }

  static Future<void> _loadWorkoutPlans() async {
    final plans = await LogService().getWorkoutPlans();
    final settings = AppSettings();
    settings.clearWorkoutPlans();

    for (final planJson in plans) {
      try {
        final plan = AiWeeklyWorkoutPlan.fromJson(planJson);
        settings.addWorkoutPlan(plan);
      } catch (e) {
        debugPrint('[SYNC] Skipping invalid workout plan: $e');
      }
    }

    // If the latest plan has nutritional targets, apply them
    if (settings.workoutPlans.isNotEmpty) {
      final latest = settings.workoutPlans.first;
      if (latest.nutritionalTargets != null) {
        settings.targetCalories = latest.nutritionalTargets!.dailyCalories;
        settings.targetProtein = latest.nutritionalTargets!.dailyProtein;
        settings.targetCarbs = latest.nutritionalTargets!.dailyCarbs;
        settings.targetFat = latest.nutritionalTargets!.dailyFat;
      }
    }
  }

  static void clearAll() {
    AppSettings().clearWorkoutPlans();
    NutritionController().clearAll();
    BurnHistoryController().clearAll();
    WorkoutController().clearAll();
    WeightHistoryController().clearAll();
  }
}
