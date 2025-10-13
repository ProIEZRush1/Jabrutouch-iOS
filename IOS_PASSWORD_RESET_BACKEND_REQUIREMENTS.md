# iOS Password Reset Backend Requirements

**Analysis Date:** 2025-10-12
**Analyzed App:** jabrutouch_ios (JabruTouch iOS App)

---

## Executive Summary

This document details the exact backend API requirements for the iOS app's password reset functionality based on code analysis of the production iOS application.

---

## 1. Deep Link URL Format

### Expected URL Structure

The iOS app expects password reset deep links in the following format:

```
https://jabrutouch.page.link/?type=reset_password&token={TOKEN}&email={EMAIL}
```

### URL Parameters

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| `type` | **YES** | String | Must be exactly `"reset_password"` |
| `token` | **YES** | String | Reset token (URL-encoded) |
| `email` | Optional | String | User's email (URL-encoded) |

### Deep Link Handling

**File:** `/Jabrutouch/App/Core/AppDelegate.swift` (Lines 73-96)

```swift
func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){
    guard let url = dynamicLink.url else { return }
    guard let url1 = url.queryDictionary else { return }
    let type = url1["type"]

    // Handle password reset deep link (doesn't require authentication)
    if type == "reset_password" {
        guard let token = url1["token"] else {
            print("⚠️  Password reset link missing token parameter")
            return
        }
        print("🔐 Password reset deep link received with token")

        let resetPasswordViewController = Storyboards.ResetPassword.resetPasswordViewController
        resetPasswordViewController.resetToken = token
        resetPasswordViewController.userEmail = url1["email"]
        resetPasswordViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.topmostViewController?.present(resetPasswordViewController, animated: true, completion: nil)
        return
    }
    // ... other deep link handlers
}
```

### URL Scheme Configuration

**File:** `/Jabrutouch/Info.plist` (Lines 27-48)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>il.co.jabrutouch.Jabrutouch</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>Jabrutouch</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>Deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>jabrutouch.page.link</string>
        </array>
    </dict>
</array>
```

### Universal Links

The app uses **Firebase Dynamic Links** for Universal Links support:
- Domain: `jabrutouch.page.link`
- Handled via `application(_:continue:restorationHandler:)` in AppDelegate

---

## 2. API Endpoints

### 2.1 Request Password Reset

**Endpoint:** `POST /reset_password/`

**Purpose:** User requests a password reset by providing their email address.

**Request Headers:**
```
Content-Type: application/json
Accept: application/json
X-App-Version: {iOS app version} (e.g., "1.0.0")
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "message": "Password reset email sent successfully",
    "user_exist_status": true,
    "reset_method": "email_link",
    "reset_link_sent": true,
    "link_expires_in": 3600
  },
  "errors": []
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "data": null,
  "errors": [
    {
      "message": "User with this email does not exist"
    }
  ]
}
```

**Implementation Files:**
- API Call: `LoginManager.swift` (Lines 110-127)
- HTTP Request: `HTTPRequestFactory.swift` (Lines 73-81)
- Response Model: `ForgotPasswordResponse.swift`

---

### 2.2 Confirm Password Reset

**Endpoint:** `POST /confirm_reset_password/`

**Purpose:** User confirms password reset with token from email link and provides new password.

**Request Headers:**
```
Content-Type: application/json
Accept: application/json
X-App-Version: {iOS app version}
```

**Request Body:**
```json
{
  "token": "abc123def456...",
  "new_password": "NewSecurePassword123"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "success": true,
    "message": "Password reset successfully",
    "user_email": "user@example.com"
  },
  "errors": []
}
```

**Error Responses:**

**Invalid/Expired Token (400 Bad Request):**
```json
{
  "success": false,
  "data": null,
  "errors": [
    {
      "message": "Invalid or expired reset token"
    }
  ]
}
```

**Validation Error (400 Bad Request):**
```json
{
  "success": false,
  "data": null,
  "errors": [
    {
      "message": "Password must be at least 6 characters"
    }
  ]
}
```

**Implementation Files:**
- API Call: `LoginManager.swift` (Lines 129-145)
- HTTP Request: `HTTPRequestFactory.swift` (Lines 83-90)
- Response Model: `ResetPasswordResponse.swift`
- UI Controller: `ResetPasswordViewController.swift` (Lines 409-428)

---

## 3. Request/Response Data Models

### 3.1 ForgotPasswordResponse Model

**File:** `/Jabrutouch/App/Models/Network/API Response models/ForgotPasswordResponse.swift`

```swift
struct ForgotPasswordResponse: APIResponseModel {
    let message: String                  // Required
    let status: Bool                     // Required (user_exist_status)

