import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/branding/gradient_logo.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../widgets/auth_scaffold.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.watch<LanguageProvider>();
    return AuthScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            const GradientLogo(size: 100),
            const SizedBox(height: 32),
            Text(
              l.getString('join_gocal_today'),
              style: AppTextStyles.authTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l.getString('fitness_goals_subtitle'),
              style: AppTextStyles.authSubtitle.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            PrimaryGlowButton(
              label: l.getString('sign_in_upper'),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignInScreen()));
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()));
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.textPrimary.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l.getString('create_account_upper'), style: AppTextStyles.buttonLabel),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
