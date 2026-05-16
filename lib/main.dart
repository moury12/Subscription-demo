import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/language_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_scheduler.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/screens/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const GocalAiApp());
}

class GocalAiApp extends StatelessWidget {
  const GocalAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageProvider()..initialize(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: 'GoCal AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark.copyWith(
              textTheme: languageProvider.currentLanguage == 'hi'
                  ? AppTheme.dark.textTheme.apply(fontFamily: 'NotoSansDevanagari')
                  : AppTheme.dark.textTheme,
            ),
            builder: (context, child) {
              return GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: child!,
              );
            },
            home: const LanguageSelectionScreen(),
          );
        },
      ),
    );
  }
}
