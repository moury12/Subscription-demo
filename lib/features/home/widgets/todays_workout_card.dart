import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_settings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/cards/app_surface_card.dart';
import '../../main/controllers/navigation_controller.dart';
import 'home_list_item.dart';

class TodaysWorkoutCard extends StatelessWidget {
  const TodaysWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = AppSettings().workoutPlans;
    String title = 'Rest day or no workout scheduled';

    if (plans.isNotEmpty) {
      final todayName = DateFormat('EEEE').format(DateTime.now());
      final plan = plans.first;
      for (final day in plan.days) {
        if (day.day.contains(todayName)) {
          title = day.isRestDay
              ? 'Rest & Recovery day'
              : '${day.title} - ${day.exercises.length} exercises';
          break;
        }
      }
    }

    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(17.1, 17.1, 17.1, 1.1),
      child: SizedBox(
        height: 145,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s Workout', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            HomeListItem(
              title: title,
              actionLabel: 'View Workouts →',
              onTap: () => NavigationController().setIndex(1),
            ),
          ],
        ),
      ),
    );
  }
}
