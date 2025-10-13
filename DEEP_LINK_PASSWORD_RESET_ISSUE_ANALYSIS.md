# Deep Link Password Reset Issue Analysis

## Problem Statement

When users click on the password reset deep link (`Jabrutouch://reset_password?type=reset_password&token=...&email=...`), they are redirected to the login page instead of the password reset screen.

Error message received: "Deep Link does not contain valid required params. URL params: {email, token, type}"

## File Paths

### Primary Files
- **AppDelegate**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Core/AppDelegate.swift`
- **ResetPasswordViewController**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/ResetPassword/ResetPasswordViewController.swift`
- **Storyboards Helper**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Resources/Storyboards.swift`
- **Info.plist**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Info.plist`

## Root Cause Analysis

### 1. Missing URL Handler Method

The app is **missing the modern iOS URL handler method** `application(_:open:options:)` which is required to handle custom URL schemes like `Jabrutouch://`.

**Current State:**
- The app has `application(_:continue:restorationHandler:)` which handles **Universal Links** (Firebase Dynamic Links)
- The app has `application(_:open:sourceApplication:annotation:)` (deprecated method) which only handles specific hosts like "crowns", "download", "gemara", "mishna"
- The app is **missing** `application(_:open:options:)` which is the modern method for custom URL schemes

### 2. Current Deep Link Handlers

#### Handler 1: Universal Links (Lines 125-155 in AppDelegate.swift)
```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let incomingURL = userActivity.webpageURL{
        let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL)
        { (dynamicLink, error)in
            // ... handles Firebase Dynamic Links
            if let dynamicLink = dynamicLink {
                self.handleIncomingDynamicLink(dynamicLink)
            }
        }
    }
}
```

**Purpose:** Handles Firebase Dynamic Links (Universal Links like `https://jabrutouch.page.link/...`)

#### Handler 2: Legacy Custom URL Scheme (Lines 167-189 in AppDelegate.swift)
```swift
func application(_ application: UIApplication, open url: URL,
                sourceApplication: String?, annotation: Any) -> Bool {

    if let host = url.host {
        let mainViewController = Storyboards.Main.mainViewController
        mainViewController.modalPresentationStyle = .fullScreen

        if host == "crowns" {
            // Handle crowns deep link
        } else if host == "download" {
            // Handle download deep link
        } else if host == "gemara" {
            // Handle gemara deep link
        } else if host == "mishna" {
            // Handle mishna deep link
        }
    }
    return true
}
```

**Issues with this handler:**
- This method is **deprecated** since iOS 9.0
- It only checks for specific hosts ("crowns", "download", "gemara", "mishna")
- It does **NOT** check for "reset_password" host
- It does **NOT** parse URL query parameters

### 3. The handleIncomingDynamicLink Method

Located at lines 73-122 in AppDelegate.swift:

```swift
func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){
    guard let url = dynamicLink.url else{
        print("My dynamic link obj has no url")
        return
    }

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

    // Existing deep link handlers require authentication
    if UserDefaultsProvider.shared.currentUser?.token == nil {
        let singinViewController = Storyboards.SignIn.signInViewController
        singinViewController.modalPresentationStyle = .fullScreen
        self.topmostViewController?.present(singinViewController, animated: false, completion: nil)
        return
    }
    // ... handle other deep link types
}
```

**This method ONLY gets called from Universal Links handler, NOT from custom URL schemes!**

### 4. URL Scheme Configuration

From Info.plist (lines 27-48):

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

**Configured URL Schemes:**
- `Jabrutouch://` - Custom URL scheme (capital J)
- `jabrutouch.page.link` - Firebase Dynamic Links scheme

## Why Users See Login Page

When a user clicks `Jabrutouch://reset_password?type=reset_password&token=...&email=...`:

1. iOS attempts to open the app with custom URL scheme `Jabrutouch://`
2. iOS looks for `application(_:open:options:)` method → **NOT FOUND**
3. iOS falls back to deprecated `application(_:open:sourceApplication:annotation:)` method
4. This method only checks `url.host` which would be "reset_password"
5. "reset_password" is not in the list of handled hosts ("crowns", "download", "gemara", "mishna")
6. Method returns `true` but does nothing
7. App opens at default state (login page if no user is logged in)

**The password reset logic in `handleIncomingDynamicLink` is NEVER executed** because:
- That method is only called from the Universal Links handler
- Custom URL schemes don't trigger Universal Links
- The custom URL scheme handler doesn't call `handleIncomingDynamicLink`

## The Missing Link

The app needs a modern URL handler that:
1. Accepts custom URL schemes (`Jabrutouch://`)
2. Parses query parameters from the URL
3. Routes to the appropriate handler based on the URL structure

## Solution

### Add Modern URL Handler Method

Add this method to AppDelegate.swift (around line 190, after the deprecated method):