    // Optional v2 fields (backward compatible)
    let resetMethod: String?             // "email_password" or "email_link"
    let resetLinkSent: Bool?             // true if reset link was sent
    let linkExpiresIn: Int?              // seconds until link expires

    init?(values: [String : Any]) {
        guard let message = values["message"] as? String else { return nil }
        guard let status = values["user_exist_status"] as? Bool else { return nil }

        self.message = message
        self.status = status

        // Optional fields
        self.resetMethod = values["reset_method"] as? String
        self.resetLinkSent = values["reset_link_sent"] as? Bool
        self.linkExpiresIn = values["link_expires_in"] as? Int
    }
}
```

### 3.2 ResetPasswordResponse Model

**File:** `/Jabrutouch/App/Models/Network/API Response models/ResetPasswordResponse.swift`

```swift
struct ResetPasswordResponse: APIResponseModel {
    let success: Bool                    // Required
    let message: String                  // Required
    let userEmail: String?               // Optional

    init?(values: [String : Any]) {
        guard let success = values["success"] as? Bool else { return nil }
        guard let message = values["message"] as? String else { return nil }

        self.success = success
        self.message = message
        self.userEmail = values["user_email"] as? String
    }
}
```

### 3.3 Generic API Response Wrapper

All responses are wrapped in a generic structure:

```json
{
  "success": true/false,
  "data": { ... },
  "errors": [
    {
      "message": "Error description"
    }
  ]
}
```

**Processing Logic:** `API.swift` (Lines 391-438)

---

## 4. Password Validation Rules

### Client-Side Validation

**File:** `/Jabrutouch/Controller/ResetPassword/ResetPasswordViewController.swift` (Lines 367-389)

```swift
@objc private func resetButtonPressed() {
    // 1. New password must not be empty
    guard let newPassword = self.newPasswordTextField.text, !newPassword.isEmpty else {
        Utils.showAlertMessage("Please enter a new password",
                              title: "Password Required",
                              viewControler: self)
        return
    }

    // 2. Password must be at least 6 characters
    guard newPassword.count >= 6 else {
        Utils.showAlertMessage("Password must be at least 6 characters",
                              title: "Password Too Short",
                              viewControler: self)
        return
    }

    // 3. Confirmation password must not be empty
    guard let confirmPassword = self.confirmPasswordTextField.text, !confirmPassword.isEmpty else {
        Utils.showAlertMessage("Please confirm your password",
                              title: "Confirmation Required",
                              viewControler: self)
        return
    }

    // 4. Passwords must match
    guard newPassword == confirmPassword else {
        Utils.showAlertMessage("Passwords do not match",
                              title: "Password Mismatch",
                              viewControler: self)
        return
    }

    // Validation passed - submit to API
    self.showActivityView()
    self.confirmResetPassword(newPassword)
}
```

### Validation Requirements Summary

| Rule | Requirement | Error Message |
|------|-------------|---------------|
| Non-empty | Password must not be empty | "Please enter a new password" |
| Min Length | Minimum 6 characters | "Password must be at least 6 characters" |
| Confirmation | Must match confirmation field | "Passwords do not match" |

---

## 5. Security & Authentication

### No Authentication Required for Reset

Password reset endpoints **DO NOT require authentication tokens**. This is by design:
- User has forgotten their password and cannot authenticate
- Deep link with token provides authorization
- Token must be validated server-side

### Token Security

**Backend Requirements:**
1. **Token Generation:** Generate cryptographically secure random tokens (minimum 32 characters)
2. **Token Storage:** Hash tokens before storing in database
3. **Token Expiration:** Tokens should expire (recommended: 1 hour)
4. **Single Use:** Tokens should be invalidated after successful use
5. **Rate Limiting:** Implement rate limiting on reset requests per email

---

## 6. App Version Header

### X-App-Version Header

**File:** `/Jabrutouch/App/Services/Network/HTTPRequestFactory.swift` (Lines 434-438)

```swift
// Add app version header for API versioning (backward compatibility)
if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
    request.addValue(version, forHTTPHeaderField: "X-App-Version")
}
```

### Purpose

The `X-App-Version` header allows the backend to:
- Track which app versions are making requests
- Implement version-specific behavior if needed
- Support backward compatibility for older app versions

**Example:** `X-App-Version: 1.0.0`

---

## 7. User Experience Flow

### Complete Password Reset Flow

```
1. User opens app → Taps "Forgot Password?"
   ↓
