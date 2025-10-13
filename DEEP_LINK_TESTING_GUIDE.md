# Deep Link Testing Guide - Password Reset Fix

## Overview

This guide provides step-by-step instructions for testing the password reset deep link functionality after implementing the fix in AppDelegate.swift.

## What Was Fixed

Added the modern iOS URL handler method `application(_:open:options:)` to properly handle custom URL schemes like `Jabrutouch://reset_password`.

**Files Modified:**
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Core/AppDelegate.swift`

## Testing Prerequisites

1. Build and install the app on a device or simulator
2. Ensure the backend is generating password reset links with the correct format

## Expected URL Formats

The fix supports both formats:

### Format 1: Host-based (Recommended)
```
Jabrutouch://reset_password?token=abc123xyz&email=user@example.com
```

### Format 2: Query-based (Fallback)
```
Jabrutouch://?type=reset_password&token=abc123xyz&email=user@example.com
```

### Format 3: With type parameter (Backward compatible)
```
Jabrutouch://reset_password?type=reset_password&token=abc123xyz&email=user@example.com
```

## Testing Methods

### Method 1: iOS Simulator Testing

1. **Build and run the app in Xcode**
   ```bash
   # Open the project
   cd /Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios
   open Jabrutouch.xcworkspace
   ```

2. **Run the app in simulator**
   - Select a simulator (e.g., iPhone 15)
   - Click Run (⌘R)

3. **Open Terminal and test the deep link**
   ```bash
   # Test password reset with all parameters
   xcrun simctl openurl booted "Jabrutouch://reset_password?token=test123&email=test@example.com"

   # Test with type parameter (backward compatible)
   xcrun simctl openurl booted "Jabrutouch://reset_password?type=reset_password&token=test123&email=test@example.com"

   # Test without host (fallback format)
   xcrun simctl openurl booted "Jabrutouch://?type=reset_password&token=test123&email=test@example.com"
   ```

4. **Expected Results:**
   - App should open (or come to foreground)
   - ResetPasswordViewController should be presented
   - You should see the password reset screen with two password fields
   - Console should show: "🔐 Password reset deep link received with token"

### Method 2: Physical Device Testing

#### Option A: Using Safari
1. **Create a test HTML file** (save as `test-deeplink.html`):
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>JabruTouch Deep Link Test</title>
       <meta name="viewport" content="width=device-width, initial-scale=1">
       <style>
           body { font-family: -apple-system; padding: 20px; }
           a { display: block; margin: 20px 0; padding: 15px; background: #007AFF; color: white; text-decoration: none; border-radius: 8px; text-align: center; }
       </style>
   </head>
   <body>
       <h1>JabruTouch Deep Link Tests</h1>

       <h2>Password Reset Links</h2>
       <a href="Jabrutouch://reset_password?token=test123&email=test@example.com">
           Test 1: Host-based format
       </a>

       <a href="Jabrutouch://reset_password?type=reset_password&token=test456&email=user@test.com">
           Test 2: Host-based with type parameter
       </a>

       <a href="Jabrutouch://?type=reset_password&token=test789&email=another@test.com">
           Test 3: Query-based format
       </a>

       <h2>Other Deep Links (Should still work)</h2>
       <a href="Jabrutouch://crowns">Test Crowns/Donation</a>
       <a href="Jabrutouch://download">Test Downloads</a>
       <a href="Jabrutouch://gemara">Test Gemara</a>
       <a href="Jabrutouch://mishna">Test Mishna</a>
   </body>
   </html>
   ```

2. **Host the file locally or use AirDrop**
   - Send to device via AirDrop
   - Or host on local server: `python3 -m http.server 8000`
   - Access from device: `http://YOUR_IP:8000/test-deeplink.html`

3. **Click the links** and verify the app opens correctly

#### Option B: Using Notes App
1. Open Notes app on iPhone/iPad
2. Create a new note
3. Type the deep link URL:
   ```
   Jabrutouch://reset_password?token=test123&email=test@example.com
   ```
4. Long press the URL and select "Open"
5. App should launch with password reset screen

#### Option C: Using Messages App
1. Send yourself an iMessage with the deep link URL
2. Tap the link in the message
3. App should open with password reset screen

### Method 3: Email Testing (Production-like)

1. **Trigger a real password reset** from your backend
2. **Check the email** on your device
3. **Click the password reset link**
4. **Verify** the app opens with the reset password screen

## Expected Console Output

When the deep link is opened successfully, you should see:

```
📱 Custom URL scheme received: Jabrutouch://reset_password?token=test123&email=test@example.com
🎯 Deep link action: reset_password
📝 Query parameters: ["token": "test123", "email": "test@example.com"]
🔐 Password reset deep link received with token
```

## Testing Checklist

