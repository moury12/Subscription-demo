import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeListItem extends StatelessWidget {
  const HomeListItem({
    required this.title,
    required this.actionLabel,
    this.onTap,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary90)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(actionLabel, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
