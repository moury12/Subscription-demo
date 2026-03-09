import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/cards/app_surface_card.dart';
import 'home_list_item.dart';

class TodaysWorkoutCard extends StatelessWidget {
  const TodaysWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(17.1, 17.1, 17.1, 1.1),
      child: SizedBox(
        height: 145,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Today\'s Workout', style: AppTextStyles.h3),
            SizedBox(height: 16),
            HomeListItem(
              title: 'Rest day or no workout scheduled',
              actionLabel: 'View Workouts →',
            ),
          ],
        ),
      ),
    );
  }
}
