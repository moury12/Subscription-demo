# Backend Integration - Language Persistence

## Quick Start for Backend Team

The Flutter app frontend is **complete and ready**. Backend needs to:

### **1. Database: Add Language Field** (5 minutes)

```sql
-- Add language column to users table
ALTER TABLE users ADD COLUMN language VARCHAR(2) DEFAULT 'en';

-- Optional: Add constraint
ALTER TABLE users ADD CONSTRAINT chk_language 
  CHECK (language IN ('en', 'hi', 'fr', 'es'));

-- Optional: Add index for performance
CREATE INDEX idx_user_language ON users(language);
```

### **2. API: Update User Profile Endpoint**

**Current behavior:**
```javascript
PUT /user/profile
{ "name": "Ahmed", "age": 25, ... }
```

**New behavior - Accept language:**
```javascript
PUT /user/profile
{ 
  "name": "Ahmed", 
  "age": 25,
  "language": "hi"    // ← New field
}

// In handler:
if (language && ['en', 'hi', 'fr', 'es'].includes(language)) {
  user.language = language;
}
await user.save();
```

### **3. API: Return Language in Profile Response**

**Current response:**
```json
{
  "id": "user_123",
  "name": "Ahmed",
  "email": "ahmed@email.com",
  "age": 25,
  ...
}
```

**New response - Include language:**
```json
{
  "id": "user_123",
  "name": "Ahmed",
  "email": "ahmed@email.com",
  "age": 25,
  "language": "hi",    // ← New field
  ...
}
```

### **4. API: Optional - Create Language Endpoint**

```javascript
// GET /user/profile/language
// Returns just the language
Response 200:
{
  "language": "hi"
}
```

---

## How Frontend Uses It

### **1. When User Changes Language**
```
App: PUT /user/profile { "language": "hi" }
Backend: Saves to database
App: Updates UI immediately
```

### **2. When User Logs In**
```
App: GET /user/profile
Backend: Returns user data + language field
App: Loads language automatically
App: Renders in user's preferred language
```

### **3. All AI Requests Include Language**
```
App: POST /api/generate-workout {
  "goals": ["weight_loss"],
  "language": "hi"    // ← Frontend sends this
}
Backend: Generate content in Hindi
```

---

## Implementation Examples

### **Node.js/Express**

```javascript
// Add language to user profile update
app.put('/user/profile', authenticateToken, async (req, res) => {
  const { name, age, language, ... } = req.body;
  
  try {
    const user = await User.findById(req.user.id);
    
    if (name) user.name = name;
    if (age) user.age = age;
    if (language && ['en', 'hi', 'fr', 'es'].includes(language)) {
      user.language = language;
    }
    
    await user.save();
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: 'Update failed' });
  }
});

// Get profile (already exists, just verify language is returned)
app.get('/user/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.json(user);  // Make sure language field is included
  } catch (error) {
    res.status(500).json({ error: 'Fetch failed' });
  }
});

// Optional: Get just the language
app.get('/user/profile/language', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.json({ language: user.language || 'en' });
  } catch (error) {
    res.status(500).json({ error: 'Fetch failed' });
  }
});
```

### **Python/Flask**

```python
# Update user profile with language
@app.route('/user/profile', methods=['PUT'])
@token_required
def update_profile(current_user):
    data = request.get_json()
    
    if 'name' in data:
        current_user.name = data['name']
    if 'language' in data:
        if data['language'] in ['en', 'hi', 'fr', 'es']:
            current_user.language = data['language']
    
    db.session.commit()
    return jsonify(current_user.to_dict()), 200

# Get profile
@app.route('/user/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    return jsonify(current_user.to_dict()), 200
```

### **MongoDB**

```javascript
// Update user with language
db.users.updateOne(
  { _id: userId },
  { 
    $set: { 
      name: "Ahmed",
      language: "hi"  // ← Add this field
    }
  }
);

// Get user (language included)
db.users.findOne({ _id: userId });
```

---

## Testing Checklist for Backend

