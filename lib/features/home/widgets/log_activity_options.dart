import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../nutrition/widgets/meal_logging_options.dart';
import '../../main/controllers/navigation_controller.dart';
import '../../../core/providers/language_provider.dart';
import 'burn_log_popup.dart';

class LogActivityOptions extends StatelessWidget {
  const LogActivityOptions({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LogActivityOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.getString('home.log_activity_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Playfair Display', // Using an elegant font as per UI
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildOption(
            context,
            icon: Icons.restaurant_menu,
            iconColor: const Color(0xFF34D399),
            title: l10n.getString('home.log_a_meal'),
            subtitle: l10n.getString('home.log_a_meal_desc'),
            onTap: () {
              Navigator.pop(context);
              MealLoggingOptions.showAddOptions(context);
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.fitness_center,
            iconColor: const Color(0xFF60A5FA),
            title: l10n.getString('home.start_workout'),
            subtitle: l10n.getString('home.start_workout_desc'),
            onTap: () {
              Navigator.pop(context);
              NavigationController().setIndex(1); // Workout tab
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFFB923C),
            title: l10n.getString('home.burn_activity'),
            subtitle: l10n.getString('home.burn_activity_desc'),
            onTap: () {
              Navigator.pop(context);
              BurnLogPopup.show(context);
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: Icons.scale_outlined,
            iconColor: const Color(0xFFA78BFA),
            title: l10n.getString('home.update_weight'),
            subtitle: l10n.getString('home.update_weight_desc'),
            onTap: () {
              Navigator.pop(context);
              NavigationController().setIndex(4); // Profile tab
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
