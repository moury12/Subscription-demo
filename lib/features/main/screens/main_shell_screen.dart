import 'package:flutter/material.dart';
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

  Future<bool> _handleBackPress() async {
    if (_navController.currentIndex != 0) {
      _navController.setIndex(0);
      _lastPressedAt = null;
      return false;
    }

    final now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      final l10n = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.getString('common.press_back_to_exit'),
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.accentBlue,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
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
