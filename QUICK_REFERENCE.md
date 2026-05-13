# 🌐 Multilingual Quick Reference

## Using Translations in Your Code

### Basic Usage
```dart
import 'package:flutter/material.dart';

// In any Widget with BuildContext:
Text(context.l10n.getString('profile.full_name'))
```

### With Type Safety
```dart
import 'context.l10n.getString(TranslationKeys.fullName)
```

### With Parameters
```dart
String greeting = context.l10n.getStringWithParams(
  'greeting',
  {'name': 'Ahmed', 'time': 'morning'}
);
```

### Using Helper Methods
```dart
// Format weight with unit
Text(LocalizationHelper.formatWeight(context, 75.5))
// Output: "75.5 kg" or "75.5 किग्रा" in Hindi

// Format age with unit
Text(LocalizationHelper.formatAge(context, 25))
// Output: "25 years" or "25 साल" in Hindi

// Get translated goal
Text(LocalizationHelper.getGoalTranslation(context, 'Lose Weight'))
// Output: "Lose Weight" or "वजन कम करें" in Hindi
```

---

## Translation Key Reference

### Profile Section
```dart
TranslationKeys.personalInformation    // "Personal Information"
TranslationKeys.fullName               // "Full Name"
TranslationKeys.age                    // "Age"
TranslationKeys.heightCm               // "Height (cm)"
TranslationKeys.currentWeight          // "Current Weight"
TranslationKeys.fitnessGoals           // "Fitness Goals"
TranslationKeys.targetWeightKg         // "Target Weight (kg)"
TranslationKeys.notifications          // "Notifications"
TranslationKeys.language               // "Language"
TranslationKeys.logout                 // "Logout"
```

### Workout Section
```dart
TranslationKeys.todaysWorkout          // "Today's Workout"
TranslationKeys.workoutPlan            // "Workout Plan"
TranslationKeys.exercises              // "Exercises"
TranslationKeys.startWorkout           // "Start Workout"
TranslationKeys.workoutHistory         // "Workout History"
```

### Nutrition Section
```dart
TranslationKeys.nutrition              // "Nutrition"
TranslationKeys.addMeal                // "Add Meal"
TranslationKeys.breakfast              // "Breakfast"
TranslationKeys.lunch                  // "Lunch"
TranslationKeys.dinner                 // "Dinner"
TranslationKeys.calories               // "Calories"
TranslationKeys.protein                // "Protein"
```

### Goals Section
```dart
TranslationKeys.loseWeight             // "Lose Weight"
TranslationKeys.gainMuscle             // "Gain Muscle"
TranslationKeys.maintainWeight         // "Maintain Weight"
TranslationKeys.improveEndurance       // "Improve Endurance"
```

---

## Adding New Translations

### 1. Add to JSON Files
Edit `assets/languages/en.json`:
```json
{
  "new_section": {
    "new_key": "English text"
  }
}
```

Then translate in `hi.json`, `fr.json`, `es.json`:
```json
{
  "new_section": {
    "new_key": "हिंदी पाठ"
  }
}
```

### 2. Add to TranslationKeys (Optional)
```dart
class TranslationKeys {
  static const newSectionNewKey = 'new_section.new_key';
}
```

### 3. Use in Widget
```dart
Text(context.l10n.getString(TranslationKeys.newSectionNewKey))
```

---

## Accessing Current Language

```dart
// Get current language code
String langCode = context.read<LanguageProvider>().currentLanguage;
// Returns: 'en', 'hi', 'fr', or 'es'

// Get current language name
String langName = context.read<LanguageProvider>().currentLanguageName;
// Returns: 'English', 'Hindi', 'French', or 'Spanish'
```

---

## Changing Language Programmatically

```dart
// Change language to Hindi
await context.read<LanguageProvider>().setLanguage('hi');

// Change language to Spanish
await context.read<LanguageProvider>().setLanguage('es');

// The entire app updates automatically
```

---

## Complete Example: Displaying User Info

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInfoWidget extends StatelessWidget {
  final String name;
  final int age;
  final double weight;
  final String goal;

  const UserInfoWidget({
    required this.name,
    required this.age,
    required this.weight,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Full Name
        Text(context.l10n.getString(TranslationKeys.fullName)),
        Text(name),
        SizedBox(height: 8),

        // Age with unit
        Text(context.l10n.getString(TranslationKeys.age)),
        Text(LocalizationHelper.formatAge(context, age)),
        SizedBox(height: 8),

        // Weight with unit
        Text(context.l10n.getString(TranslationKeys.currentWeight)),
        Text(LocalizationHelper.formatWeight(context, weight)),
        SizedBox(height: 8),

        // Goal (translated)
        Text(context.l10n.getString(TranslationKeys.primaryGoal)),
        Text(LocalizationHelper.getGoalTranslation(context, goal)),
      ],
    );
  }
}
```

---

## Reactive Language Changes

Use `Consumer` to rebuild when language changes:

```dart
Consumer<LanguageProvider>(
  builder: (context, languageProvider, _) {
    return Text(context.l10n.getString('profile.language'));
    // This widget rebuilds whenever language changes
  },
)
```

---

## API Usage

All API requests automatically include language:

```dart
// This request will automatically include:
// { "language": "hi" } when sent
ApiService().post(
  '/api/generate-workout',
  {'userId': '123', 'goals': ['weight_loss']}
);

// Result: Backend receives:
// {
//   "userId": "123",
//   "goals": ["weight_loss"],
//   "language": "hi"
// }
```

---

## Supported Languages

| Code | Name | Flag |
|------|------|------|
| en | English | 🇺🇸 |
| hi | Hindi | 🇮🇳 |
| fr | French | 🇫🇷 |
| es | Spanish | 🇪🇸 |

---

## Common Patterns

### Check if Translation Exists
```dart
bool hasKey = context.l10n.localizationService.hasKey('profile.full_name');
```

### Get All Translations in Section
```dart
Map<String, dynamic>? profileStrings = 
  context.l10n.getSection('profile');
```

### Fallback to English
```dart
// Automatic: If translation missing, returns the key itself
Text(context.l10n.getString('non.existent.key'))
// Shows: "non.existent.key" as fallback
```

### Custom Formatting
```dart
String formatted = context.l10n.localizationService.formatNumber(
  1234.56,
  decimalPlaces: 2
);
```

---

## File Locations

```
assets/
└── languages/
    ├── en.json
    ├── hi.json
    ├── fr.json
    └── es.json

lib/
├── core/
│   ├── services/
│   │   ├── localization_service.dart
│   │   └── api_service.dart (updated)
│   ├── providers/
│   │   └── language_provider.dart
│   └── localization/
│       └── localization_helpers.dart
└── main.dart (updated)
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "key" displays instead of text | Check JSON file has the key |
| Language doesn't persist | Ensure LanguageProvider.initialize() called in main |
| UI doesn't update on language change | Wrap widget with Consumer<LanguageProvider> |
| Import error for `context.l10n` | Add `import 'localization_helpers.dart'` |
| Missing Provider error | Ensure MultiProvider setup in main.dart |

---

**For detailed documentation, see:** `MULTILINGUAL_GUIDE.md`
**For overview, see:** `IMPLEMENTATION_SUMMARY.md`
