import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/cards/app_surface_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.md),
              const AppSurfaceCard(
                child: Row(
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: AppColors.brandPrimary, child: Icon(Icons.person, color: AppColors.background)),
                    SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jhon Deo', style: AppTextStyles.bodyMedium),
                        Text('Fitness Enthusiast', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppSurfaceCard(
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Profile Information', style: AppTextStyles.body),
                      trailing: Icon(Icons.chevron_right, color: AppColors.textPrimary90),
                    ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Workout Reminders', style: AppTextStyles.body),
                      trailing: Icon(Icons.chevron_right, color: AppColors.textPrimary90),
                    ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Logout', style: AppTextStyles.body),
                      trailing: Icon(Icons.logout, color: AppColors.textPrimary90),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
