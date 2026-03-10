import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../utils/responsive.dart';

class HomeHeader extends StatefulWidget {
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
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final dateStr = DateFormat('EEEE, MMMM d,').format(_currentTime);
    final timeStr = DateFormat('hh:mm a').format(_currentTime);

    return Container(
      height: scale.s(260.16),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(scale.s(AppSpacing.radiusXl)),
          bottomRight: Radius.circular(scale.s(AppSpacing.radiusXl)),
        ),
        boxShadow: [
          BoxShadow(color: const Color.fromRGBO(96, 165, 250, 0.2), blurRadius: scale.s(64)),
          BoxShadow(color: const Color.fromRGBO(96, 165, 250, 0.4), blurRadius: scale.s(32), offset: const Offset(0, 8)),
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
          padding: EdgeInsets.fromLTRB(scale.s(24), scale.s(54), scale.s(24), scale.s(28)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning,',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary90,
                            fontSize: scale.s(16),
                          ),
                        ),
                        Text(
                          widget.userName,
                          style: AppTextStyles.h2.copyWith(fontSize: scale.s(22)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: AppColors.textPrimary90,
                          fontSize: scale.s(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: scale.s(20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: scale.s(40),
                    height: scale.s(40),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.overlayMedium,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: scale.s(16)),
                height: scale.s(80),
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
                    SizedBox(width: scale.s(16)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.streakDays} Day Streak', style: AppTextStyles.h3.copyWith(fontSize: scale.s(18))),
                        Text('Keep it up! 🔥', style: AppTextStyles.body.copyWith(fontSize: scale.s(14))),
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
