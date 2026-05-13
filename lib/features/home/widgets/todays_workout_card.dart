import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/app_settings.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/cards/app_surface_card.dart';
import '../../main/controllers/navigation_controller.dart';
import 'home_list_item.dart';

class TodaysWorkoutCard extends StatelessWidget {
  const TodaysWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();
    final plans = AppSettings().workoutPlans;
    String title = l10n.getString('home.rest_day_no_workout');

    if (plans.isNotEmpty) {
      final todayName = DateFormat('EEEE').format(DateTime.now());
      final plan = plans.first;
      for (final day in plan.days) {
        if (day.day.contains(todayName)) {
          title = day.isRestDay
              ? l10n.getString('home.rest_recovery_day')
              : '${day.title} - ${day.exercises.length} ${l10n.getString('workout.exercises')}';
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
            Text(l10n.getString('workout.todays_workout'), style: AppTextStyles.h3),
            const SizedBox(height: 16),
            HomeListItem(
              title: title,
              actionLabel: l10n.getString('home.view_workouts'),
              onTap: () => NavigationController().setIndex(1),
            ),
          ],
        ),
      ),
    );
  }
}
