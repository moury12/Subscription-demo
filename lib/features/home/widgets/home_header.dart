import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../utils/responsive.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.userName,
    required this.streakDays,
    required this.scale,
    super.key,
  });

  final String userName;
  final int streakDays;
  final DesignScale scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: scale.s(250.16),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(scale.s(AppSpacing.radiusXl)),
          bottomRight: Radius.circular(scale.s(AppSpacing.radiusXl)),
        ),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(96, 165, 250, 0.2), blurRadius: 64),
          BoxShadow(color: Color.fromRGBO(96, 165, 250, 0.4), blurRadius: 32, offset: Offset(0, 8)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.overlaySoft,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(scale.s(AppSpacing.radiusXl)),
            bottomRight: Radius.circular(scale.s(AppSpacing.radiusXl)),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(scale.s(24), scale.s(48), scale.s(24), scale.s(32)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning,',
                          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary90),
                        ),
                        Text(userName, style: AppTextStyles.h2),
                      ],
                    ),
                  ),
                  Container(
                    width: scale.s(44),
                    height: scale.s(44),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.overlayMedium,
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: scale.s(16)),
                height: scale.s(64),
                decoration: BoxDecoration(
                  color: AppColors.overlayMedium,
                  borderRadius: BorderRadius.circular(scale.s(AppSpacing.radiusLg)),
                  border: Border.all(color: AppColors.borderSoft, width: 1.1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: scale.s(48),
                      height: scale.s(48),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentOrange,
                        boxShadow: [
                          BoxShadow(color: Color.fromRGBO(251, 146, 60, 0.3), blurRadius: 48),
                          BoxShadow(color: Color.fromRGBO(251, 146, 60, 0.6), blurRadius: 24),
                        ],
                      ),
                      child: const Icon(Icons.local_fire_department, color: AppColors.textPrimary),
                    ),
                    SizedBox(width: scale.s(12)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$streakDays Day Streak', style: AppTextStyles.labelMedium),
                        Text('Keep it up! 🔥', style: AppTextStyles.label),
                      ],
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
