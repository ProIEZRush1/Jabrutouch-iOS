# iOS Password Reset Endpoint - Quick Answer

**Date**: 2025-10-12

---

## Question
Which endpoint is the iOS app calling for password reset, and why might it be using the legacy method?

---

## Answer

### The iOS app IS using the NEW secure endpoint ✅

**Endpoint**: `request_password_reset/`

**Full URL**: `https://jabrutouchback.overcloud.us/api/request_password_reset/`

**Evidence**:
- File: `Jabrutouch/App/Services/Network/HTTPRequestFactory.swift`
- Line 76: `let link = baseUrl.appendingPathComponent("request_password_reset/").absoluteString`
- Comment on same line: `// Updated to use secure reset link endpoint`

---

## Why It Might APPEAR to Use Legacy Method

### Reason 1: Backward Compatible Response Parser
The response model supports BOTH formats:
- NEW format: `{"success": true, "message": "..."}`
- OLD format: `{"user_exist_status": true, "message": "..."}`

This might create confusion, but it's for backward compatibility, not because it's calling the old endpoint.

### Reason 2: Previous Bug (Now Fixed)
Before commit `59cbbb4d`, the app was:
- ✅ Calling the correct NEW endpoint
- ❌ But only parsing the OLD response format
- ❌ This caused "Operation could not be completed" errors

This was fixed by updating the parser to handle both formats.

### Reason 3: Historical Commits
Git history shows the transition:
- OLD: `reset_password/` (legacy endpoint)
- NEW: `request_password_reset/` (current endpoint)

Older documentation might reference the legacy endpoint.

---

## Network Request Details

### HTTP Request
```
POST https://jabrutouchback.overcloud.us/api/request_password_reset/
Content-Type: application/json
Accept: application/json
X-App-Version: 1.6.0

{
  "email": "user@example.com"
}
```

### HTTP Method
POST

### Request Body Structure
```json
{
  "email": "user@example.com"
}
```

### Headers
- `Content-Type`: `application/json`
- `Accept`: `application/json`
- `X-App-Version`: `1.6.0` (for backend API versioning)

### Timeout
10 seconds

---

## Code Path

1. User taps "Send" button
2. `ForgotPasswordViewController.sendButtonPressed()` - validates email
3. `LoginManager.shared.forgotPassword(email)` - business logic
4. `API.forgotPassword(email)` - API interface
5. `HttpRequestsFactory.forgotPasswordRequest(email)` - **builds request with `request_password_reset/`**
6. `HttpServiceProvider.executeRequest()` - sends HTTP request
7. Response parsed by `ForgotPasswordResponse.init(values:)` - supports both old and new formats

---

## Key Files

| File | Purpose | Line |
|------|---------|------|
| `HTTPRequestFactory.swift` | ⭐ Defines endpoint URL | 76 |
| `ForgotPasswordViewController.swift` | UI logic and validation | 112-174 |
| `LoginManager.swift` | Business logic | 110-127 |
| `API.swift` | API interface | 68-76 |
| `ForgotPasswordResponse.swift` | Response parsing | 22-42 |

---

## Endpoint Configuration

### No Dynamic Switching
The iOS app does **NOT** dynamically switch between endpoints based on:
- ❌ App version
- ❌ API version
- ❌ Backend response
- ❌ Feature flags
- ❌ Configuration

It **ALWAYS** calls: `request_password_reset/`

### Base URL Configuration
The only configurable part is the base URL:
- Build Settings: `API_BASE_URL = "https://jabrutouchback.overcloud.us/api/"`
- Info.plist: `<string>$(API_BASE_URL)</string>`
- Code: `Bundle.main.object(forInfoDictionaryKey: "APIBaseUrl")`

---

## Conclusion

**The iOS app is NOT using the legacy method.**

It correctly calls the new secure endpoint `request_password_reset/` and has backward compatibility for parsing both old and new response formats.

---

## Related Documentation

For full technical details, see:
- `IOS_PASSWORD_RESET_ENDPOINT_ANALYSIS.md` - Complete analysis
- `IOS_PASSWORD_RESET_FIX.md` - Recent bug fix history
- `FIREBASE_DYNAMIC_LINK_FIX.md` - Backend Firebase link fix

---

**Status**: ✅ iOS app is using the correct new endpoint
