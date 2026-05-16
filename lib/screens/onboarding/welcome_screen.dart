import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/branding/gradient_logo.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/onboarding/onboarding_background.dart';

import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const WelcomeScreen({super.key, required this.onStart, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    
    return Scaffold(
      body: OnboardingBackground(
        child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    lp.getString('onboarding.skip'),
                    style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const GradientLogo(size: 100),
              const SizedBox(height: 32),
              Text(
                lp.getString('onboarding.welcome_title'),
                style: AppTextStyles.splashTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                lp.getString('onboarding.welcome_subtitle'),
                style: AppTextStyles.splashSubtitle.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildFeatureItem(
                context,
                icon: Icons.track_changes,
                title: lp.getString('onboarding.feature1_title'),
                subtitle: lp.getString('onboarding.feature1_subtitle'),
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                context,
                icon: Icons.trending_up,
                title: lp.getString('onboarding.feature2_title'),
                subtitle: lp.getString('onboarding.feature2_subtitle'),
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                context,
                icon: Icons.bolt,
                title: lp.getString('onboarding.feature3_title'),
                subtitle: lp.getString('onboarding.feature3_subtitle'),
              ),
              const SizedBox(height: 64),
              PrimaryGlowButton(
                label: lp.getString('onboarding.get_started'),
                onPressed: onStart,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context,
      {required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
