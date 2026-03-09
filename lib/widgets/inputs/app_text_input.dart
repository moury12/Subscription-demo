import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppTextInput extends StatelessWidget {
  const AppTextInput({
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.svgIcon,
    this.obscureText = false,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final String? svgIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.inputHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.inputBorder, width: 1.1),
      ),
      child: Stack(
        children: [
          // Icon positioned absolutely like in Figma
          if (svgIcon != null)
            Positioned(
              left: AppSpacing.inputIconLeft,
              top: AppSpacing.inputIconTop,
              child: SvgPicture.asset(
                svgIcon!,
                width: AppSpacing.iconSize,
                height: AppSpacing.iconSize,
              ),
            )
          else if (prefixIcon != null)
            Positioned(
              left: AppSpacing.inputIconLeft,
              top: AppSpacing.inputIconTop,
              child: SizedBox(
                width: AppSpacing.iconSize,
                height: AppSpacing.iconSize,
                child: prefixIcon!,
              ),
            ),
          // Text field with exact padding
          Padding(
            padding: EdgeInsets.only(
              left: (svgIcon != null || prefixIcon != null)
                  ? AppSpacing.inputPaddingLeft
                  : 16,
              right: 16,
              top: 12,
              bottom: 12,
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                border: InputBorder.none,
                hintStyle:
                    AppTextStyles.inputText.copyWith(color: AppColors.textSecondary),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