```swift
// MARK: - Modern URL Scheme Handler (iOS 9.0+)
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("📱 Custom URL scheme received: \(url.absoluteString)")

    // Check if this is a Firebase Dynamic Link
    if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
        print("🔗 Processing as Firebase Dynamic Link")
        handleIncomingDynamicLink(dynamicLink)
        return true
    }

    // Handle direct custom URL schemes (Jabrutouch://...)
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
        print("⚠️  Failed to parse URL components")
        return false
    }

    // Parse query parameters
    var queryDict: [String: String] = [:]
    if let queryItems = components.queryItems {
        for item in queryItems {
            queryDict[item.name] = item.value ?? ""
        }
    }

    // Get the host or path as the action type
    let action = components.host ?? components.path.replacingOccurrences(of: "/", with: "")
    print("🎯 Deep link action: \(action)")
    print("📝 Query parameters: \(queryDict)")

    // Handle password reset deep link
    if action == "reset_password" || queryDict["type"] == "reset_password" {
        guard let token = queryDict["token"], !token.isEmpty else {
            print("⚠️  Password reset link missing token parameter")
            return false
        }
        print("🔐 Password reset deep link received with token")

        let resetPasswordViewController = Storyboards.ResetPassword.resetPasswordViewController
        resetPasswordViewController.resetToken = token
        resetPasswordViewController.userEmail = queryDict["email"]
        resetPasswordViewController.modalPresentationStyle = .fullScreen
        self.topmostViewController?.present(resetPasswordViewController, animated: true, completion: nil)
        return true
    }

    // Handle other custom URL scheme hosts
    let mainViewController = Storyboards.Main.mainViewController
    mainViewController.modalPresentationStyle = .fullScreen

    switch action {
    case "crowns":
        self.topmostViewController?.present(mainViewController, animated: false, completion: nil)
        mainViewController.presentDonation()
        return true

    case "download":
        self.topmostViewController?.present(mainViewController, animated: false, completion: nil)
        mainViewController.presentDownloadsViewController()
        return true

    case "gemara":
        self.topmostViewController?.present(mainViewController, animated: false, completion: nil)
        mainViewController.presentAllGemara()
        return true

    case "mishna":
        self.topmostViewController?.present(mainViewController, animated: false, completion: nil)
        mainViewController.presentAllMishna()
        return true

    default:
        print("⚠️  Unhandled deep link action: \(action)")
        return false
    }
}
```

### Update Deprecated Method (Optional)

The old deprecated method at line 167 can be updated to call the new method:

```swift
func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    // Delegate to modern handler
    return self.application(application, open: url, options: [:])
}
```

## Expected URL Format

The deep link should work with either format:

### Format 1: Host-based (RECOMMENDED)
```
Jabrutouch://reset_password?token=abc123xyz&email=user@example.com&type=reset_password
```

- Scheme: `Jabrutouch://`
- Host: `reset_password`
- Query parameters: `token`, `email`, `type`

### Format 2: Query-based (FALLBACK)
```
Jabrutouch://?type=reset_password&token=abc123xyz&email=user@example.com
```

- Scheme: `Jabrutouch://`
- No host
- Query parameters: `type`, `token`, `email`

## Testing

### Test in Simulator
```bash
# Test password reset
xcrun simctl openurl booted "Jabrutouch://reset_password?token=test123&email=test@example.com"

# Test other deep links
xcrun simctl openurl booted "Jabrutouch://crowns"
xcrun simctl openurl booted "Jabrutouch://download"
```

### Test on Device
1. Send the deep link URL via email or message
2. Click the link on the device
3. App should open and present ResetPasswordViewController

## Additional Considerations

### 1. Case Sensitivity
- URL scheme in Info.plist: `Jabrutouch` (capital J)
- URLs are case-insensitive for scheme: `jabrutouch://` will work same as `Jabrutouch://`
- Host is case-sensitive by default: `reset_password` vs `Reset_Password`

### 2. Firebase Dynamic Links
- The new handler checks for Firebase Dynamic Links first
- This maintains backward compatibility with existing Universal Links
- Firebase Dynamic Links can wrap custom URL schemes

### 3. URL Query Parameter Parsing
- The new implementation uses `URLComponents` and `queryItems`
- This is more robust than manual string splitting
- Handles URL encoding/decoding automatically
- Handles edge cases like missing values or malformed URLs

### 4. Error Handling
- Returns `false` if URL cannot be handled
- Logs warnings for debugging
- Gracefully handles missing parameters

## Summary

**Problem:** Missing modern URL handler method causes custom URL schemes to fail

**Solution:** Add `application(_:open:options:)` method that:
1. Checks for Firebase Dynamic Links first
2. Parses custom URL schemes with query parameters
3. Routes password reset links to ResetPasswordViewController
4. Maintains existing functionality for other deep links

**Files to Modify:**
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Core/AppDelegate.swift`
  - Add new method after line 189
  - Optionally update deprecated method at line 167

**No other files need modification** - the ResetPasswordViewController and Storyboards helper are already correctly implemented.