- [ ] Deep link opens the app from background
- [ ] Deep link opens the app when app is closed
- [ ] ResetPasswordViewController is presented
- [ ] Password fields are visible and functional
- [ ] Token is correctly passed to the view controller
- [ ] Email is correctly passed to the view controller (if provided)
- [ ] User can enter new password
- [ ] User can confirm password
- [ ] Reset button is functional
- [ ] Success screen appears after successful reset
- [ ] Error messages display for invalid tokens
- [ ] Other deep links still work (crowns, download, gemara, mishna)

## Common Issues and Solutions

### Issue 1: "No application knows how to open URL"
**Cause:** App is not installed or URL scheme is not registered

**Solution:**
- Verify app is installed on device/simulator
- Check Info.plist has `Jabrutouch` URL scheme registered
- Clean build folder and rebuild: Product → Clean Build Folder (⇧⌘K)

### Issue 2: App opens but shows login page instead of password reset
**Cause:** URL handler is not being called or parameters are not being parsed

**Solution:**
- Check console logs for "📱 Custom URL scheme received"
- If no log appears, the handler is not being called
- Verify the method signature matches exactly:
  ```swift
  func application(_ app: UIApplication, open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
  ```

### Issue 3: Console shows "Failed to parse URL components"
**Cause:** Malformed URL

**Solution:**
- Verify URL format is correct
- Ensure no spaces or invalid characters
- URL-encode special characters if needed

### Issue 4: Console shows "Missing token parameter"
**Cause:** Token is not in the URL or is empty

**Solution:**
- Check the backend is generating URLs with the token parameter
- Verify URL format: `Jabrutouch://reset_password?token=ACTUAL_TOKEN`

## Debug Tips

### Enable Verbose Logging

The implementation already includes print statements. To see them:

1. **In Xcode:**
   - Open Console (⌘⇧C)
   - Run the app
   - Filter by "📱" or "Deep link"

2. **For more detailed logging, add these lines in AppDelegate:**
   ```swift
   // Add at the beginning of application(_:open:options:)
   print("🔍 DEBUG - URL components:")
   print("   Scheme: \(components.scheme ?? "none")")
   print("   Host: \(components.host ?? "none")")
   print("   Path: \(components.path)")
   print("   Query: \(components.query ?? "none")")
   ```

### Test Invalid Scenarios

Test error handling with these invalid URLs:

```bash
# Missing token
xcrun simctl openurl booted "Jabrutouch://reset_password?email=test@example.com"

# Empty token
xcrun simctl openurl booted "Jabrutouch://reset_password?token=&email=test@example.com"

# Unknown action
xcrun simctl openurl booted "Jabrutouch://unknown_action?param=value"
```

Expected behaviors:
- Missing/empty token: Console shows "⚠️  Password reset link missing token parameter"
- Unknown action: Console shows "⚠️  Unhandled deep link action: unknown_action"

## Integration with Backend

### Backend URL Generation

Ensure your backend generates URLs in this format:

**Python/Django Example:**
```python
reset_link = f"Jabrutouch://reset_password?token={token}&email={user.email}"
```

**Laravel Example:**
```php
$resetLink = "Jabrutouch://reset_password?token={$token}&email={$user->email}";
```

**Node.js Example:**
```javascript
const resetLink = `Jabrutouch://reset_password?token=${token}&email=${user.email}`;
```

### Email Template

The email should contain an HTML link like this:

```html
<a href="Jabrutouch://reset_password?token={{token}}&email={{email}}">
    Reset Your Password
</a>
```

Or as a clickable URL:
```
Click here to reset your password:
Jabrutouch://reset_password?token={{token}}&email={{email}}
```

## Rollback Plan

If the fix causes issues, you can revert the changes:

1. **Locate the git commit before the changes**
2. **Revert AppDelegate.swift:**
   ```bash
   git checkout HEAD~1 -- Jabrutouch/App/Core/AppDelegate.swift
   ```
3. **Or manually remove the new method** and restore the old one

## Success Criteria

The fix is successful when:

1. ✅ User clicks password reset link in email
2. ✅ App opens (or comes to foreground)
3. ✅ ResetPasswordViewController is displayed
4. ✅ User can enter new password
5. ✅ User can confirm password
6. ✅ Success message appears after reset
7. ✅ User can log in with new password
8. ✅ Other deep links continue to work

## Next Steps After Testing

1. **If tests pass:**
   - Deploy to TestFlight for beta testing
   - Monitor crash reports and user feedback
   - Roll out to production

2. **If tests fail:**
   - Review console logs for error messages
   - Check the analysis document for additional troubleshooting
   - Verify URL format matches expected patterns
   - Test on different iOS versions

## Support Files

- **Analysis Document:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/DEEP_LINK_PASSWORD_RESET_ISSUE_ANALYSIS.md`
- **Modified File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Core/AppDelegate.swift`
- **ResetPasswordViewController:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/ResetPassword/ResetPasswordViewController.swift`
