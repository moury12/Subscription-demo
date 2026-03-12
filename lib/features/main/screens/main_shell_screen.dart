import 'package:flutter/material.dart';

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
    return Scaffold(
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
    );
  }
}
