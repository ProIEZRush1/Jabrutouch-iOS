# iOS Rate Limiting Handling Analysis

**Date**: 2025-10-13
**Context**: Backend returns HTTP 429 with rate limit error, but iOS app doesn't handle it properly
**User Request**: Add rate limiting handling with proper user messaging

---

## Current Password Reset Flow Analysis

### 1. UI Controller: ForgotPasswordViewController.swift

**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/ForgotPassword/ForgotPasswordViewController.swift`

#### Current Implementation

The app already has **client-side rate limiting** implemented:

```swift
// Rate limiting properties (lines 18-21)
private var lastRequestTime: Date?
private let requestCooldown: TimeInterval = 60 // 60 seconds
private var cooldownTimer: Timer?

// Rate limit check in sendButtonPressed (lines 125-133)
if let lastRequest = lastRequestTime {
    let timeSinceLastRequest = Date().timeIntervalSince(lastRequest)
    if timeSinceLastRequest < requestCooldown {
        let remainingTime = Int(requestCooldown - timeSinceLastRequest)
        Utils.showAlertMessage("Please wait \(remainingTime) seconds before requesting again",
                              title: "Too Many Requests",
                              viewControler: self)
        return
    }
}
```

#### Error Handling (lines 162-174)

```swift
private func forgotPassword(_ email: String) {
    LoginManager.shared.forgotPassword(email: email) { (result) in
        self.removeActivityView()
        switch result {
        case .success(let result):
            self.setSecondContainer(message: result.message, status: result.status)
        case .failure(let error):
            let title = Strings.error
            let message = error.localizedDescription  // ⚠️ PROBLEM: Generic error message
            Utils.showAlertMessage(message, title: title, viewControler: self)
        }
    }
}
```

**Problem**: When backend returns HTTP 429, the error falls through to `.failure` case and shows the generic system error message: **"No se ha podido completar la operación"** (The operation could not be completed).

---

### 2. Response Model: ForgotPasswordResponse.swift

**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Network/API Response models/ForgotPasswordResponse.swift`

```swift
struct ForgotPasswordResponse: APIResponseModel {
    let message: String
    let status: Bool

    // Optional new fields for v2 API
    let resetMethod: String?
    let resetLinkSent: Bool?
    let linkExpiresIn: Int?

    init?(values: [String : Any]) {
        if let message = values["message"] as? String {
            self.message = message
        } else { return nil }

        // Support both new and old API response formats
        if let status = values["success"] as? Bool {
            self.status = status
        } else if let status = values["user_exist_status"] as? Bool {
            self.status = status
        } else {
            return nil
        }

        // Optional fields...
    }
}
```

**Note**: This model only parses **successful** responses. HTTP errors (429, 500, etc.) never reach this parser.

---

### 3. API Layer: API.swift

**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/Network/API.swift`

#### forgotPassword Method (lines 68-76)

```swift
class func forgotPassword(email: String?, completionHandler:@escaping (_ response: APIResult<ForgotPasswordResponse>)->Void) {
    guard let request = HttpRequestsFactory.forgotPasswordRequest(email: email) else {
        completionHandler(APIResult.failure(.unableToCreateRequest))
        return
    }
    HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
        self.processResult(data: data, response: response, error: error, completionHandler: completionHandler)
    }
}
```

#### processResult Method (lines 391-438)

```swift
private class func processResult<T: APIResponseModel>(data: Data?, response: URLResponse?, error: Error?, completionHandler:@escaping (_ response: APIResult<T>)->Void) {
    if let _error = error {
        completionHandler(APIResult.failure(.serverError(_error)))  // ⚠️ Network errors
    }
    else if let _data = data {
        guard let values = Utils.convertDataToDictionary(_data) else {
            completionHandler(APIResult.failure(.unableToParseResponse))
            return
        }
        guard let serverResponse = ServerGenericResponse(values: values) else {
            completionHandler(APIResult.failure(.unableToParseResponse))
            return
        }
        if serverResponse.success {
            // Success handling...
        }
        else {
            // Error handling (lines 419-432)
            if serverResponse.errors.count > 0 {
                let fieldError = serverResponse.errors[0]
                switch fieldError.message {
                case "Invalid token.":
                    completionHandler(.failure(.invalidToken))
                default:
                    completionHandler(.failure(.custom(fieldError.message)))  // ⚠️ OPPORTUNITY
                }
            }
            else {
                completionHandler(.failure(.unknown))
            }
        }
    }
    else {
        completionHandler(.failure(.unknown))
    }
}
```

**Critical Finding**: The `processResult` method:
1. **Does NOT check HTTP status codes** (response is received but never inspected)
2. Only parses JSON body to extract errors
3. When `success: false`, it checks `errors[0].message` and can return custom messages

---

### 4. HTTP Layer: HttpServiceProvider.swift

**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/Network/HttpServiceProvider.swift`

