import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';
import '../../features/profile/services/profile_service.dart';

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

    // Save to local preferences
    await _prefs.setString('app_language', languageCode);

    // Save to backend database
    final response = await _updateLanguageInBackend(languageCode);
    if (!response) {
      // If backend fails, at least keep local preference
      print('Warning: Failed to save language to backend');
    }

    // Update localization service
    await _localizationService.setLanguage(languageCode);

    notifyListeners();
  }

  /// Sync language from backend (called after login/sync)
  Future<void> syncLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    
    _currentLanguage = languageCode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
    await _localizationService.setLanguage(languageCode);
    notifyListeners();
  }

  Future<bool> _updateLanguageInBackend(String languageCode) async {
    try {
      return await ProfileService().updateLanguagePreference(languageCode);
    } catch (e) {
      return false;
    }
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

  /// Localization formatting utilities
  String formatNumber(num number, {int decimalPlaces = 2}) =>
      _localizationService.formatNumber(number, decimalPlaces: decimalPlaces);

  String formatInteger(int number) => _localizationService.formatInteger(number);

  String formatCalories(num calories) =>
      _localizationService.formatCalories(calories);

  String formatWeight(num weight, {int decimalPlaces = 1}) =>
      _localizationService.formatWeight(weight, decimalPlaces: decimalPlaces);

  String formatPercentage(num percentage) =>
      _localizationService.formatPercentage(percentage);

  String formatMacro(num macro) => _localizationService.formatMacro(macro);

  String translateDigits(String text) =>
      _localizationService.translateDigits(text);

  String formatDate(DateTime date) => _localizationService.formatDate(date);
}
