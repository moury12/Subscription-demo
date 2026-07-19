import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../../nutrition/screens/nutrition_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../workout/screens/workout_screen.dart';

import '../controllers/navigation_controller.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final NavigationController _navController = NavigationController();
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _navController.addListener(_updateIndex);
  }

  @override
  void dispose() {
    _navController.removeListener(_updateIndex);
    super.dispose();
  }

  void _updateIndex() {
    if (mounted) setState(() {});
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    WorkoutScreen(),
    NutritionScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // 1. If user is in any tab other than Dashboard (index != 0), route to Dashboard first
        if (_navController.currentIndex != 0) {
          _navController.setIndex(0);
          _lastPressedAt = null;
          return;
        }

        // 2. If user is at Dashboard screen, require 2 back presses to exit
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          final l10n = Provider.of<LanguageProvider>(context, listen: false);

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.getString('common.press_back_to_exit'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.accentGreen.withValues(alpha: 0.5), width: 1.5),
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            ),
          );
          return;
        }

        // 3. User pressed back twice within 2s on Dashboard -> Close the app
        await SystemNavigator.pop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(index: _navController.currentIndex, children: _screens),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: HomeBottomNav(
                selectedIndex: _navController.currentIndex,
                onTap: (value) => _navController.setIndex(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
