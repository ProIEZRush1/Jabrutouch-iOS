# Deep Link Navigation Fix - Implementation Guide

## Quick Summary

**Problem:** Password reset deep link presents ResetPasswordViewController modally, but SplashScreen then replaces the root view controller, dismissing it.

**Solution:** Store deep link parameters and process them after SplashScreen completes navigation.

## Step-by-Step Implementation

### Step 1: Modify AppDelegate.swift

Add property to store pending deep link (after line 25):

```swift
var isInternetConenect: Bool = true

// ADD THIS:
var pendingPasswordResetDeepLink: (token: String, email: String?)? = nil
```

### Step 2: Modify Deep Link Handler in AppDelegate.swift

Replace the password reset handler in `handleIncomingDynamicLink` method (lines 82-96):

**FIND:**
```swift
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
```

**REPLACE WITH:**
```swift
// Handle password reset deep link (doesn't require authentication)
if type == "reset_password" {
    guard let token = url1["token"] else {
        print("⚠️  Password reset link missing token parameter")
        return
    }
    print("🔐 Password reset deep link received - storing for after launch")
    print("🔐 Token: \(token)")
    if let email = url1["email"] {
        print("🔐 Email: \(email)")
    }

    // Store the deep link parameters to process after app finishes launching
    self.pendingPasswordResetDeepLink = (token: token, email: url1["email"])
    return
}
```

### Step 3: Add Processing Method to AppDelegate.swift

Add this new method after the `handleIncomingDynamicLink` method (around line 122):

```swift
// MARK: - Process Pending Deep Links

func processPendingPasswordResetDeepLink() {
    guard let deepLink = pendingPasswordResetDeepLink else {
        print("🔐 No pending password reset deep link")
        return
    }

    print("🔐 Processing pending password reset deep link")
    print("🔐 Token: \(deepLink.token)")

    // Small delay to ensure the view controller is ready
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        guard let self = self else { return }

        let resetPasswordViewController = Storyboards.ResetPassword.resetPasswordViewController
        resetPasswordViewController.resetToken = deepLink.token
        resetPasswordViewController.userEmail = deepLink.email
        resetPasswordViewController.modalPresentationStyle = .fullScreen

        self.topmostViewController?.present(resetPasswordViewController, animated: true) {
            print("✅ ResetPasswordViewController presented successfully")
            // Clear the pending deep link after presenting
            self.pendingPasswordResetDeepLink = nil
        }
    }
}
```

### Step 4: Modify SplashScreenViewController.swift

In the `navigateToSignIn()` method (around line 173), add the call to process pending deep link:

**FIND:**
```swift
private func navigateToSignIn() {
    let signInViewController = Storyboards.SignIn.signInViewController
    appDelegate.setRootViewController(viewController: signInViewController, animated: true)

}
```

**REPLACE WITH:**
```swift
private func navigateToSignIn() {
    let signInViewController = Storyboards.SignIn.signInViewController
    appDelegate.setRootViewController(viewController: signInViewController, animated: true)

    // Process any pending password reset deep link
    appDelegate.processPendingPasswordResetDeepLink()
}
```

## Testing Checklist

After implementing the changes, test these scenarios:

### Test 1: Cold Start with Deep Link
1. ✅ Kill the app completely (swipe away from app switcher)
2. ✅ Click password reset link from email
3. ✅ App should open and show ResetPasswordViewController on top of SignIn screen
4. ✅ Enter new password and confirm
5. ✅ Should see success message

### Test 2: App in Background
1. ✅ Have app running in background
2. ✅ Click password reset link from email
3. ✅ App should come to foreground
4. ✅ Should show ResetPasswordViewController

### Test 3: App Already on SignIn Screen
1. ✅ Have app open on SignIn screen
2. ✅ Click password reset link (from another device or Safari)
3. ✅ Should show ResetPasswordViewController modally

### Test 4: Network Conditions
1. ✅ Test with WiFi
2. ✅ Test with cellular data
3. ✅ Test with slow connection
4. ✅ Ensure ResetPasswordViewController appears in all cases

### Test 5: Invalid Token
1. ✅ Use expired/invalid token
2. ✅ ResetPasswordViewController should appear
3. ✅ After entering password, should show error from backend

### Test 6: Cancel/Dismiss
1. ✅ Open via deep link
2. ✅ Tap X button to dismiss
3. ✅ Should return to SignIn screen
4. ✅ Should be able to login normally

## Verification in Logs

When testing, you should see this sequence in Xcode console:

```
🔐 Password reset deep link received - storing for after launch
🔐 Token: <token_string>
🔐 Email: user@example.com
...
🔐 Processing pending password reset deep link
🔐 Token: <token_string>
✅ ResetPasswordViewController presented successfully
```

If you see these logs but the screen doesn't appear, the issue is elsewhere (likely view hierarchy).

## Rollback Plan

If this fix doesn't work or causes issues, you can easily revert:

1. Remove the `pendingPasswordResetDeepLink` property from AppDelegate
2. Restore the original deep link handler (present immediately)
3. Remove the call to `processPendingPasswordResetDeepLink()` from SplashScreen
4. Delete the `processPendingPasswordResetDeepLink()` method

## Why This Works

**Before Fix:**
```
1. Deep link received → Present ResetPasswordVC
2. SplashScreen finishes → setRootViewController()
3. ResetPasswordVC dismissed (because root changed)
4. User sees SignIn (appears broken)
```

**After Fix:**
```
1. Deep link received → Store parameters
2. SplashScreen finishes → setRootViewController(SignIn)
3. SignIn becomes root and is visible
4. Process stored deep link → Present ResetPasswordVC
5. User sees ResetPasswordVC (works correctly!)
```

The key difference: We wait for the root view controller to stabilize before presenting modally.

## Additional Notes

### Why Not Use Notification Pattern?

We could use NotificationCenter to broadcast when SplashScreen completes, but this approach is simpler and more direct. The SplashScreen already knows when it's navigating to SignIn, so it can trigger the deep link processing directly.

### Why the 0.3 Second Delay?

The `asyncAfter` delay in `processPendingPasswordResetDeepLink()` ensures:
1. The SignIn view controller is fully loaded in memory
2. The transition animation from SplashScreen has completed
3. The view hierarchy is stable for modal presentation

This small delay is imperceptible to users but prevents edge cases where the VC isn't ready.

### Thread Safety

The `[weak self]` capture in the async block prevents retain cycles and ensures the AppDelegate can be deallocated if needed (though it typically lives for the app's lifetime).

## Alternative: If You Want Instant Presentation

If you want the password reset screen to appear immediately without seeing SignIn first:

Modify `navigateToSignIn()` to:

```swift
private func navigateToSignIn() {
    let signInViewController = Storyboards.SignIn.signInViewController

    // Check if there's a pending password reset before setting root
    if appDelegate.pendingPasswordResetDeepLink != nil {
        // Set SignIn as root but don't animate
        appDelegate.setRootViewController(viewController: signInViewController, animated: false)
        // Then immediately show password reset
        appDelegate.processPendingPasswordResetDeepLink()
    } else {
        // Normal sign-in navigation
        appDelegate.setRootViewController(viewController: signInViewController, animated: true)
    }
}
```

This skips the SignIn animation and shows password reset immediately, giving users the impression they went straight to password reset from the link.