2. ForgotPasswordViewController appears
   ↓
3. User enters email → Taps "Send Reset Link"
   ↓
4. API: POST /reset_password/ {"email": "user@example.com"}
   ↓
5. Backend sends email with Firebase Dynamic Link
   Example: https://jabrutouch.page.link/?type=reset_password&token=abc123&email=user@example.com
   ↓
6. User clicks link in email
   ↓
7. iOS opens app via Universal Link
   ↓
8. AppDelegate handles deep link
   ↓
9. ResetPasswordViewController appears with token pre-filled
   ↓
10. User enters new password + confirmation → Taps "Reset Password"
    ↓
11. Client validates: length ≥ 6, passwords match
    ↓
12. API: POST /confirm_reset_password/ {"token": "abc123", "new_password": "newpass"}
    ↓
13. Backend validates token, updates password
    ↓
14. Success screen appears: "Password Reset Successfully"
    ↓
15. User taps "Go to Login" → Returns to SignInViewController
```

---

## 8. UI Components & User Interaction

### ResetPasswordViewController

**File:** `/Jabrutouch/Controller/ResetPassword/ResetPasswordViewController.swift`

**Properties:**
```swift
class ResetPasswordViewController: UIViewController {
    var resetToken: String = ""           // Set by deep link handler
    var userEmail: String?                // Optional, set by deep link
}
```

**UI Elements:**
- **New Password Field:** Secure text entry, minimum 6 characters
- **Confirm Password Field:** Secure text entry, must match new password
- **Reset Button:** Validates and submits to API
- **Activity Indicator:** Shows during API call
- **Success Container:** Appears after successful reset
- **Exit Buttons:** Dismiss controller

**Keyboard Handling:**
- Container animates from 94pt to 20pt top margin when keyboard appears
- Return key navigates between fields
- Final return dismisses keyboard

---

## 9. Error Handling

### Client-Side Errors

| Error Type | Display Method | User Action |
|------------|----------------|-------------|
| Empty Password | Alert Dialog | Re-enter password |
| Password Too Short | Alert Dialog | Enter longer password |
| Password Mismatch | Alert Dialog | Re-enter confirmation |
| Network Error | Alert Dialog | Retry |

### Server-Side Errors

**File:** `API.swift` (Lines 391-438)

```swift
if serverResponse.success {
    // Parse success response
    if let apiResponse = T(values: values) {
        completionHandler(.success(apiResponse))
    }
} else {
    // Handle error
    if serverResponse.errors.count > 0 {
        let fieldError = serverResponse.errors[0]
        switch fieldError.message {
        case "Invalid token.":
            completionHandler(.failure(.invalidToken))
        default:
            completionHandler(.failure(.custom(fieldError.message)))
        }
    }
}
```

### Expected Error Messages

| Error | HTTP Status | Backend Message |
|-------|-------------|-----------------|
| Email Not Found | 400 | "User with this email does not exist" |
| Invalid Token | 400 | "Invalid or expired reset token" |
| Token Expired | 400 | "Reset token has expired" |
| Password Too Short | 400 | "Password must be at least 6 characters" |
| Server Error | 500 | "An error occurred. Please try again later" |

---

## 10. Implementation Checklist for Backend

### 10.1 Request Password Reset Endpoint

- [ ] **Endpoint:** `POST /reset_password/`
- [ ] **Accept:** JSON body with `email` field
- [ ] **Validate:** Email exists in database
- [ ] **Generate:** Cryptographically secure reset token (32+ chars)
- [ ] **Store:** Hashed token with expiration timestamp
- [ ] **Send Email:** With Firebase Dynamic Link
- [ ] **Return:** Success response with required fields
- [ ] **Rate Limit:** Max 3 requests per email per hour

**Response Format:**
```json
{
  "success": true,
  "data": {
    "message": "Password reset email sent successfully",
    "user_exist_status": true,
    "reset_method": "email_link",
    "reset_link_sent": true,
    "link_expires_in": 3600
  },
  "errors": []
}
```

### 10.2 Confirm Password Reset Endpoint

- [ ] **Endpoint:** `POST /confirm_reset_password/`
- [ ] **Accept:** JSON body with `token` and `new_password`
- [ ] **Validate:** Token exists and not expired
- [ ] **Validate:** Password meets minimum requirements (6+ chars)
- [ ] **Hash:** New password with secure algorithm (bcrypt/Argon2)
- [ ] **Update:** User password in database
- [ ] **Invalidate:** Reset token (single use)
- [ ] **Return:** Success response with user email

**Response Format:**
```json
{
  "success": true,
  "data": {
    "success": true,
    "message": "Password reset successfully",
    "user_email": "user@example.com"
  },
  "errors": []
}
```

### 10.3 Email Template

**Subject:** Password Reset - JabruTouch

**Body Structure:**
```
Hello [User Name],