### **Test 1: Save Language**
```bash
# Request
curl -X PUT http://localhost:3000/user/profile \
  -H "Authorization: Bearer token" \
  -H "Content-Type: application/json" \
  -d '{"language": "hi"}'

# Should return 200 with updated user
```

### **Test 2: Retrieve Language**
```bash
# Request
curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer token"

# Should include language in response
# {
#   "id": "user_123",
#   "language": "hi",
#   ...
# }
```

### **Test 3: Multi-User Languages**
```bash
# User A sets Hindi
# User B sets Spanish
# User C gets English (default)

# Verify each gets their own language
curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer tokenA"
# Should return "language": "hi"

curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer tokenB"
# Should return "language": "es"

curl -X GET http://localhost:3000/user/profile \
  -H "Authorization: Bearer tokenC"
# Should return "language": "en" (default)
```

### **Test 4: Invalid Language**
```bash
# Request with invalid language
curl -X PUT http://localhost:3000/user/profile \
  -H "Authorization: Bearer token" \
  -d '{"language": "xx"}'

# Should either:
# Option A: Ignore invalid language (keep current)
# Option B: Return 400 Bad Request
```

---

## Database Verification

After implementation, verify with:

```sql
-- Check language field exists
SELECT * FROM users LIMIT 5;

-- Verify all users have a language (should be 'en' by default)
SELECT id, name, language FROM users;

-- Check distribution
SELECT language, COUNT(*) 
FROM users 
GROUP BY language;
```

---

## Deployment Steps

1. **Create migration** with language field
2. **Run migration** on database
3. **Update API endpoint** to accept language
4. **Update response** to include language
5. **Test with all 4 languages** (en, hi, fr, es)
6. **Deploy to production**
7. **Notify frontend team** - ready to test

---

## Integration Testing (End-to-End)

Once backend is ready, run this test:

1. **Signup/Login** as new user
   - App loads with English (default)
   - Check database - language='en'

2. **Change Language to Hindi**
   - User selects Hindi in Profile
   - Clicks Done
   - Check database - language='hi'
   - Check app - all text in Hindi

3. **Login on Different Device**
   - Logout and clear app data
   - Login again
   - App loads in Hindi automatically
   - No manual language selection needed

4. **Generate AI Content**
   - Generate workout in Hindi
   - Should be in Hindi (backend handles)
   - Generate meal plan in French
   - Should be in French

5. **Logout and Cleanup**
   - Logout
   - Delete test user
   - Verify database clean

---

## Common Issues & Solutions

### **Issue: Language not persisting**
**Solution:** Ensure PUT endpoint saves language to database

### **Issue: GET returns old value**
**Solution:** Query fresh from database, not cache

### **Issue: Default language not set**
**Solution:** Add DEFAULT 'en' to language column

### **Issue: AI content not in user's language**
**Solution:** Ensure frontend sends language, backend receives it

---

## Performance Considerations

### **Query Optimization**
```sql
-- Add index for language filter queries
CREATE INDEX idx_language ON users(language);

-- Query users by language
SELECT * FROM users WHERE language = 'hi';
```

### **Caching**
- Cache user language with auth token (for API responses)
- Invalidate on language change
- Reduces database queries

### **Lazy Loading**
- Don't load all user languages at startup
- Load only for logged-in user
- Efficient for large user bases

---

## Rollout Plan

**Phase 1: Development (1 day)**
- Add database field
- Update API endpoints
- Local testing

**Phase 2: Testing (1 day)**
- Run test checklist
- Multi-user testing
- Edge case testing

**Phase 3: Staging (1 day)**
- Deploy to staging
- Test with actual frontend app
- Performance testing

**Phase 4: Production (0.5 day)**
- Deploy to production
- Monitor logs
- Gradual rollout (10% → 50% → 100%)

---

## Questions?

- **API Contract:** See `/user/profile` endpoint details above
- **Database Schema:** See SQL migration section
- **Testing:** See testing checklist section
- **Examples:** See implementation examples for your framework

**Frontend is ready to go!** 🚀

Once backend is deployed, users will have:
- ✅ Language persists across sessions
- ✅ Multi-device synchronization
- ✅ AI content in preferred language
- ✅ Automatic language on login
