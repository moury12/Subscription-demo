import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <({IconData icon, String label})>[
      (icon: Icons.dashboard_outlined, label: 'Dashboard'),
      (icon: Icons.fitness_center, label: 'Workout'),
      (icon: Icons.restaurant_menu_outlined, label: 'Nutrition'),
      (icon: Icons.show_chart, label: 'Progress'),
      (icon: Icons.person_outline, label: 'Profile'),
    ];

    return Container(
      height: 73.1,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderSoft, width: 1.1)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _NavItem(
                icon: items[i].icon,
                label: items[i].label,
                selected: i == selectedIndex,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? AppColors.textPrimary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 63.99,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              Positioned(
                top: 0,
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.accentBlue,
                    boxShadow: [
                      BoxShadow(color: Color.fromRGBO(96, 165, 250, 0.5), blurRadius: 32),
                      BoxShadow(color: Color.fromRGBO(96, 165, 250, 1), blurRadius: 16),
                    ],
                  ),
                ),
              ),
            if (selected)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Color.fromRGBO(96, 165, 250, 0.08), Color.fromRGBO(0, 0, 0, 0)],
                      stops: [0, 0.7],
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: textColor),
                const SizedBox(height: 2),
                Text(label, style: AppTextStyles.caption.copyWith(color: textColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
