# Backend Integration Guide for Multilingual Support

## Overview

The Flutter app now sends language preference with all API requests. The backend should handle the `language` parameter to generate or translate AI content accordingly.

---

## API Request Format

### All POST/PUT Requests Now Include Language

**Format:**
```json
{
  // ... existing fields
  "language": "en|hi|fr|es"  // ← New field automatically added
}
```

**Supported Language Codes:**
- `en` - English
- `hi` - Hindi
- `fr` - French
- `es` - Spanish

---

## AI Content Generation Endpoints

### 1. Generate Workout

**Request:**
```json
POST /api/generate-workout
{
  "userId": "user_123",
  "goals": ["weight_loss"],
  "workoutDays": 3,
  "language": "hi"  // ← New
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "name": "आपका व्यक्तिगत कसरत योजना",  // In Hindi
    "description": "यह योजना आपके लक्ष्यों के लिए तैयार की गई है",
    "exercises": [
      {
        "name": "पुश-अप",  // In Hindi
        "description": "छाती और बाहों के लिए",
        "sets": 3,
        "reps": 10
      }
    ]
  }
}
```

### 2. Generate Meal Plan

**Request:**
```json
POST /api/generate-meal-plan
{
  "userId": "user_123",
  "goals": ["weight_loss"],
  "dietaryPreference": "vegetarian",
  "language": "fr"  // ← New
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "name": "Votre plan de repas personnalisé",  // In French
    "meals": [
      {
        "type": "breakfast",  // Keep in English
        "name": "Omelette aux légumes",  // In French
        "calories": 350
      }
    ]
  }
}
```

### 3. Generate Progress Report

**Request:**
```json
POST /api/generate-progress-report
{
  "userId": "user_123",
  "startDate": "2026-05-01",
  "endDate": "2026-05-13",
  "language": "es"  // ← New
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "summary": "¡Excelente progreso esta semana!",  // In Spanish
    "details": "Ha quemado 2,500 calorías",
    "tips": ["Continúe con el entrenamiento", "Beba más agua"]
  }
}
```

### 4. Analyze Food (AI Food Recognition)

**Request:**
```json
POST /api/analyze-food
{
  "userId": "user_123",
  "imageUrl": "https://...",
  "language": "hi"  // ← New
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "foodName": "चिकन सलाद",  // In Hindi
    "calories": 280,
    "macros": {
      "protein": "35g (प्रोटीन)",  // Can include translation
      "carbs": "15g (कार्ब्स)",
      "fat": "10g (वसा)"
    },
    "description": "स्वस्थ विकल्प"  // In Hindi
  }
}
```

---

## Implementation Strategies

### Strategy 1: Generate in Target Language
Use AI prompts in the target language:

```javascript
// Node.js/Express example
async function generateWorkout(userId, goals, language = 'en') {
  const languageNames = {
    en: 'English',
    hi: 'Hindi',
    fr: 'French',
    es: 'Spanish'
  };

  const prompt = `Generate a workout plan in ${languageNames[language]}...`;
  const workout = await aiService.generate(prompt);
  return workout;
}
```

### Strategy 2: Generate English, Then Translate
Generate content in English, then translate:

```javascript
async function generateAndTranslate(userId, goals, language = 'en') {
  // Generate in English
  const workoutEn = await generateWorkout(userId, goals, 'en');

  // Translate if not English
  if (language !== 'en') {
    const translated = await translationService.translate(
      workoutEn,
      'en',
      language
    );
    return translated;
  }

  return workoutEn;
}
```

### Strategy 3: Use Translation API
Cache translations for efficiency:

```javascript
async function getLocalizedContent(contentId, language = 'en') {
  // Check cache first
  const cached = await cache.get(`content:${contentId}:${language}`);
  if (cached) return cached;

  // Generate/translate
  let content = await getContent(contentId);
  if (language !== 'en') {
    content = await translate(content, language);
  }

  // Cache for future requests
  await cache.set(`content:${contentId}:${language}`, content, 3600);
  return content;
}
```

---

## Guidelines for Translations

### 1. **Key Fields to Translate**
- Exercise names and descriptions
- Meal names and descriptions
- Tips and recommendations
- Progress messages
- Error messages
- Success messages

### 2. **Fields to Keep in English** (Optional)
- Technical field names (stay consistent with API schema)
- Unit abbreviations (e.g., "kg", "cal")
- Date formats (standardize on ISO 8601)

### 3. **Numbers and Units**
```javascript
// Good - Translate units
const formatted = `${value} किग्रा`;  // Hindi: kg

// Better - Use separate fields
{
  "value": 75.5,
  "unit": "kg",  // Or "किग्रा" based on language
  "display": "75.5 किग्रा"
}
```

### 4. **Pluralization**
Different languages have different plural rules:
```javascript
// Instead of assuming English singular/plural
const meals = [
  { name: "Breakfast", count: 1 },
  { name: "Lunches", count: 3 }  // English assumes plural
];

// Better approach
{
  "meals": [
    { name: "breakfast", count: 1 },
    { name: "lunch", count: 3 }
  ],
  "display": "उपलब्ध: 1 नाश्ता, 3 दोपहर का भोजन"  // Hindi handling
}
```

---

## Testing the Integration

### 1. Test Each Language
```bash
# Test English
curl -X POST http://localhost:3000/api/generate-workout \
  -H "Content-Type: application/json" \
  -d '{"userId":"test","goals":["weight_loss"],"language":"en"}'

# Test Hindi
curl -X POST http://localhost:3000/api/generate-workout \
  -H "Content-Type: application/json" \
  -d '{"userId":"test","goals":["weight_loss"],"language":"hi"}'

# Test French and Spanish similarly
```