```swift
func excecuteRequest(request:URLRequest, completionHandler:@escaping ((Data?, URLResponse?, Error?) -> Void) ) {
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
        if let _error = error {
            completionHandler(data, response, _error)
        }
        else {
            completionHandler(data, response, nil)  // ⚠️ No status code check
        }
    }
    task.resume()
}
```

**Problem**: HTTP status codes (like 429) are **never checked**. The response is passed through without inspection.

---

### 5. Error Types: JTError.swift

**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/JTError.swift`

```swift
enum JTError: Error {
    case unableToConvertDictionaryToString
    case unableToConvertStringToData
    case invalidUrl
    case authTokenMissing
    case userAlreadyExist
    case unknown
    case unableToCreateRequest
    case unableToParseResponse
    case serverError(Error)
    case invalidToken
    case custom(String)

    var message: String {
        switch self {
        case .serverError(let error):
            return error.localizedDescription
        case .invalidToken:
            return "Invalid Token."
        case .custom(let message):
            return message
        default:
            return "Server error"
        }
    }
}
```

**Opportunity**: `.custom(String)` case allows for custom error messages.

---

### 6. Localization Strings

#### Spanish (es.lproj/Localizable.strings)

**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Supporting Files/Strings/es.lproj/Localizable.strings`

**Current strings** (lines 55-62):
```
"forgotPassword" = "¿Olvidaste tu contraseña?";
"forgotPasswordText" = "Ingresa tu e-mail para recibir un enlace de restablecimiento:";
"sendNow" = "Enviar";
"forgotPasswordTitle" = "Recupera tu contraseña";
"forgotPasswordErrorMessage" = "¡Vaya! Parece que no estás registrado...";
"forgotPasswordSuccessMessage" = "Acabamos de enviarte un enlace para restablecer tu contraseña al siguiente e-mail:";
"forgotPasswordSuccessTitle" = "E-mail enviado";
```

#### English (en.lproj/Localizable.strings)

**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Supporting Files/Strings/en.lproj/Localizable.strings`

**Same keys, same Spanish text** (app uses Spanish for both locales)

**Missing Strings**: No rate limit error messages currently exist.

---

## Backend API Response Format (HTTP 429)

When rate limited, the backend returns:

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json

{
  "success": false,
  "message": "Too many reset attempts. Please try again later."
}
```

---

## Problem Summary

### Current User Experience (BAD)

1. User taps "Forgot Password"
2. Enters email and taps "Send"
3. **Backend returns HTTP 429** with rate limit message
4. iOS app receives data but **never checks status code**
5. API layer parses JSON: `success: false`, extracts message
6. But error handling shows: **"No se ha podido completar la operación"** (generic iOS error)
7. User is confused and may retry multiple times

### Root Causes

1. **HTTP status codes are ignored**: `HttpServiceProvider` never checks `HTTPURLResponse.statusCode`
2. **Error message not passed through**: When backend returns `success: false` with a message, the custom message is used BUT in this specific case it's falling through to a system error
3. **Client-side rate limit too permissive**: App allows 1 request per 60s, backend may be stricter

---

## Recommended Solution

### Option A: Parse Backend Error Message (RECOMMENDED)

**Approach**: The backend already returns `{"success": false, "message": "..."}`. We need to ensure this message reaches the user.

**Changes Required**:

1. **No changes to HttpServiceProvider** (keep it simple)
2. **Verify API.processResult handles rate limit properly**
3. **Update ForgotPasswordViewController error handling**
4. **Add localized rate limit strings**

#### Implementation

**Step 1**: Add Rate Limit Localization Strings

**File**: `Jabrutouch/Supporting Files/Strings/es.lproj/Localizable.strings`

Add these lines (after line 62):
```
"rateLimitTitle" = "Demasiados intentos";
"rateLimitMessage" = "Has realizado muchas solicitudes. Por favor, espera unos minutos antes de intentarlo nuevamente.";
```

**File**: `Jabrutouch/Supporting Files/Strings/en.lproj/Localizable.strings`

Add the same strings (app uses Spanish for both).

**Step 2**: Update Strings.swift

**File**: `Jabrutouch/App/Resources/Strings.swift`

Add these properties (after line 70):
```swift
class var rateLimitTitle: String {
    return NSLocalizedString("rateLimitTitle", comment: "")
}

class var rateLimitMessage: String {
    return NSLocalizedString("rateLimitMessage", comment: "")
}
```

**Step 3**: Update ForgotPasswordViewController Error Handling

**File**: `Jabrutouch/Controller/ForgotPassword/ForgotPasswordViewController.swift`

Replace the `forgotPassword` method (lines 162-174) with:

