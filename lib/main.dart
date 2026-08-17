import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gocal_ai/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'core/providers/language_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/screens/language_selection_screen.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();

  // অ্যাপ শুরুতেই কনফিগার করুন
  if (Platform.isAndroid) {
    await Purchases.configure(PurchasesConfiguration("goog_your_api_key_here"));
  } else if (Platform.isIOS) {
    await Purchases.configure(PurchasesConfiguration("appl_your_api_key_here"));
  }  await NotificationService().initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
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