### 2. Verify Response Format
```javascript
// Each response should include translated content
{
  "success": true,
  "data": {
    "name": "...",  // Should be in target language
    "description": "...",  // Should be in target language
    "content": [...]  // All text should be localized
  }
}
```

### 3. Check Quality
- Verify translations are natural (not literal)
- Check formatting is correct for language
- Ensure unit translations match mobile app
- Test with long text (some languages take more space)

---

## Error Handling

### Unsupported Language
If a language is not supported:

```javascript
if (!['en', 'hi', 'fr', 'es'].includes(language)) {
  // Option 1: Default to English
  language = 'en';

  // Option 2: Return error
  return {
    success: false,
    error: "Language not supported",
    supportedLanguages: ['en', 'hi', 'fr', 'es']
  };
}
```

### Missing Translation
If translation service fails:

```javascript
try {
  const translated = await translationService.translate(content, language);
  return translated;
} catch (error) {
  // Fallback to English
  console.warn(`Translation failed for ${language}, using English`);
  return content;  // Return English content as fallback
}
```

---

## Database Considerations

### Store Original + Translations
```sql
-- Content table
CREATE TABLE content (
  id INT PRIMARY KEY,
  content_en TEXT,
  content_hi TEXT,
  content_fr TEXT,
  content_es TEXT,
  created_at TIMESTAMP
);

-- Query based on language
SELECT
  CASE 
    WHEN language = 'en' THEN content_en
    WHEN language = 'hi' THEN content_hi
    WHEN language = 'fr' THEN content_fr
    WHEN language = 'es' THEN content_es
    ELSE content_en
  END as content
FROM content
WHERE id = ?;
```

### Caching Strategy
```sql
-- Cache translations
CREATE TABLE translation_cache (
  id INT PRIMARY KEY,
  content_hash VARCHAR(64),
  language VARCHAR(2),
  translated_content TEXT,
  created_at TIMESTAMP,
  expires_at TIMESTAMP
);
```

---

## Recommended Translation Tools

### Option 1: Google Translate API
```javascript
const translate = require('@google-cloud/translate').v2;
const client = new translate.Translate();

async function translateContent(text, targetLanguage) {
  const [translation] = await client.translate(text, targetLanguage);
  return translation;
}
```

### Option 2: DeepL API (Higher Quality)
```javascript
const deepl = require('deepl-node');
const translator = new deepl.Translator(apiKey);

async function translateContent(text, targetLanguage) {
  const result = await translator.translateText(text, 'EN-US', targetLanguage);
  return result.text;
}
```

### Option 3: Manual Translations (Higher Control)
- Hire professional translators
- Maintain translation files in database
- More control over terminology
- Better for domain-specific content

---

## Performance Optimization

### Caching Strategy
```javascript
// Cache generated content by language
const cacheKey = `workout:${userId}:${language}:${hash(goals)}`;
const cached = await cache.get(cacheKey);

if (cached) {
  return cached;  // Return from cache
}

// Generate if not cached
const generated = await generateWorkout(userId, goals, language);
await cache.set(cacheKey, generated, 86400);  // Cache for 24 hours
return generated;
```

### Batch Translations
```javascript
// Translate multiple items at once (more efficient)
const items = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
const translations = await bulkTranslate(items, targetLanguage);
// Result: ['नाश्ता', 'दोपहर का भोजन', 'रात का भोजन', 'नाश्ते']
```

---

## Example Implementation (Node.js/Express)

```javascript
// middleware/languageMiddleware.js
module.exports = (req, res, next) => {
  // Ensure language is valid
  const language = req.body.language || 'en';
  if (!['en', 'hi', 'fr', 'es'].includes(language)) {
    req.body.language = 'en';
  }
  next();
};

// routes/ai.js
const express = require('express');
const router = express.Router();
const languageMiddleware = require('../middleware/languageMiddleware');

router.post('/generate-workout', languageMiddleware, async (req, res) => {
  try {
    const { userId, goals, language } = req.body;
    
    // Check cache
    const cacheKey = `workout:${userId}:${language}`;
    const cached = await cache.get(cacheKey);
    if (cached) {
      return res.json({ success: true, data: cached });
    }

    // Generate in target language
    const workout = await aiService.generateWorkout(
      userId,
      goals,
      language
    );

    // Cache result
    await cache.set(cacheKey, workout, 3600);

    res.json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

module.exports = router;
```

---

## Monitoring & Analytics

### Track Language Usage
```javascript
// Log language preferences
async function trackLanguageUsage(userId, language) {
  await db.insert('language_usage', {
    userId,
    language,
    timestamp: new Date(),
    endpoint: req.path
  });
}

// Analytics
SELECT language, COUNT(*) as usage_count
FROM language_usage
GROUP BY language
ORDER BY usage_count DESC;

// Result:
// en: 5000
// hi: 2800
// es: 1500
// fr: 800
```

---

## Rollout Plan

1. **Phase 1:** Test with single language (English)
2. **Phase 2:** Add Hindi support
3. **Phase 3:** Add French support
4. **Phase 4:** Add Spanish support
5. **Phase 5:** Monitor and optimize

---

## Support & Documentation

- **Frontend Implementation:** See `MULTILINGUAL_GUIDE.md`
- **Quick Reference:** See `QUICK_REFERENCE.md`
- **API Examples:** This document

For questions about backend multilingual support, refer to this guide.
