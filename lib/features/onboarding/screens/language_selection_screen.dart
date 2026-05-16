import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import 'onboarding_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    // Supported languages with their display names and icons/flags
    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'hi', 'name': 'हिन्दी / Hindi', 'flag': '🇮🇳'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                Text(
                  'Select Language',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: You can change this later in Settings',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(flex: 1),
                ...languages.map((lang) {
                  final isSelected = languageProvider.currentLanguage == lang['code'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _LanguageButton(
                      name: lang['name']!,
                      flag: lang['flag']!,
                      isSelected: isSelected,
                      onTap: () async {
                        await languageProvider.setLanguage(lang['code']!);
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const OnboardingScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  );
                }),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String name;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.name,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.brandPrimary.withOpacity(0.2)
              : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isSelected 
                ? AppColors.brandPrimary 
                : AppColors.borderSoft,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.brandPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(
                  color: AppColors.borderSoft,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                flag,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.h3.copyWith(
                  color: isSelected ? AppColors.textPrimary : AppColors.textPrimary90,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.brandPrimary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
