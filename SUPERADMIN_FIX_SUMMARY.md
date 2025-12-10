# SuperAdmin Login & Permissions Fix

## Problem Identified
Your backend's `/loginUser` endpoint was **not returning a sessionToken** in the response.

Debug output showed:
```
DEBUG loginUser: sessionToken from response = ''
DEBUG loginUser: sessionToken is empty? true
DEBUG loginUser: sessionToken length = 0
```

The login response contained user data but the critical `sessionToken` field was missing, preventing authentication for subsequent API calls.

---

## Solutions Implemented

### 1. Fixed `user_api.dart` - loginUser() Method (Lines 11-117)
**What was changed:**
- Added automatic fallback to Parse's built-in `/login` endpoint when sessionToken is empty
- Created new helper method `_getSessionTokenFromParseLogin()` (Lines 119-154)
- Ensured sessionToken is always included in the returned map

**How it works:**
```
Flow: /loginUser (custom endpoint)
  ↓
If sessionToken is empty:
  ↓
/login (Parse built-in endpoint) ← Gets sessionToken
  ↓
Returns complete user data with sessionToken
```

### 2. Updated `main.dart`
**Added test route:**
```dart
'/superadmin-test': (context) => const SuperAdminPermissionsTest(),
```

This allows you to test the login and all permissions from the app.

### 3. Created `SuperAdminPermissionsTest.dart`
**Complete test screen featuring:**
- Login form with username/password input
- Live test logging with timestamps
- Automatic session token retrieval verification
- Permission checks via SharedPreferences
- Tests for all SuperAdmin endpoints:
  - `getAllAdmins()` - SuperAdmin only
  - `getAllDoctors()` - Admin+
  - `getAllSpecialists()` - Admin+

---

## How to Test

### Option 1: Use the Test Screen (Recommended)
1. Run the app
2. Navigate to `/superadmin-test` route:
   ```dart
   Navigator.pushNamed(context, '/superadmin-test');
   ```
3. Enter SuperAdmin credentials:
   - Username: `yaradiab`
   - Password: (your password)
4. Click "Test Login"
5. Review the test results in the log

### Option 2: Manual Testing in Postman
```
POST http://localhost:1337/api/functions/loginUser

Headers:
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY

Body:
{
  "username": "yaradiab",
  "password": "your_password",
  "platform": "flutter",
  "locale": "ar"
}
```

---

## Verification Checklist

After login, verify:
- ✅ `sessionToken` is not empty (length > 0)
- ✅ `role` is "SUPER_ADMIN" 
- ✅ `SharedPrefsHelper.isSuperAdmin()` returns `true`
- ✅ `SharedPrefsHelper.isAdmin()` returns `true`
- ✅ `getAllAdmins()` endpoint works
- ✅ Token is stored in SharedPreferences
- ✅ Can navigate to AdminHome screen

---

## File Changes Summary

| File | Change | Lines |
|------|--------|-------|
| `lib/api/user_api.dart` | Added fallback sessionToken retrieval | 11-154 |
| `lib/main.dart` | Added test route import and definition | 8, 46-47 |
| `lib/TEST/SuperAdminPermissionsTest.dart` | Created new test screen | NEW |

---

## Key Code Sections

### Fallback SessionToken Retrieval
```dart
// If sessionToken is empty from cloud function, get it from Parse
if (sessionToken.isEmpty) {
  print(" Fetching sessionToken from Parse login endpoint...");
  final sessionTokenData = await _getSessionTokenFromParseLogin(username, password);
  if (sessionTokenData.containsKey("sessionToken")) {
    sessionToken = sessionTokenData["sessionToken"] ?? "";
  }
}
```

### Permission Checking
```dart
// In AdminHomeScreen.dart
final isSuperAdmin = SharedPrefsHelper.isSuperAdmin();
final isAdmin = SharedPrefsHelper.isAdmin();

// Show admin-only features
if (isSuperAdmin) {
  // Show Admin management card
}
```

---

## Important Notes

1. **Backend Fix Recommended**: While the Flutter fix handles the missing sessionToken, it's better to fix the backend `/loginUser` function to return sessionToken directly.

2. **Master Key Usage**: The code uses Master Key for debugging. In production, remove or restrict this.

3. **SuperAdmin Role**: Must be assigned in Parse Dashboard:
   - Users table → Select user → Roles → Add "SUPER_ADMIN" role

4. **Session Storage**: Token is stored in SharedPreferences for offline access and API calls.

---

## Troubleshooting

### If login still fails:
1. Verify username/password in Parse Dashboard
2. Check that SuperAdmin role exists in Roles table
3. Verify the user has the SUPER_ADMIN role assigned
4. Check Parse server logs for errors

### If getAllAdmins() fails:
- Ensure sessionToken is not empty (check logs)
- Verify user has SUPER_ADMIN role
- Check Parse Dashboard for role permissions/ACL

### If role detection fails:
- Check the role fetch in debug logs
- Verify role object structure in Parse Dashboard
- May need to manually assign role if detection fails

---

## Next Steps

1. **Test the fix**: Use SuperAdminPermissionsTest screen
2. **Verify all endpoints**: Run through the test checklist
3. **Optional backend fix**: Update `/loginUser` cloud function to return sessionToken
4. **Remove debug logs**: Clean up before production