You requested to reset your password for your JabruTouch account.

Click the link below to reset your password:

[RESET BUTTON with Firebase Dynamic Link]
https://jabrutouch.page.link/?type=reset_password&token={TOKEN}&email={EMAIL}

This link will expire in 1 hour.

If you did not request this reset, please ignore this email.

---
JabruTouch Team
```

### 10.4 Firebase Dynamic Link Configuration

**Required Parameters:**
```
Domain: jabrutouch.page.link
Link: https://jabrutouch.page.link/
Query Params:
  - type=reset_password
  - token={generated_token}
  - email={user_email_urlencoded}
iOS Bundle ID: il.co.jabrutouch.Jabrutouch
iOS App Store ID: [Your App Store ID]
```

### 10.5 Security Considerations

- [ ] Use HTTPS for all endpoints
- [ ] Validate email format
- [ ] Hash tokens before storing
- [ ] Set token expiration (1 hour recommended)
- [ ] Invalidate token after use
- [ ] Implement rate limiting
- [ ] Log password reset attempts
- [ ] Send confirmation email after successful reset
- [ ] Don't reveal if email exists (security best practice)
- [ ] Consider CAPTCHA for abuse prevention

---

## 11. Testing Scenarios

### 11.1 Happy Path Testing

1. **Request Reset:**
   - POST /reset_password/ with valid email
   - Verify 200 response with success=true
   - Verify email received with valid deep link

2. **Confirm Reset:**
   - Open deep link from email
   - App opens to ResetPasswordViewController
   - Enter valid password (6+ chars)
   - Enter matching confirmation
   - Submit
   - Verify 200 response with success=true
   - Verify success screen appears

3. **Login with New Password:**
   - Return to login screen
   - Login with new password
   - Verify successful authentication

### 11.2 Error Scenario Testing

1. **Invalid Email:**
   - Request reset with non-existent email
   - Verify appropriate error response

2. **Expired Token:**
   - Generate token
   - Wait for expiration
   - Attempt reset
   - Verify "expired token" error

3. **Invalid Token:**
   - Use malformed/fake token
   - Attempt reset
   - Verify "invalid token" error

4. **Password Validation:**
   - Try password < 6 chars
   - Verify client-side validation
   - Try mismatched confirmation
   - Verify client-side validation

5. **Token Reuse:**
   - Successfully reset password
   - Try to use same token again
   - Verify token is invalidated

---

## 12. API Version Compatibility

### X-App-Version Header Usage

The iOS app sends `X-App-Version` header with every request:
- **Current Format:** Semantic versioning (e.g., "1.0.0")
- **Source:** `CFBundleShortVersionString` from Info.plist

### Backward Compatibility Strategy

**ForgotPasswordResponse** supports optional fields for v2:
- Old apps: Only parse `message` and `user_exist_status`
- New apps: Parse additional fields if present

**Backend Strategy:**
```python
# Example backend logic
if request.headers.get('X-App-Version') >= '2.0.0':
    # Send v2 response with additional fields
    return {
        'message': '...',
        'user_exist_status': True,
        'reset_method': 'email_link',
        'reset_link_sent': True,
        'link_expires_in': 3600
    }
