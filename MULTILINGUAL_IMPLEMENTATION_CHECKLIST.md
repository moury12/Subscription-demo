# Multilingual Persistence Implementation Checklist

## ✅ Code Changes Completed

### 1. ProfileService
- [x] Added `updateLanguagePreference(String languageCode)` method
  - Sends PUT request to `/user/profile` with language
  - Returns success/failure boolean
  
- [x] Added `getUserLanguagePreference()` method
  - Fetches from GET `/user/profile/language`
  - Returns language code string or null

### 2. AuthService
- [x] Enhanced `_fetchAndSyncProfile()` method
  - Checks for `language` field in profile response
  - Stores in SharedPreferences with key `'app_language'`
  - Loads language immediately after login

### 3. LanguageProvider
- [x] Added import for ProfileService
- [x] Updated `setLanguage()` method
  - Saves to local preferences
  - Calls backend to persist language
  - Includes error handling and warning logs
  
- [x] Added `_updateLanguageInBackend()` private method
  - Wraps ProfileService call
  - Handles errors gracefully

### 4. ProfileScreen
- [x] Modified language selection done button
  - Made async to wait for backend persistence
  - Calls LanguageProvider.setLanguage()
  - Maintains consistency with ProfileService update

## 🔧 Backend Requirements

### Database Schema
- [ ] Add `language` field to user profile table/document
  - Type: String
  - Nullable: Yes (defaults to 'en')
  - Example values: 'en', 'hi', 'fr', 'es'

### API Endpoints

#### PUT `/user/profile`
- [x] Already exists, needs to accept `language` field
- [ ] Backend implementation required
- [ ] Should return HTTP 200 on success

```json
// Request
{
  "language": "hi"
}

// Response
{
  "statusCode": 200,
  "message": "Profile updated successfully"
}
```

#### GET `/user/profile`
- [x] Already exists, needs to include `language` field
- [ ] Backend implementation required
- [ ] Should return user's current language preference

```json
// Response
{
  "id": "user_id",
  "email": "user@example.com",
  "language": "hi",
  ...other fields
}
```

#### GET `/user/profile/language` (Optional)
- [ ] New endpoint, retrieves language preference only
- [ ] Useful for client-side preflight checks
- [ ] Can be implemented later if needed

```json
// Response
{
  "language": "hi"
}
```

## 🧪 Testing Scenarios

### Scenario 1: Login with Saved Language
1. [ ] Admin sets user language to 'hi' in backend
2. [ ] User logs in
3. [ ] Verify: AppSettings receives language from backend
4. [ ] Verify: LanguageProvider initializes with 'hi'
5. [ ] Verify: UI renders in Hindi

### Scenario 2: Change Language and Persist
1. [ ] User logged in with 'en'
2. [ ] User opens Profile → Language section
3. [ ] User selects 'hi'
4. [ ] Verify: Backend receives PUT with language='hi' (HTTP 200)
5. [ ] Verify: Local SharedPreferences updated
6. [ ] Verify: UI immediately switches to Hindi

### Scenario 3: Persist Across Sessions
1. [ ] User language set to 'fr'
2. [ ] User logs out
3. [ ] User logs back in
4. [ ] Verify: Backend returns language='fr' in profile
5. [ ] Verify: UI loads in French
6. [ ] Verify: LanguageProvider.currentLanguage == 'fr'

### Scenario 4: Backend Failure Handling
1. [ ] Mock backend language update endpoint to fail
2. [ ] User tries to change language
3. [ ] Verify: Local preference is still updated
4. [ ] Verify: Warning is logged in console
5. [ ] Verify: UI switches language locally
6. [ ] Verify: App continues to function

### Scenario 5: New User Default Language
1. [ ] New user signs up without language preference set in backend
2. [ ] User logs in
3. [ ] Verify: Backend returns no language or null
4. [ ] Verify: AppSettings doesn't overwrite if null
5. [ ] Verify: LanguageProvider defaults to 'en'
6. [ ] Verify: User can select language and it saves

## 📱 Supported Languages

Current supported languages (must match LocalizationService):
- [x] English ('en') - Default
- [x] Hindi ('hi')
- [x] French ('fr')
- [x] Spanish ('es')

Backend should validate language code against this list.

## 🔐 Security Considerations

- [x] Language preference changes authenticated via existing token
- [x] No sensitive data in language field
- [x] All API calls use existing AuthService token mechanism
- [x] No new authentication required

## 📊 Data Flow Verification

### Login Flow
```
✓ User submits credentials
✓ AuthService.login() → backend auth
✓ Token saved to SharedPreferences
✓ AuthService._fetchAndSyncProfile() called
✓ GET /user/profile executed
✓ profileData['language'] extracted
✓ Stored in SharedPreferences['app_language']
✓ LanguageProvider.initialize() loads from SharedPreferences
✓ UI renders in correct language
```

### Change Language Flow
```
✓ User selects language in ProfileScreen
✓ onPressed calls setLanguage() (async)
✓ LocalizationService language updated
✓ _updateLanguageInBackend() called
✓ ProfileService.updateLanguagePreference() sends PUT
✓ Backend receives and validates language
✓ Backend updates user profile
✓ Response HTTP 200 received
✓ LanguageProvider notifies listeners
✓ UI refreshes with new language
```

## 🚀 Deployment Checklist

- [ ] All code changes reviewed and approved
- [ ] Backend language field added to schema
- [ ] Backend endpoints updated to support language
- [ ] Database migration completed (if applicable)
- [ ] Backend tests pass (language persistence tests)
- [ ] Integration tests pass (login/language flow)
- [ ] Backend deployed to staging
- [ ] Frontend builds without errors
- [ ] Frontend APK/iOS build successful
- [ ] QA testing on staging completed
- [ ] No regression issues found
- [ ] Documentation updated
- [ ] Deploy to production
- [ ] Monitor error logs for 24 hours
- [ ] Collect user feedback

## 📋 Troubleshooting

### Issue: Language not persisting after logout/login
**Solution:** Verify backend is returning `language` field in GET /user/profile response

### Issue: Backend update fails silently
**Solution:** Check console logs for "Warning: Failed to save language to backend" messages; verify backend endpoint is accessible

### Issue: UI doesn't switch language immediately
**Solution:** Verify `LanguageProvider.setLanguage()` is being called; check that notifyListeners() is triggered

### Issue: New users don't get default language
**Solution:** Ensure AuthService handles null language gracefully; LanguageProvider should default to 'en'

### Issue: Language field not saved in database
**Solution:** Verify backend migration was run; check user profile schema includes language field

---

**Implementation Date:** 2024
**Status:** Ready for Backend Integration
**Backward Compatibility:** ✅ Fully compatible
