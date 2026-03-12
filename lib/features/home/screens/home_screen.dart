import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/responsive.dart';
import '../controllers/home_controller.dart';
import '../widgets/calorie_overview_card.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/todays_workout_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.showBottomNav = false,
    this.selectedIndex = 0,
    this.onTabSelected,
    super.key,
  });

  final bool showBottomNav;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = DesignScale.fromConstraints(constraints);
        final model = _controller.model;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(bottom: scale.s(90)),
                    child: Column(
                      children: [
                        HomeHeader(
                          userName: model.userName,
                          streakDays: model.streakDays,
                          scale: scale,
                        ),
                        SizedBox(height: scale.s(12.84)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: scale.s(AppSpacing.lg)),
                          child: Column(
                            children: [
                              CalorieOverviewCard(
                                consumed: model.consumedCalories,
                                target: model.targetCalories,
                                progress: model.caloriesProgress,
                              ),
                              SizedBox(height: scale.s(AppSpacing.md)),
                              const TodaysWorkoutCard(),
                              SizedBox(height: scale.s(AppSpacing.md)),
                              QuickStatsRow(
                                workouts: model.workoutsCompleted,
                                streak: model.dayStreak,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.showBottomNav)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: HomeBottomNav(
                      selectedIndex: widget.selectedIndex,
                      onTap: widget.onTabSelected ?? (_) {},
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
