import 'package:flutter/material.dart';

import '../../home/screens/home_screen.dart';
import '../../home/widgets/home_bottom_nav.dart';
import '../../nutrition/screens/nutrition_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../workout/screens/workout_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

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
            child: IndexedStack(index: _index, children: _screens),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: HomeBottomNav(
              selectedIndex: _index,
              onTap: (value) => setState(() => _index = value),
            ),
          ),
        ],
      ),
    );
  }
}
