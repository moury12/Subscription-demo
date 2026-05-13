/// Localization Helper - Add this to easily access translations throughout the app
///
/// Usage in Widgets:
/// ```dart
/// // Get a single string
/// Text(context.l10n.getString('profile.full_name'))
///
/// // Get string with parameters
/// Text(context.l10n.getStringWithParams(
///   'greeting',
///   {'name': 'Ahmed'}
/// ))
/// ```
///
/// For more details, see the translation examples below.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

extension LocalizationExtension on BuildContext {
  LanguageProvider get l10n => watch<LanguageProvider>();
  LanguageProvider get l10nRead => read<LanguageProvider>();
}

/// Common translation keys used throughout the app
class TranslationKeys {
  // Common
  static const appName = 'common.app_name';
  static const ok = 'common.ok';
  static const cancel = 'common.cancel';
  static const save = 'common.save';
  static const done = 'common.done';
  static const update = 'common.update';
  static const delete = 'common.delete';
  static const edit = 'common.edit';
  static const close = 'common.close';
  static const loading = 'common.loading';
  static const error = 'common.error';
  static const success = 'common.success';

  // Profile
  static const personalInformation = 'profile.personal_information';
  static const fullName = 'profile.full_name';
  static const age = 'profile.age';
  static const heightCm = 'profile.height_cm';
  static const currentWeight = 'profile.current_weight';
  static const entryWeight = 'profile.entry_weight';
  static const fitnessGoals = 'profile.fitness_goals';
  static const primaryGoal = 'profile.primary_goal';
  static const targetWeightKg = 'profile.target_weight_kg';
  static const notifications = 'profile.notifications';
  static const enabled = 'profile.enabled';
  static const disabled = 'profile.disabled';
  static const language = 'profile.language';
  static const selectLanguage = 'profile.select_language';
  static const logout = 'profile.logout';
  static const weightKg = 'profile.weight_kg';
  static const years = 'profile.years';
  static const cm = 'profile.cm';

  // Goals
  static const loseWeight = 'goals.lose_weight';
  static const gainMuscle = 'goals.gain_muscle';
  static const maintainWeight = 'goals.maintain_weight';
  static const improveEndurance = 'goals.improve_endurance';

  // Workout
  static const todaysWorkout = 'workout.todays_workout';
  static const workoutPlan = 'workout.workout_plan';
  static const exercises = 'workout.exercises';
  static const startWorkout = 'workout.start_workout';
  static const completeWorkout = 'workout.complete_workout';
  static const workoutHistory = 'workout.workout_history';

  // Nutrition
  static const nutrition = 'nutrition.nutrition';
  static const addMeal = 'nutrition.add_meal';
  static const breakfast = 'nutrition.breakfast';
  static const lunch = 'nutrition.lunch';
  static const dinner = 'nutrition.dinner';
  static const snacks = 'nutrition.snacks';
  static const calories = 'nutrition.calories';
  static const protein = 'nutrition.protein';
  static const carbs = 'nutrition.carbs';
  static const fat = 'nutrition.fat';

  // Progress
  static const progress = 'progress.progress';
  static const weightProgress = 'progress.weight_progress';
  static const burnHistory = 'progress.burn_history';

  // Onboarding
  static const welcome = 'onboarding.welcome';
  static const getStarted = 'onboarding.get_started';
  static const next = 'onboarding.next';
  static const back = 'onboarding.back';

  // Auth
  static const signIn = 'auth.sign_in';
  static const signUp = 'auth.sign_up';
  static const email = 'auth.email';
  static const password = 'auth.password';
}

/// Helper functions for common localization patterns
class LocalizationHelper {
  /// Format weight with unit
  static String formatWeight(BuildContext context, double weight) {
    return '${weight.toStringAsFixed(1)} ${context.l10n.getString(TranslationKeys.weightKg)}';
  }

  /// Format age with unit
  static String formatAge(BuildContext context, int age) {
    return '$age ${context.l10n.getString(TranslationKeys.years)}';
  }

  /// Format height with unit
  static String formatHeight(BuildContext context, double height) {
    return '${height.toStringAsFixed(1)} ${context.l10n.getString(TranslationKeys.cm)}';
  }

  /// Format calories
  static String formatCalories(BuildContext context, int calories) {
    return '$calories ${context.l10n.getString(TranslationKeys.calories)}';
  }

  /// Get goal translation
  static String getGoalTranslation(BuildContext context, String goalEnglish) {
    const goalMap = {
      'Lose Weight': TranslationKeys.loseWeight,
      'Gain Muscle': TranslationKeys.gainMuscle,
      'Maintain Weight': TranslationKeys.maintainWeight,
      'Improve Endurance': TranslationKeys.improveEndurance,
    };

    final key = goalMap[goalEnglish] ?? TranslationKeys.loseWeight;
    return context.l10n.getString(key);
  }

  /// Get meal type translation
  static String getMealTypeTranslation(BuildContext context, String mealType) {
    const mealMap = {
      'Breakfast': TranslationKeys.breakfast,
      'Lunch': TranslationKeys.lunch,
      'Dinner': TranslationKeys.dinner,
      'Snacks': TranslationKeys.snacks,
    };

    return context.l10n.getString(
      mealMap[mealType] ?? TranslationKeys.addMeal,
    );
  }
}
