import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gocal_ai/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'core/providers/language_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/navigation_service.dart';
import 'features/onboarding/screens/language_selection_screen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  if (Platform.isAndroid) {
    await Purchases.configure(PurchasesConfiguration("goog_OWqKtkpAIdXrAEDNwDNNhidHOGc"));
  } else if (Platform.isIOS) {
    // If the user gets the iOS Public API Key, they can replace the placeholder here.
    await Purchases.configure(PurchasesConfiguration("appl_your_api_key_here"));
  }

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
            navigatorKey: NavigationService.navigatorKey,
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
