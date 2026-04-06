import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/nutrition_controller.dart';
import '../screens/add_meal_screen.dart';
import '../screens/ai_food_scan_screen.dart';

class MealLoggingOptions {
  static void showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddOptionsContent(context),
    );
  }

  static void showAddOptionsForMealType(BuildContext context, String mealType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddOptionsContent(context, mealType: mealType),
    );
  }

  static Widget _buildAddOptionsContent(BuildContext context, {String? mealType}) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Add Meal',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildOptionItem(
            context: context,
            icon: Icons.edit_note,
            title: 'Manual Entry',
            subtitle: 'Log your meal by searching or manually',
            onTap: () {
              Navigator.pop(context);
              if (mealType != null) {
                _openAddMeal(context, mealType);
              } else {
                showMealTimeSelection(context, isAiScan: false);
              }
            },
          ),
          const SizedBox(height: 16),
          _buildOptionItem(
            context: context,
            icon: Icons.camera_alt,
            title: 'AI Scan',
            subtitle: 'Scan your food for instant nutritional info',
            onTap: () {
              Navigator.pop(context);
              if (mealType != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AiFoodScanScreen(mealType: mealType)),
                );
              } else {
                showMealTimeSelection(context, isAiScan: true);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accentGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  static void showMealTimeSelection(BuildContext context, {required bool isAiScan}) {
    final mealTimes = [
      {'title': 'Breakfast', 'icon': Icons.coffee_rounded},
      {'title': 'Lunch', 'icon': Icons.wb_sunny_rounded},
      {'title': 'Dinner', 'icon': Icons.mode_night_rounded},
      {'title': 'Snack', 'icon': Icons.cookie_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Meal Time',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...mealTimes.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  if (isAiScan) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AiFoodScanScreen(mealType: meal['title'] as String)),
                    );
                  } else {
                    _openAddMeal(context, meal['title'] as String);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(5)),
                  ),
                  child: Row(
                    children: [
                      Icon(meal['icon'] as IconData, color: AppColors.accentGreen, size: 24),
                      const SizedBox(width: 16),
                      Text(
                        meal['title'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.white24),
                    ],
                  ),
                ),
              ),
            )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static void _openAddMeal(BuildContext context, String type) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => AddMealScreen(initialMealType: type)),
    );
    if (result != null && result['food'] != null) {
      NutritionController().addMeal(type, result['food'], result['multiplier'] ?? 1.0);
    }
  }
}