else:
    # Send v1 response (minimal fields)
    return {
        'message': '...',
        'user_exist_status': True
    }
```

---

## 13. Files Reference

### iOS App Files Analyzed

| File | Purpose | Lines |
|------|---------|-------|
| `AppDelegate.swift` | Deep link handling | 73-96 |
| `ResetPasswordViewController.swift` | Password reset UI & logic | 469 |
| `LoginManager.swift` | API call managers | 110-145 |
| `API.swift` | HTTP service layer | 68-86 |
| `HTTPRequestFactory.swift` | Request builders | 73-90 |
| `ResetPasswordResponse.swift` | Response model | 38 |
| `ForgotPasswordResponse.swift` | Response model | 48 |
| `Info.plist` | URL schemes config | 27-48 |

---

## 14. Summary of Backend Requirements

### Must Have (Critical)

1. ✅ **POST /reset_password/** - Accept email, send reset link
2. ✅ **POST /confirm_reset_password/** - Accept token + password, update user
3. ✅ **Firebase Dynamic Link** - Format: `type=reset_password&token={TOKEN}&email={EMAIL}`
4. ✅ **Token Security** - Cryptographically secure, hashed, expiring, single-use
5. ✅ **Response Format** - Generic wrapper with success/data/errors structure

### Should Have (Recommended)

1. ✅ **Rate Limiting** - Prevent abuse
2. ✅ **Email Template** - Professional, branded email
3. ✅ **Logging** - Track reset attempts for security
4. ✅ **Confirmation Email** - After successful reset

### Optional (Nice to Have)

1. ⚪ **X-App-Version** handling - Version-specific behavior
2. ⚪ **CAPTCHA** - Prevent automated abuse
3. ⚪ **User Notification** - Alert user if they didn't request reset

---

## Appendix A: Example API Calls

### Request Password Reset

```bash
curl -X POST https://api.jabrutouch.com/reset_password/ \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "X-App-Version: 1.0.0" \
  -d '{
    "email": "user@example.com"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Password reset email sent successfully",
    "user_exist_status": true,
    "reset_method": "email_link",
    "reset_link_sent": true,
    "link_expires_in": 3600
  },
  "errors": []
}
```

### Confirm Password Reset

```bash
curl -X POST https://api.jabrutouch.com/confirm_reset_password/ \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "X-App-Version: 1.0.0" \
  -d '{
    "token": "abc123def456xyz789...",
    "new_password": "NewSecurePassword123"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "success": true,
    "message": "Password reset successfully",
    "user_email": "user@example.com"
  },
  "errors": []
}
```

---

## Appendix B: Token Generation Example

### Python Example (Django/Laravel)

```python
import secrets
import hashlib
from datetime import datetime, timedelta

def generate_reset_token():
    """Generate cryptographically secure reset token"""
    # Generate 32-byte random token
    token = secrets.token_urlsafe(32)
    return token

def hash_token(token):
    """Hash token for storage"""
    return hashlib.sha256(token.encode()).hexdigest()

def create_password_reset_request(user_email):
    """Create password reset request"""
    token = generate_reset_token()
    hashed_token = hash_token(token)
    expires_at = datetime.now() + timedelta(hours=1)

    # Store in database
    PasswordResetToken.objects.create(
        email=user_email,
        token_hash=hashed_token,
        expires_at=expires_at
    )

    # Send email with plain token
    send_reset_email(user_email, token)

    return token
```

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-12 | Claude Code | Initial analysis and documentation |

---

**End of Document**