```swift
private func forgotPassword(_ email: String) {
    LoginManager.shared.forgotPassword(email: email) { (result) in
        self.removeActivityView()
        switch result {
        case .success(let result):
            self.setSecondContainer(message: result.message, status: result.status)
        case .failure(let error):
            // Check if error message indicates rate limiting
            let errorMessage = error.localizedDescription
            let title: String
            let message: String

            if errorMessage.lowercased().contains("too many") ||
               errorMessage.lowercased().contains("rate limit") ||
               errorMessage.lowercased().contains("demasiados") {
                // Rate limit error
                title = Strings.rateLimitTitle
                message = Strings.rateLimitMessage
            } else {
                // Generic error
                title = Strings.error
                message = errorMessage
            }

            Utils.showAlertMessage(message, title: title, viewControler: self)
        }
    }
}
```

**Alternative (cleaner)**: If you want to handle this more robustly, add a new error case to `JTError`:

```swift
// In JTError.swift
enum JTError: Error {
    // ... existing cases
    case rateLimitExceeded(String)  // New case

    var message: String {
        switch self {
        // ... existing cases
        case .rateLimitExceeded(let message):
            return message
        }
    }
}
```

And update API.processResult to detect rate limit errors:

```swift
// In API.swift, processResult method (around line 422-426)
if serverResponse.errors.count > 0 {
    let fieldError = serverResponse.errors[0]
    switch fieldError.message {
    case "Invalid token.":
        completionHandler(.failure(.invalidToken))
    case let msg where msg.lowercased().contains("too many") || msg.lowercased().contains("rate limit"):
        completionHandler(.failure(.rateLimitExceeded(msg)))
    default:
        completionHandler(.failure(.custom(fieldError.message)))
    }
}
```

Then in ForgotPasswordViewController:

```swift
case .failure(let error):
    let title: String
    let message: String

    switch error {
    case .rateLimitExceeded:
        title = Strings.rateLimitTitle
        message = Strings.rateLimitMessage
    default:
        title = Strings.error
        message = error.localizedDescription
    }

    Utils.showAlertMessage(message, title: title, viewControler: self)
```

---

### Option B: Check HTTP Status Code (MORE INVASIVE)

**Approach**: Modify `HttpServiceProvider` to check status codes and return specific errors.

**Not Recommended Because**:
- More invasive changes across the codebase
- Would affect all API calls, not just password reset
- Backend already provides error messages in JSON
- Requires more extensive testing

---

## Testing Plan

### Test Case 1: Normal Rate Limit (Client-Side)

1. Open app → Tap "Forgot Password"
2. Enter email → Tap "Send"
3. Immediately tap "Send" again
4. **Expected**: Alert shows "Please wait X seconds before requesting again" (already working)

### Test Case 2: Backend Rate Limit (HTTP 429)

1. Trigger backend rate limit (make multiple requests quickly via API)
2. Open app → Tap "Forgot Password"
3. Enter email → Tap "Send"
4. **Expected**: Alert shows localized rate limit message, NOT "No se ha podido completar la operación"

### Test Case 3: Other Errors Still Work

1. Disconnect internet
2. Tap "Forgot Password" → Enter email → Tap "Send"
3. **Expected**: Generic connection error shown

---

## File Summary

### Files to Modify

1. **Localizable.strings** (Spanish)
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Supporting Files/Strings/es.lproj/Localizable.strings`
   - Change: Add `rateLimitTitle` and `rateLimitMessage` keys

2. **Localizable.strings** (English)
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Supporting Files/Strings/en.lproj/Localizable.strings`
   - Change: Add same rate limit keys

3. **Strings.swift**
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Resources/Strings.swift`
   - Change: Add `rateLimitTitle` and `rateLimitMessage` properties

4. **ForgotPasswordViewController.swift**
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/ForgotPassword/ForgotPasswordViewController.swift`
   - Change: Update `forgotPassword` method error handling (lines 162-174)

### Optional Files (Cleaner Approach)

5. **JTError.swift** (optional, cleaner architecture)
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/JTError.swift`
   - Change: Add `.rateLimitExceeded(String)` case

6. **API.swift** (optional, if updating JTError)
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/Network/API.swift`
   - Change: Update `processResult` to detect rate limit messages (line ~422)

---

## Implementation Priority

### Minimal Fix (Quick)

✅ **Add localization strings** (2 files)
✅ **Update Strings.swift** (1 file)
✅ **Update ForgotPasswordViewController** (1 file, ~15 lines)

**Total**: 3 files, ~30 lines of code

### Better Fix (Recommended)

All of the above PLUS:
✅ **Update JTError enum** (1 file, ~3 lines)
✅ **Update API.processResult** (1 file, ~5 lines)

**Total**: 5 files, ~50 lines of code

---

## Notes

1. **Client-side rate limit** (60s cooldown) is already implemented and working
2. **Backend already sends custom error messages** in JSON
3. The issue is that backend rate limit messages aren't being displayed to users
4. The fix is straightforward: detect rate limit errors and show proper UI
5. **No breaking changes** - only improved error handling

---

**Status**: Analysis complete, ready for implementation
**Recommendation**: Implement "Better Fix" approach for cleaner error handling architecture
