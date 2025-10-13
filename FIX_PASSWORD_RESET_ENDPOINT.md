# iOS App - Fix Password Reset Endpoint

**Date**: 2025-10-12
**Issue**: App still getting numeric passwords instead of reset links
**Root Cause**: iOS app calling OLD endpoint `/api/reset_password/` instead of NEW endpoint `/api/request-password-reset/`

---

## Problem Summary

The Django backend was successfully updated with secure password reset (commit `24dd9fc4`), but the iOS app is still calling the old endpoint that sends 4-digit numeric passwords via email.

**Current Flow (INCORRECT):**
```
iOS App → /api/reset_password/ → Backend generates 4-digit password → Email with password
```

**Desired Flow (CORRECT):**
```
iOS App → /api/request-password-reset/ → Backend generates token → Email with reset link → iOS app opens ResetPasswordViewController
```

---

## Files That Need to be Changed

### 1. HTTPRequestFactory.swift ⚠️ REQUIRES UPDATE

**File**: `/Jabrutouch/App/Services/Network/HTTPRequestFactory.swift`

**Current Code (Line 73-81):**
```swift
class func forgotPasswordRequest(email: String?) -> URLRequest?{
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    if email == nil { return nil }
    let link = baseUrl.appendingPathComponent("reset_password/").absoluteString  // ❌ OLD ENDPOINT
    let body: [String:Any] = [ "email": email ?? ""]
    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
    return request
}
```

**New Code (Change line 76):**
```swift
class func forgotPasswordRequest(email: String?) -> URLRequest?{
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    if email == nil { return nil }
    let link = baseUrl.appendingPathComponent("request-password-reset/").absoluteString  // ✅ NEW SECURE ENDPOINT
    let body: [String:Any] = [ "email": email ?? ""]
    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
    return request
}
```

**Change Required:**
```diff
- let link = baseUrl.appendingPathComponent("reset_password/").absoluteString
+ let link = baseUrl.appendingPathComponent("request-password-reset/").absoluteString
```

---

## Already Implemented (No Changes Needed)

The following components are already correctly implemented:

### ✅ Deep Link Handling
**File**: `AppDelegate.swift` (lines 83-96)
- Already handles `reset_password` deep link type
- Extracts token from URL
- Opens ResetPasswordViewController with token

### ✅ Reset Password View Controller
**File**: `ResetPasswordViewController.swift` (469 lines)
- Fully implemented with programmatic UI
- Accepts token and email
- Calls `confirm_reset_password/` endpoint
- Shows success screen after password reset

### ✅ Confirm Reset Password Endpoint
**File**: `HTTPRequestFactory.swift` (lines 83-90)
- Already calls `/confirm_reset_password/` (note: should be `/confirm-password-reset/` with hyphens)

**ISSUE**: The endpoint name has a mismatch!

**Backend Endpoint (with hyphens):**
```
/api/confirm-password-reset/
```

**iOS Endpoint (with underscores):**
```
/confirm_reset_password/
```

**This also needs to be fixed!**

---

## Complete Fix Required

### Fix 1: Update Forgot Password Endpoint

**File**: `/Jabrutouch/App/Services/Network/HTTPRequestFactory.swift`

**Line 76 - Change from:**
```swift
let link = baseUrl.appendingPathComponent("reset_password/").absoluteString
```

**To:**
```swift
let link = baseUrl.appendingPathComponent("request-password-reset/").absoluteString
```

### Fix 2: Update Confirm Reset Password Endpoint

**File**: `/Jabrutouch/App/Services/Network/HTTPRequestFactory.swift`

**Line 85 - Change from:**
```swift
let link = baseUrl.appendingPathComponent("confirm_reset_password/").absoluteString
```

**To:**
```swift
let link = baseUrl.appendingPathComponent("confirm-password-reset/").absoluteString
```

---

## Testing After Fix

### 1. Build and Run iOS App

```bash
cd /Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios
# Open in Xcode and build
```

### 2. Test Password Reset Flow

1. **Open app → Sign In screen**
2. **Tap "Forgot Password?"**
3. **Enter email address**
4. **Tap "Send"**
5. **Check email** - Should receive email with reset **LINK** (not password)
6. **Email should look like:**
   ```
   Subject: Restablece tu contraseña de Jabrutouch

   Hola [Name],

   Recibimos una solicitud para restablecer tu contraseña.

   Haz clic en el siguiente enlace para crear una nueva contraseña:
   https://jabrutouch.page.link/?type=reset_password&token=ABC123...&email=user@example.com

   Este enlace expirará en 1 hora.
   ```
7. **Tap link in email** - App should open ResetPasswordViewController
8. **Enter new password** (minimum 6 characters)
9. **Tap "Reset"** - Password should be updated
10. **Sign in with new password** - Should work!

### 3. Verify Network Requests

Check Xcode console output:
```
📧 Password reset email requested for: user@example.com
   Reset method: email_link
   Reset link sent: true
```

---

## Alternative: Quick Backend Fix (If iOS Can't Be Updated)

If you can't update the iOS app immediately, you can add **URL aliases** on the backend to support both naming conventions:

**File**: `jabrutouch_server/jabrutouch_server/urls.py`

**Add these lines after line 71:**
```python
# iOS app compatibility (uses underscores instead of hyphens)
re_path('api/request_password_reset/?$', request_password_reset),  # Alias
re_path('api/validate_reset_token/?$', validate_reset_token),      # Alias
re_path('api/confirm_reset_password/?$', confirm_password_reset),   # Alias
```

This allows the iOS app to call either:
- `/api/request-password-reset/` (correct, with hyphens)
- `/api/request_password_reset/` (iOS version, with underscores)

Both will work!

---

## Summary

**Problem**: iOS app calls old endpoint → Gets numeric password
**Solution**: Update 2 lines in HTTPRequestFactory.swift
**Alternative**: Add URL aliases on backend (no iOS changes needed)

**Files to Change**:
1. ✏️ HTTPRequestFactory.swift line 76: `reset_password/` → `request-password-reset/`
2. ✏️ HTTPRequestFactory.swift line 85: `confirm_reset_password/` → `confirm-password-reset/`

**Or Backend Alternative**:
1. ✏️ Add 3 URL aliases with underscores to urls.py

---

**Last Updated**: 2025-10-12
**Status**: Awaiting iOS app update or backend URL aliases
