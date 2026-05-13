import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';

class LanguageProvider extends ChangeNotifier {
  late final LocalizationService _localizationService;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;
  String get currentLanguageName =>
      _localizationService.languageNames[_currentLanguage] ?? 'English';
  bool get isInitialized => _isInitialized;
  LocalizationService get localizationService => _localizationService;

  /// Initialize the language provider
  Future<void> initialize() async {
    _localizationService = LocalizationService();
    _prefs = await SharedPreferences.getInstance();

    // Load saved language preference or use default
    _currentLanguage = _prefs.getString('app_language') ?? 'en';

    // Initialize localization service with current language
    await _localizationService.initialize(_currentLanguage);
    _isInitialized = true;
    notifyListeners();
  }

  /// Change the app language and save preference
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) {
      return;
    }

    if (!_localizationService.supportedLanguages.contains(languageCode)) {
      return;
    }

    _currentLanguage = languageCode;

    // Save to preferences
    await _prefs.setString('app_language', languageCode);

    // Update localization service
    await _localizationService.setLanguage(languageCode);

    notifyListeners();
  }

  /// Get translated string
  String getString(String key) => _localizationService.getString(key);

  /// Get translated string with parameters
  String getStringWithParams(String key, Map<String, String> params) =>
      _localizationService.getStringWithParams(key, params);

  /// Get a section of translations
  Map<String, dynamic>? getSection(String sectionKey) =>
      _localizationService.getSection(sectionKey);

  /// Get all supported languages
  List<String> getSupportedLanguages() =>
      _localizationService.supportedLanguages;

  /// Get language name by code
  String getLanguageName(String languageCode) =>
      _localizationService.languageNames[languageCode] ?? languageCode;
}
