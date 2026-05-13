import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() => _instance;

  LocalizationService._internal();

  late Map<String, dynamic> _translations = {};
  String _currentLanguage = 'en';

  final List<String> supportedLanguages = ['en', 'hi', 'fr', 'es'];
  final Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'Hindi',
    'fr': 'French',
    'es': 'Spanish',
  };

  String get currentLanguage => _currentLanguage;
  String get currentLanguageCode => _currentLanguage;
  String get currentLanguageName => languageNames[_currentLanguage] ?? 'English';

  /// Initialize localization with the given language code
  Future<void> initialize(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) {
      languageCode = 'en'; // Fallback to English
    }
    _currentLanguage = languageCode;
    await _loadLanguage(languageCode);
  }

  /// Load language JSON file from assets
  Future<void> _loadLanguage(String languageCode) async {
    try {
      // rootBundle.loadString already handles UTF-8 by default, but let's be explicit
      // if there are issues with local dev environments or asset encoding.
      final ByteData data = await rootBundle.load('assets/languages/$languageCode.json');
      final String jsonString = utf8.decode(data.buffer.asUint8List());
      _translations = json.decode(jsonString);
    } catch (e) {
      print('Error loading language file: $e');
      // Fallback to English if language file not found or corrupted
      if (languageCode != 'en') {
        await _loadLanguage('en');
      }
    }
  }

  /// Change the current language
  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) {
      return;
    }
    if (_currentLanguage == languageCode) {
      return;
    }
    _currentLanguage = languageCode;
    await _loadLanguage(languageCode);
  }

  /// Get translated string by key (supports nested keys like "profile.full_name")
  String getString(String key) {
    final keys = key.split('.');
    dynamic value = _translations;

    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        // Return key itself if translation not found
        return key;
      }
    }

    return value.toString();
  }

  /// Get translated string with parameters
  String getStringWithParams(String key, Map<String, String> params) {
    String result = getString(key);
    params.forEach((paramKey, paramValue) {
      result = result.replaceAll('{$paramKey}', paramValue);
    });
    return result;
  }

  /// Get nested translations (e.g., all "profile" strings)
  Map<String, dynamic>? getSection(String sectionKey) {
    if (_translations.containsKey(sectionKey)) {
      return _translations[sectionKey];
    }
    return null;
  }

  /// Check if a key exists in translations
  bool hasKey(String key) {
    final keys = key.split('.');
    dynamic value = _translations;

    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return false;
      }
    }

    return true;
  }

  /// Format number according to current locale with locale-specific digits and separators
  String formatNumber(num number, {int decimalPlaces = 2}) {
    final String pattern = number.toStringAsFixed(decimalPlaces);
    
    switch (_currentLanguage) {
      case 'hi': // Hindi - Convert to Devanagari numerals
        return _convertToDevanagari(pattern);
      case 'en': // English
      case 'es': // Spanish
      case 'fr': // French
      default:
        return pattern;
    }
  }

  /// Format integer number according to current locale
  String formatInteger(int number) {
    final String pattern = number.toString();
    
    switch (_currentLanguage) {
      case 'hi': // Hindi - Convert to Devanagari numerals
        return _convertToDevanagari(pattern);
      case 'en': // English
      case 'es': // Spanish
      case 'fr': // French
      default:
        return pattern;
    }
  }

  /// Convert Western digits to Devanagari numerals for Hindi
  String _convertToDevanagari(String number) {
    const Map<String, String> devanagariMap = {
      '0': '०',
      '1': '१',
      '2': '२',
      '3': '३',
      '4': '४',
      '5': '५',
      '6': '६',
      '7': '७',
      '8': '८',
      '9': '९',
      '.': '.',
      '-': '-',
    };

    return number.split('').map((char) => devanagariMap[char] ?? char).join('');
  }

  /// Format calories with localized number
  String formatCalories(num calories) => '${formatInteger(calories.toInt())}';

  /// Format weight with localized number
  String formatWeight(num weight, {int decimalPlaces = 1}) => 
      formatNumber(weight, decimalPlaces: decimalPlaces);

  /// Format percentage with localized number
  String formatPercentage(num percentage) => '${formatInteger(percentage.toInt())}%';

  /// Format macros (protein, carbs, fat) with localized number
  String formatMacro(num macro) => '${formatInteger(macro.toInt())}g';

  /// Format date (e.g., "Monday, May 13") using localized days and months
  String formatDate(DateTime date) {
    // Ensure we use lowercase keys for the JSON lookup as defined in assets
    final weekDayName = _getWeekdayName(date.weekday).toLowerCase();
    final monthNameKey = _getMonthName(date.month).toLowerCase();
    
    final dayName = getString('days.$weekDayName');
    final monthName = getString('months.$monthNameKey');
    final day = formatInteger(date.day);
    
    // Format: "बुधवार, मई १३"
    return translateDigits('$dayName, $monthName $day');
  }

  String _getWeekdayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Localize any string containing Western digits (like dates, times)
  String translateDigits(String text) {
    if (_currentLanguage == 'hi') {
      return _convertToDevanagari(text);
    }
    return text;
  }

  /// Get all translations (for debugging)
  Map<String, dynamic> getAllTranslations() => _translations;
}
