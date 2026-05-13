# Multilingual Implementation Guide

## Overview
The GoCal AI app now supports 4 languages:
- English (en) - Default
- Hindi (hi)
- French (fr)
- Spanish (es)

## Core Components

### 1. **LocalizationService** (`lib/core/services/localization_service.dart`)
Handles loading and retrieving translations from JSON files.

**Key Methods:**
- `initialize(String languageCode)` - Initialize with language
- `setLanguage(String languageCode)` - Change language
- `getString(String key)` - Get translated string (e.g., "profile.full_name")
- `getStringWithParams(String key, Map params)` - Get string with parameter substitution

### 2. **LanguageProvider** (`lib/core/providers/language_provider.dart`)
State management for language using ChangeNotifier + Provider.

**Key Methods:**
- `initialize()` - Load saved language preference from shared_preferences
- `setLanguage(String code)` - Change language and save to preferences
- `getString(String key)` - Access translations

### 3. **Localization Helpers** (`lib/core/localization/localization_helpers.dart`)
Utility extension and constants for easy access throughout the app.

**Usage:**
```dart
// Access in any widget with BuildContext
Text(context.l10n.getString(TranslationKeys.fullName))
```

### 4. **Language Files** (`assets/languages/`)
- `en.json` - English translations
- `hi.json` - Hindi translations
- `fr.json` - French translations
- `es.json` - Spanish translations

## How to Use in Your App

### Step 1: Add Provider Import
```dart
import 'package:provider/provider.dart';
import 'context.l10n.getString('profile.full_name')
```

### Step 2: Get Translations
```dart
// Simple string
Text(context.l10n.getString('profile.full_name'))

// With parameters
Text(context.l10n.getStringWithParams(
  'greeting',
  {'name': 'Ahmed'}
))

// Using TranslationKeys constant (type-safe)
Text(context.l10n.getString(TranslationKeys.fullName))

// With LocalizationHelper
Text(LocalizationHelper.formatWeight(context, 75.5))
```

### Step 3: React to Language Changes
```dart
// The UI automatically updates when language changes
Consumer<LanguageProvider>(
  builder: (context, languageProvider, _) {
    return Text(context.l10n.getString('profile.language'));
  },
)
```

## Implementation in Different Screens

### Profile Screen (Already Updated)
The profile screen's language selection is already integrated. When users select a language:
1. The selection is saved to `shared_preferences` via `LanguageProvider`
2. All UI text automatically updates
3. The language preference persists across app restarts

### Other Screens

To add translations to other screens:

**Option 1: Update all strings at once**
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.getString('dashboard.home')),
      ),
      body: Column(
        children: [
          Text(context.l10n.getString('workout.todays_workout')),
          Text(context.l10n.getString('nutrition.nutrition')),
          Text(context.l10n.getString('progress.progress')),
        ],
      ),
    );
  }
}
```

**Option 2: Gradual migration (backward compatible)**
```dart
// Old approach (still works)
Text('Old hardcoded text')

// New approach
Text(context.l10n.getString('key'))

// You can mix both during migration
```

## Adding New Translations

### 1. Add to JSON Files
In `assets/languages/en.json`:
```json
{
  "myfeature": {
    "button_text": "Click Me",
    "description": "This is a description"
  }
}
```

Apply the same keys to `hi.json`, `fr.json`, and `es.json` with translated values.

### 2. Add TranslationKey (Optional)
In `localization_helpers.dart`:
```dart
static const myFeatureButtonText = 'myfeature.button_text';
static const myFeatureDescription = 'myfeature.description';
```

### 3. Use in Your Widget
```dart
Text(context.l10n.getString(TranslationKeys.myFeatureButtonText))
```

## AI-Generated Content Translation

The API service now automatically includes the user's language preference in all requests:

```dart
// Before (English only)
POST /api/generate-workout
{
  "userId": "123",
  "goals": ["weight_loss"]
}

// After (Language-aware)
POST /api/generate-workout
{
  "userId": "123",
  "goals": ["weight_loss"],
  "language": "hi"  // ← Automatically added
}
```

Backend should handle the `language` parameter to:
- Generate AI content in the target language
- Translate existing English content if needed
- Fall back to English if translation unavailable

## Number & Date Formatting

Future enhancements can use the `intl` package (already in dependencies) for locale-aware formatting:

```dart
// Example for future implementation
import 'package:intl/intl.dart';

// Format number for current locale
final formatter = NumberFormat("#,##0.00", _getLocaleCode(languageCode));
final formatted = formatter.format(123.456); // "123.46"

// Format date for current locale
final dateFormatter = DateFormat('dd/MM/yyyy', _getLocaleCode(languageCode));
final formatted = dateFormatter.format(DateTime.now());
```

## Testing Multilingual Features

1. **Language Persistence Test**
   - Select Spanish
   - Close and reopen app
   - Verify Spanish is still selected

2. **Translation Completeness Test**
   - Check all 4 languages display text correctly
   - Verify no keys show the key name (fallback)

3. **AI Content Test**
   - Generate workout/meal plan in different languages
   - Verify backend receives language parameter

4. **Layout Test**
   - Some languages (Hindi) take more space
   - Verify UI doesn't break with long text

## Current Status

✅ **Implemented:**
- JSON language files (en, hi, fr, es)
- LocalizationService with caching
- LanguageProvider with state management
- Language persistence (shared_preferences)
- Profile screen language selector
- API service language support
- Localization helpers and constants

⏳ **Recommended Next Steps:**
1. Update all screen strings to use localization keys
2. Test language switching on all screens
3. Backend implementation for AI content translation
4. Add date/number formatting for each locale
5. Consider RTL support if needed

## Troubleshooting

**Issue: "Key" displayed instead of translation**
- Solution: Check JSON file has the key under correct section
- Check spelling matches exactly (case-sensitive)

**Issue: Language doesn't persist after app restart**
- Solution: Ensure LanguageProvider.initialize() is called in main.dart
- Check shared_preferences is working (happens after first init)

**Issue: Missing translation in one language**
- Solution: Ensure all 4 JSON files have identical key structure
- Fill missing values with English translation as temporary fix

**Issue: UI doesn't update when language changes**
- Solution: Wrap widget with Consumer<LanguageProvider>
- Or use context.l10n.getString() which rebuilds automatically

## API Integration Example

Backend endpoint should handle language parameter:

```javascript
// Node.js/Express example
app.post('/api/generate-workout', async (req, res) => {
  const { userId, goals, language = 'en' } = req.body;
  
  // Use language in AI prompt
  const prompt = `Generate a workout plan in ${language}...`;
  
  // Or translate after generation
  const workoutPlan = await generateWorkout(userId, goals);
  const translatedPlan = await translateContent(workoutPlan, language);
  
  res.json(translatedPlan);
});
```

## Future Enhancements

1. **More Languages** - Add German, Portuguese, etc. following same pattern
2. **RTL Support** - For Arabic, Hebrew if needed
3. **Pluralization** - Handle singular/plural forms
4. **Date/Number Formatting** - Use intl package for locale-aware formatting
5. **Translation Management** - Consider using services like Crowdin or Firebase Remote Config for easier management
6. **Language Auto-Detection** - Detect device locale and set language automatically

---

**For Questions or Issues:** Check the TranslationKeys class for available keys or add new ones as needed.
