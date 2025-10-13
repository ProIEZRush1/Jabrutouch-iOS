# Password Reset Email Link Implementation - Complete Analysis

**Date:** October 12, 2025
**Project:** JabruTouch iOS App
**Purpose:** Plan and implement password reset via clickable email link

---

## Executive Summary

This document provides comprehensive analysis of the email infrastructure and URL handling patterns across the JabruTouch system (Django backend, Laravel backend, iOS app) to implement secure password reset functionality via email links.

**Current State:** Password reset sends new password directly in plain text email
**Target State:** Password reset sends secure, time-limited link that opens app to reset password

---

## Table of Contents

1. [Email Infrastructure Analysis](#1-email-infrastructure-analysis)
2. [Current Password Reset Implementation](#2-current-password-reset-implementation)
3. [iOS Deep Linking Infrastructure](#3-ios-deep-linking-infrastructure)
4. [Recommended Implementation](#4-recommended-implementation)
5. [Implementation Plan](#5-implementation-plan)
6. [Security Considerations](#6-security-considerations)
7. [Testing Strategy](#7-testing-strategy)

---

## 1. Email Infrastructure Analysis

### 1.1 Django Backend (Legacy - Currently Active)

**Email Service Configuration:**
- **Method**: `django.core.mail.send_mail` and `django.core.mail.EmailMultiAlternatives`
- **SMTP**: Configured via environment variables
- **From Address**: `Jabrutouch <${EMAIL_HOST_USER}>`

**Existing Email Template System:**

Location: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_server/jabrutouch_server/jabrutouch_api/utils.py` (lines 55-64)

```python
def send_mail_with_html_template(full_name: str, mail_address: str,
                                 template_name: str, subject: str,
                                 preview_text: str, **kwargs):
    msg_html = render_to_string(template_name,
        {'full_name': full_name,
         'preview_text': preview_text,
         **kwargs})
    email = EmailMultiAlternatives(
        subject=subject,
        body='',
        from_email=f'Jabrutouch <{settings.EMAIL_HOST_USER}>',
        to=[mail_address],
    )
    email.attach_alternative(msg_html, "text/html")
    email.send()
```

**Template Location:**
`/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_server/jabrutouch_server/jabrutouch_api/templates/`

**Existing Email Templates:**
- `welcome_email.html` - New user welcome
- `complete_payment.html` - Payment notifications
- `rns_week_1.html` through `rns_week_11.html` - Campaign emails
- `rns_month_3.html` - Monthly campaigns
- `meguila_campaign_email.html` - Special campaigns
- `coupon_report.html`, `coupon_payment1.html` - Coupon notifications

**Template Pattern:**
- HTML-based with Django template syntax
- Supports context variables: `full_name`, `preview_text`, custom kwargs
- Uses `render_to_string()` for rendering
- Multi-part email (HTML + plain text fallback)

### 1.2 Laravel Backend (Development - tashema-back)

**Email Configuration:**

Location: `/Users/ech/Documents/Programacion/jabrutouch/tashema-back/config/mail.php`

```php
'default' => env('MAIL_MAILER', 'log'),

'from' => [
    'address' => env('MAIL_FROM_ADDRESS', 'hello@example.com'),
    'name' => env('MAIL_FROM_NAME', 'Example'),
],
```

**Available Mailers:**
- SMTP (production)
- Sendmail
- Mailgun
- SES
- Postmark
- Resend
- Log (development)

**Built-in Password Reset:**

Location: `/Users/ech/Documents/Programacion/jabrutouch/tashema-back/vendor/laravel/framework/src/Illuminate/Auth/Notifications/ResetPassword.php`

Laravel includes complete password reset infrastructure:
- `password_reset_tokens` table (already exists in migration)
- Built-in notification class with customizable URL
- Token generation with expiration (default 60 minutes)
- Email template customization via callbacks

**Database Schema (already exists):**
```php
Schema::create('password_reset_tokens', function (Blueprint $table) {
    $table->string('email')->primary();
    $table->string('token');
    $table->timestamp('created_at')->nullable();
});
```

---

## 2. Current Password Reset Implementation

### 2.1 Backend Implementation (Django)

**Endpoint:** `POST /reset_password/`

Location: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_server/jabrutouch_server/jabrutouch_api/login_process.py` (lines 190-209)

```python
@api_view(["POST"])
@permission_classes((AllowAny,))
def reset_password(request):
    ResetPasswordSerializer(data=request.data).is_valid(raise_exception=True)
    user = User.objects.filter(email=request.data['email']).first()
    if user:
        new_password = generate_password()  # 4-digit random number
        user.set_password(new_password)
        user.save()
        send_mail(
            'Tu contraseña',
            f"Hola {user.first_name}, tu nueva contraseña es {new_password}",
            f'Jabrutouch <{settings.EMAIL_HOST_USER}>',
            [user.email],
            fail_silently=False,
        )
        return Response({
            "user_exist_status": True,
            "message": "mail has bin send"
        })
    else:
        return Response({
            "user_exist_status": False,
            "message": "User doesn't exist in system..."
        })
```

**Critical Issues:**
1. ❌ Password reset happens immediately (no confirmation)
2. ❌ Plain text password sent via email
3. ❌ No token-based validation
4. ❌ No expiration mechanism
5. ❌ User enumeration vulnerability (`user_exist_status`)
6. ❌ Password sent in clear text over email

### 2.2 iOS Implementation

**Request Creation:**

Location: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/Network/HTTPRequestFactory.swift` (lines 73-81)

```swift
class func forgotPasswordRequest(email: String?) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    if email == nil { return nil }
    let link = baseUrl.appendingPathComponent("reset_password/").absoluteString
    let body: [String:Any] = ["email": email ?? ""]
    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(url, method: .post, body: body,
                                     additionalHeaders: nil)
    return request
}
```

**Response Model:**

Location: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Network/API Response models/ForgotPasswordResponse.swift`

```swift
struct ForgotPasswordResponse: APIResponseModel {
    let message: String
    let status: Bool

    init?(values: [String : Any]) {
        self.message = values["message"] as? String
        self.status = values["user_exist_status"] as? Bool
    }
}
```

**UI Controller:**

Location: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/ForgotPassword/ForgotPasswordViewController.swift`

Current Flow:
1. User enters email → Shows loading
2. Calls API → Receives response
3. Shows success/error based on `user_exist_status`
4. User dismisses modal

---

## 3. iOS Deep Linking Infrastructure

### 3.1 URL Schemes Configuration

**Location:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Info.plist` (lines 27-49)

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

**Configured Schemes:**
- `Jabrutouch://` - Primary custom scheme
- `jabrutouch.page.link://` - Deep link scheme

### 3.2 Universal Links Configuration

**Entitlements:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Jabrutouch.entitlements`

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:jabrutouch.page.link</string>
</array>
```

**Status:**
- ✅ Domain configured: `jabrutouch.page.link`
- ❌ No `apple-app-site-association` file found in repository
- ⚠️ Needs server-side configuration

### 3.3 Deep Link Handling (AppDelegate)

**Location:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Core/AppDelegate.swift`

**Custom URL Scheme Handler** (lines 149-171):

```swift
func application(_ application: UIApplication, open url: URL,
                sourceApplication: String?, annotation: Any) -> Bool {
    if let host = url.host {
        let mainViewController = Storyboards.Main.mainViewController
        mainViewController.modalPresentationStyle = .fullScreen

        if host == "crowns" {
            // Opens donation screen
        } else if host == "download" {
            // Opens downloads
        } else if host == "gemara" {
            // Opens Gemara list
        } else if host == "mishna" {
            // Opens Mishna list
        }
    }
    return true
}
```

**Supported Deep Links:**
- `jabrutouch://crowns` → Donation screen
- `jabrutouch://download` → Downloads view
- `jabrutouch://gemara` → Gemara content
- `jabrutouch://mishna` → Mishna content

**Universal Links Handler** (lines 107-137):

```swift
func application(_ application: UIApplication,
                continue userActivity: NSUserActivity,
                restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let incomingURL = userActivity.webpageURL {
        let linkHandled = DynamicLinks.dynamicLinks()
            .handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else { return }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
        return linkHandled
    }
    return false
}
```

**Dynamic Link Processing** (lines 73-104):

```swift
func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
    guard let url = dynamicLink.url else { return }

    // Check authentication
    if UserDefaultsProvider.shared.currentUser?.token == nil {
        // Show sign-in screen
        return
    }

    guard let url1 = url.queryDictionary else { return }
    let type = url1["type"]

    if type == "coupon" {
        // Handle coupon deep link
        guard let values = JTDeepLinkCoupone(values: url1) else { return }
        mainViewController.couponeFromDeepLink(values: values)
    } else {
        // Handle lesson deep link
        guard let values = JTDeepLinkLesson(values: url1) else { return }
        mainViewController.lessonFromDeepLink(values)
    }
}
```

### 3.4 Existing Deep Link Models

**Lesson Deep Link:** `JTDeepLinkLesson.swift`

Query Parameters:
- `type` - Link type
- `seder` - Order
- `masechet` - Tractate ID
- `page` - Page number
- `video` - Video ID
- `masechet_name` - Tractate name
- `gemara` - Is Gemara (1/0)
- `mishna` - Mishna number
- `chapter` - Chapter number
- `duration` - Start position

**Coupon Deep Link:** `JTDeepLinkCoupone.swift`

Query Parameters:
- `type` - "coupon"
- `coupon_distributor` - Distributor
- `coupon_title` - Title
- `coupon_sum` - Amount

---

## 4. Recommended Implementation

### 4.1 URL Format Options

#### Option A: Custom URL Scheme ⚡ (Quickest)

**Format:** `jabrutouch://reset-password?token=ABC123&email=user@example.com`

**Pros:**
- ✅ Quick implementation
- ✅ No server configuration
- ✅ Works immediately
- ✅ Already configured in Info.plist

**Cons:**
- ❌ Browser confirmation dialog
- ❌ Less secure
- ❌ No web fallback

#### Option B: Universal Links 🏆 (Recommended)

**Format:** `https://jabrutouch.page.link/reset-password?token=ABC123&email=user@example.com`

**Pros:**
- ✅ Seamless UX (no browser prompt)
- ✅ Secure HTTPS
- ✅ Web fallback if app not installed
- ✅ Industry standard
- ✅ Better user trust

**Cons:**
- ❌ Requires server configuration
- ❌ Need `apple-app-site-association` file
- ❌ More complex setup

**Server Requirements:**
1. Host file at: `https://jabrutouch.page.link/.well-known/apple-app-site-association`
2. File format:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.il.co.jabrutouch.Jabrutouch",
        "paths": ["/reset-password", "/reset-password/*"]
      }
    ]
  }
}
```

#### Option C: Hybrid Approach 🎯 (Best Practice)

**Implementation:**
1. Primary: Universal Links (production)
2. Fallback: Custom URL scheme (development/testing)
3. Web page: Password reset form (non-app users)

---

### 4.2 Complete Password Reset Flow

```
┌─────────────────────────────────────────────────────────────┐
│                 Password Reset Flow (Secure)                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. User enters email in app                                 │
│         ↓                                                    │
│  2. POST /api/request-password-reset/                        │
│         ↓                                                    │
│  3. Backend:                                                 │
│     • Validate email exists                                  │
│     • Generate secure token (32-byte)                        │
│     • Store in DB with expiry (1 hour)                       │
│     • Build reset URL with token                             │
│     • Send HTML email                                        │
│         ↓                                                    │
│  4. User receives email                                      │
│         ↓                                                    │
│  5. User clicks reset link                                   │
│         ↓                                                    │
│  6. iOS handles deep link:                                   │
│     • App opens (if installed)                               │
│     • OR web page (if not installed)                         │
│         ↓                                                    │
│  7. POST /api/validate-reset-token/                          │
│         ↓                                                    │
│  8. If valid:                                                │
│     • Show reset password screen                             │
│     • User enters new password                               │
│         ↓                                                    │
│  9. POST /api/confirm-password-reset/                        │
│         ↓                                                    │
│  10. Password updated, token marked used                     │
│         ↓                                                    │
│  11. Success → Navigate to login                             │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Implementation Plan

### 5.1 Phase 1: Backend Token System (Django)

#### Step 1.1: Create Database Model

**File:** Create `jabrutouch_server/jabrutouch_server/jabrutouch_api/models.py` (add to existing)

```python
class PasswordResetToken(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='password_reset_tokens'
    )
    token = models.CharField(max_length=100, unique=True, db_index=True)
    email = models.EmailField()
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'password_reset_tokens'
        ordering = ['-created_at']

    def is_valid(self):
        from django.utils import timezone
        return not self.used and timezone.now() < self.expires_at

    def mark_used(self):
        from django.utils import timezone
        self.used = True
        self.used_at = timezone.now()
        self.save()
```

**Migration:**
```bash
cd jabrutouch_server/jabrutouch_server
python manage.py makemigrations
python manage.py migrate
```

#### Step 1.2: Create Request Password Reset Endpoint

**File:** Update `jabrutouch_server/jabrutouch_server/jabrutouch_api/login_process.py`

```python
import secrets
from datetime import timedelta
from django.utils import timezone
from jabrutouch_api.models import PasswordResetToken

@api_view(["POST"])
@permission_classes((AllowAny,))
def request_password_reset(request):
    """
    Send password reset email with secure token link
    """
    email = request.data.get('email')

    # Always return success to prevent user enumeration
    generic_response = {
        'success': True,
        'message': 'Si existe una cuenta con este correo, recibirás un enlace para restablecer tu contraseña.'
    }

    # Try to find user
    user = User.objects.filter(email=email).first()

    if user:
        # Generate secure token
        token = secrets.token_urlsafe(32)
        expiry = timezone.now() + timedelta(hours=1)

        # Clean old tokens for this user
        PasswordResetToken.objects.filter(user=user).delete()

        # Create new token
        PasswordResetToken.objects.create(
            user=user,
            token=token,
            email=email,
            expires_at=expiry
        )

        # Build reset URL (universal link)
        reset_url = f"https://jabrutouch.page.link/reset-password?token={token}&email={email}"

        # Send email
        try:
            send_mail_with_html_template(
                full_name=user.first_name,
                mail_address=user.email,
                template_name='password_reset_email.html',
                subject='Restablecer tu contraseña - Jabrutouch',
                preview_text='Haz clic para restablecer tu contraseña de forma segura',
                reset_url=reset_url,
                expiry_hours=1
            )
            print(f"✅ Password reset email sent to {email}")
        except Exception as e:
            print(f"❌ Failed to send email to {email}: {e}")
    else:
        print(f"⚠️  Password reset requested for non-existent email: {email}")

    return Response(generic_response)
```

#### Step 1.3: Create Token Validation Endpoint

```python
@api_view(["POST"])
@permission_classes((AllowAny,))
def validate_reset_token(request):
    """
    Validate password reset token
    """
    token = request.data.get('token')
    email = request.data.get('email')

    try:
        reset_token = PasswordResetToken.objects.get(
            token=token,
            email=email,
            used=False,
            expires_at__gt=timezone.now()
        )

        return Response({
            'valid': True,
            'user_id': reset_token.user.id,
            'email': reset_token.user.email,
            'first_name': reset_token.user.first_name
        })
    except PasswordResetToken.DoesNotExist:
        return Response({
            'valid': False,
            'error': 'Token inválido o expirado'
        }, status=400)
```

#### Step 1.4: Create Password Reset Confirmation Endpoint

```python
@api_view(["POST"])
@permission_classes((AllowAny,))
def confirm_password_reset(request):
    """
    Complete password reset with token validation
    """
    token = request.data.get('token')
    email = request.data.get('email')
    new_password = request.data.get('new_password')

    # Validate password strength
    if len(new_password) < 6:
        return Response({
            'success': False,
            'error': 'La contraseña debe tener al menos 6 caracteres'
        }, status=400)

    try:
        reset_token = PasswordResetToken.objects.get(
            token=token,
            email=email,
            used=False,
            expires_at__gt=timezone.now()
        )

        # Update password
        user = reset_token.user
        user.set_password(new_password)
        user.save()

        # Mark token as used
        reset_token.mark_used()

        # Send confirmation email
        send_mail(
            'Contraseña actualizada - Jabrutouch',
            f'Hola {user.first_name},\n\nTu contraseña ha sido actualizada exitosamente.',
            f'Jabrutouch <{settings.EMAIL_HOST_USER}>',
            [user.email],
            fail_silently=True
        )

        print(f"✅ Password reset completed for {email}")

        return Response({
            'success': True,
            'message': 'Contraseña actualizada exitosamente'
        })

    except PasswordResetToken.DoesNotExist:
        return Response({
            'success': False,
            'error': 'Token inválido o expirado'
        }, status=400)
```

#### Step 1.5: Update URL Routes

**File:** `jabrutouch_server/jabrutouch_server/jabrutouch_server/urls.py`

```python
urlpatterns = [
    # ... existing urls ...
    path('api/request-password-reset/', request_password_reset),
    path('api/validate-reset-token/', validate_reset_token),
    path('api/confirm-password-reset/', confirm_password_reset),
]
```

#### Step 1.6: Create Email Template

**File:** Create `jabrutouch_server/jabrutouch_server/jabrutouch_api/templates/password_reset_email.html`

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restablecer Contraseña - Jabrutouch</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f4; padding: 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="background-color: #4CAF50; padding: 30px 20px; text-align: center;">
                            <h1 style="color: #ffffff; margin: 0; font-size: 28px;">Jabrutouch</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <h2 style="color: #333333; margin: 0 0 20px 0;">Restablecer tu contraseña</h2>

                            <p style="color: #666666; line-height: 1.6; margin: 0 0 20px 0;">
                                Hola <strong>{{ full_name }}</strong>,
                            </p>

                            <p style="color: #666666; line-height: 1.6; margin: 0 0 20px 0;">
                                Recibimos una solicitud para restablecer la contraseña de tu cuenta de Jabrutouch.
                            </p>

                            <p style="color: #666666; line-height: 1.6; margin: 0 0 30px 0;">
                                Haz clic en el botón de abajo para restablecer tu contraseña de forma segura:
                            </p>

                            <!-- Button -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 20px 0;">
                                        <a href="{{ reset_url }}"
                                           style="background-color: #4CAF50;
                                                  color: #ffffff;
                                                  padding: 14px 40px;
                                                  text-decoration: none;
                                                  border-radius: 5px;
                                                  display: inline-block;
                                                  font-weight: bold;
                                                  font-size: 16px;">
                                            Restablecer Contraseña
                                        </a>
                                    </td>
                                </tr>
                            </table>

                            <p style="color: #999999; font-size: 14px; line-height: 1.6; margin: 30px 0 20px 0;">
                                ⏱ Este enlace expirará en <strong>{{ expiry_hours }} hora(s)</strong>.
                            </p>

                            <p style="color: #999999; font-size: 14px; line-height: 1.6; margin: 0 0 20px 0;">
                                Si no solicitaste este cambio, puedes ignorar este correo de forma segura. Tu contraseña no será modificada.
                            </p>

                            <p style="color: #666666; line-height: 1.6; margin: 30px 0 0 0;">
                                Saludos,<br>
                                <strong>El equipo de Jabrutouch</strong>
                            </p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f9f9f9; padding: 30px; border-top: 1px solid #e0e0e0;">
                            <p style="color: #999999; font-size: 12px; line-height: 1.5; margin: 0 0 10px 0;">
                                <strong>🔗 Si el botón no funciona, copia y pega este enlace en tu navegador:</strong>
                            </p>
                            <p style="color: #4CAF50; font-size: 12px; word-break: break-all; margin: 0;">
                                {{ reset_url }}
                            </p>
                        </td>
                    </tr>

                    <!-- Security Notice -->
                    <tr>
                        <td style="background-color: #fff3cd; padding: 20px; border-top: 1px solid #ffc107;">
                            <p style="color: #856404; font-size: 13px; line-height: 1.5; margin: 0;">
                                🔒 <strong>Aviso de seguridad:</strong> Nunca compartas este enlace con nadie.
                                Jabrutouch nunca te pedirá tu contraseña por correo electrónico.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
```

---

### 5.2 Phase 2: iOS Deep Link Implementation

#### Step 2.1: Update AppDelegate

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Core/AppDelegate.swift`

Add to existing `application(_ application:open url:)` method (around line 169):

```swift
func application(_ application: UIApplication, open url: URL,
                sourceApplication: String?, annotation: Any) -> Bool {
    if let host = url.host {
        let mainViewController = Storyboards.Main.mainViewController
        mainViewController.modalPresentationStyle = .fullScreen

        // ... existing code for crowns, download, gemara, mishna ...

        // NEW: Handle password reset
        if host == "reset-password" {
            handlePasswordResetDeepLink(url: url)
            return true
        }
    }
    return true
}

// NEW METHOD: Handle password reset deep link
private func handlePasswordResetDeepLink(url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let token = components.queryItems?.first(where: { $0.name == "token" })?.value,
          let email = components.queryItems?.first(where: { $0.name == "email" })?.value else {
        showInvalidResetLinkAlert()
        return
    }

    // Validate token with backend
    validateResetToken(token: token, email: email) { [weak self] isValid, userData in
        if isValid, let userData = userData {
            // Present reset password screen
            self?.presentResetPasswordViewController(
                token: token,
                email: email,
                userData: userData
            )
        } else {
            self?.showExpiredResetLinkAlert()
        }
    }
}

private func validateResetToken(token: String, email: String,
                                completion: @escaping (Bool, [String: Any]?) -> Void) {
    API.validateResetToken(token: token, email: email) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let response):
                completion(response.valid, response.userData)
            case .failure:
                completion(false, nil)
            }
        }
    }
}

private func presentResetPasswordViewController(token: String, email: String,
                                               userData: [String: Any]) {
    let resetVC = Storyboards.Auth.resetPasswordViewController
    resetVC.token = token
    resetVC.email = email
    resetVC.userData = userData
    resetVC.modalPresentationStyle = .fullScreen

    topmostViewController?.present(resetVC, animated: true, completion: nil)
}

private func showInvalidResetLinkAlert() {
    let alert = UIAlertController(
        title: "Enlace Inválido",
        message: "El enlace de restablecimiento de contraseña no es válido.",
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    topmostViewController?.present(alert, animated: true)
}

private func showExpiredResetLinkAlert() {
    let alert = UIAlertController(
        title: "Enlace Expirado",
        message: "Este enlace de restablecimiento ha expirado. Por favor, solicita uno nuevo.",
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Solicitar Nuevo", style: .default) { _ in
        // Navigate to forgot password screen
        let forgotVC = Storyboards.SignIn.forgotPasswordViewController
        forgotVC.modalPresentationStyle = .fullScreen
        self.topmostViewController?.present(forgotVC, animated: true)
    })
    alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
    topmostViewController?.present(alert, animated: true)
}
```

#### Step 2.2: Create Reset Password View Controller

**File:** Create `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Auth/ResetPasswordViewController.swift`

```swift
import UIKit

class ResetPasswordViewController: UIViewController {

    // MARK: - Properties
    var token: String!
    var email: String!
    var userData: [String: Any]?

    private var activityView: ActivityView?

    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var passwordStrengthLabel: UILabel!
    @IBOutlet weak var showPasswordButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        displayUserInfo()
    }

    // MARK: - Setup
    private func setupUI() {
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8

        newPasswordView.layer.cornerRadius = 8
        newPasswordView.layer.borderWidth = 1
        newPasswordView.layer.borderColor = Colors.borderGray.cgColor

        confirmPasswordView.layer.cornerRadius = 8
        confirmPasswordView.layer.borderWidth = 1
        confirmPasswordView.layer.borderColor = Colors.borderGray.cgColor

        resetButton.layer.cornerRadius = 8
        cancelButton.layer.cornerRadius = 8

        titleLabel.text = "Restablecer Contraseña"
        resetButton.setTitle("Confirmar", for: .normal)
        cancelButton.setTitle("Cancelar", for: .normal)
    }

    private func setupTextFields() {
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true

        newPasswordTextField.placeholder = "Nueva contraseña"
        confirmPasswordTextField.placeholder = "Confirmar contraseña"

        newPasswordTextField.addTarget(
            self,
            action: #selector(passwordTextDidChange),
            for: .editingChanged
        )
    }

    private func displayUserInfo() {
        if let firstName = userData?["first_name"] as? String {
            userInfoLabel.text = "Hola \(firstName), ingresa tu nueva contraseña"
        } else {
            userInfoLabel.text = "Ingresa tu nueva contraseña"
        }
    }

    // MARK: - Password Validation
    @objc private func passwordTextDidChange() {
        guard let password = newPasswordTextField.text else { return }

        let strength = getPasswordStrength(password)
        updatePasswordStrengthUI(strength: strength)
    }

    private func getPasswordStrength(_ password: String) -> PasswordStrength {
        let length = password.count
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = password.rangeOfCharacter(
            from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        ) != nil

        var score = 0
        if length >= 8 { score += 1 }
        if length >= 12 { score += 1 }
        if hasUppercase && hasLowercase { score += 1 }
        if hasNumbers { score += 1 }
        if hasSpecial { score += 1 }

        switch score {
        case 0...1: return .weak
        case 2...3: return .medium
        default: return .strong
        }
    }

    private func updatePasswordStrengthUI(strength: PasswordStrength) {
        switch strength {
        case .weak:
            passwordStrengthLabel.text = "Contraseña débil"
            passwordStrengthLabel.textColor = .red
        case .medium:
            passwordStrengthLabel.text = "Contraseña media"
            passwordStrengthLabel.textColor = .orange
        case .strong:
            passwordStrengthLabel.text = "Contraseña fuerte"
            passwordStrengthLabel.textColor = .green
        }
    }

    // MARK: - Actions
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        guard let newPassword = newPasswordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showAlert(
                title: "Error",
                message: "Por favor, completa todos los campos"
            )
            return
        }

        // Validate password length
        guard newPassword.count >= 6 else {
            showAlert(
                title: "Contraseña Débil",
                message: "La contraseña debe tener al menos 6 caracteres"
            )
            return
        }

        // Validate passwords match
        guard newPassword == confirmPassword else {
            showAlert(
                title: "Error",
                message: "Las contraseñas no coinciden"
            )
            return
        }

        confirmPasswordReset(newPassword: newPassword)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showPasswordButtonPressed(_ sender: UIButton) {
        newPasswordTextField.isSecureTextEntry.toggle()
        confirmPasswordTextField.isSecureTextEntry.toggle()

        let imageName = newPasswordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - API
    private func confirmPasswordReset(newPassword: String) {
        showActivityView()

        API.confirmPasswordReset(
            token: token,
            email: email,
            newPassword: newPassword
        ) { [weak self] result in
            self?.removeActivityView()

            switch result {
            case .success(let response):
                if response.success {
                    self?.showSuccessAndNavigateToLogin()
                } else {
                    self?.showAlert(
                        title: "Error",
                        message: response.error ?? "Error desconocido"
                    )
                }
            case .failure(let error):
                self?.showAlert(
                    title: "Error",
                    message: error.localizedDescription
                )
            }
        }
    }

    private func showSuccessAndNavigateToLogin() {
        let alert = UIAlertController(
            title: "¡Éxito!",
            message: "Tu contraseña ha sido actualizada. Por favor, inicia sesión con tu nueva contraseña.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigateToLogin()
        })
        present(alert, animated: true)
    }

    private func navigateToLogin() {
        dismiss(animated: true) {
            let signInVC = Storyboards.SignIn.signInViewController
            signInVC.modalPresentationStyle = .fullScreen
            appDelegate.topmostViewController?.present(signInVC, animated: true)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Activity View
    private func showActivityView() {
        DispatchQueue.main.async {
            if self.activityView == nil {
                self.activityView = Utils.showActivityView(
                    inView: self.view,
                    withFrame: self.view.frame,
                    text: nil
                )
            }
        }
    }

    private func removeActivityView() {
        DispatchQueue.main.async {
            if let view = self.activityView {
                Utils.removeActivityView(view)
                self.activityView = nil
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPasswordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            resetButtonPressed(resetButton)
        }
        return true
    }
}

// MARK: - Password Strength Enum
enum PasswordStrength {
    case weak
    case medium
    case strong
}
```

#### Step 2.3: Add API Methods

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/Network/API.swift`

Add to existing API class:

```swift
// MARK: - Password Reset

class func requestPasswordReset(
    email: String,
    completionHandler: @escaping (_ response: APIResult<PasswordResetRequestResponse>) -> Void
) {
    guard let request = HttpRequestsFactory.createRequestPasswordResetRequest(
        email: email
    ) else {
        completionHandler(APIResult.failure(.unableToCreateRequest))
        return
    }

    HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
        self.processResult(
            data: data,
            response: response,
            error: error,
            completionHandler: completionHandler
        )
    }
}

class func validateResetToken(
    token: String,
    email: String,
    completionHandler: @escaping (_ response: APIResult<TokenValidationResponse>) -> Void
) {
    guard let request = HttpRequestsFactory.createValidateResetTokenRequest(
        token: token,
        email: email
    ) else {
        completionHandler(APIResult.failure(.unableToCreateRequest))
        return
    }

    HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
        self.processResult(
            data: data,
            response: response,
            error: error,
            completionHandler: completionHandler
        )
    }
}

class func confirmPasswordReset(
    token: String,
    email: String,
    newPassword: String,
    completionHandler: @escaping (_ response: APIResult<PasswordResetConfirmResponse>) -> Void
) {
    guard let request = HttpRequestsFactory.createConfirmPasswordResetRequest(
        token: token,
        email: email,
        newPassword: newPassword
    ) else {
        completionHandler(APIResult.failure(.unableToCreateRequest))
        return
    }

    HttpServiceProvider.shared.excecuteRequest(request: request) { (data, response, error) in
        self.processResult(
            data: data,
            response: response,
            error: error,
            completionHandler: completionHandler
        )
    }
}
```

#### Step 2.4: Add HTTP Request Factory Methods

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/Network/HTTPRequestFactory.swift`

Add to existing class:

```swift
// MARK: - Password Reset Requests

class func createRequestPasswordResetRequest(email: String) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    let link = baseUrl.appendingPathComponent("api/request-password-reset/").absoluteString
    let body: [String: Any] = ["email": email]

    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(
        url,
        method: .post,
        body: body,
        additionalHeaders: nil
    )
    return request
}

class func createValidateResetTokenRequest(
    token: String,
    email: String
) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    let link = baseUrl.appendingPathComponent("api/validate-reset-token/").absoluteString
    let body: [String: Any] = [
        "token": token,
        "email": email
    ]

    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(
        url,
        method: .post,
        body: body,
        additionalHeaders: nil
    )
    return request
}

class func createConfirmPasswordResetRequest(
    token: String,
    email: String,
    newPassword: String
) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    let link = baseUrl.appendingPathComponent("api/confirm-password-reset/").absoluteString
    let body: [String: Any] = [
        "token": token,
        "email": email,
        "new_password": newPassword
    ]

    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(
        url,
        method: .post,
        body: body,
        additionalHeaders: nil
    )
    return request
}
```

#### Step 2.5: Add Response Models

**File:** Create `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Network/API Response models/PasswordResetResponses.swift`

```swift
import Foundation

// Request Password Reset Response
struct PasswordResetRequestResponse: APIResponseModel {
    let success: Bool
    let message: String

    init?(values: [String: Any]) {
        guard let success = values["success"] as? Bool,
              let message = values["message"] as? String else {
            return nil
        }
        self.success = success
        self.message = message
    }
}

// Token Validation Response
struct TokenValidationResponse: APIResponseModel {
    let valid: Bool
    let userData: [String: Any]?
    let error: String?

    init?(values: [String: Any]) {
        self.valid = values["valid"] as? Bool ?? false
        self.userData = values
        self.error = values["error"] as? String
    }
}

// Password Reset Confirmation Response
struct PasswordResetConfirmResponse: APIResponseModel {
    let success: Bool
    let message: String?
    let error: String?

    init?(values: [String: Any]) {
        self.success = values["success"] as? Bool ?? false
        self.message = values["message"] as? String
        self.error = values["error"] as? String
    }
}
```

#### Step 2.6: Update Forgot Password Flow

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/ForgotPassword/ForgotPasswordViewController.swift`

Update the `forgotPassword()` method to use new endpoint:

```swift
private func forgotPassword(_ email: String) {
    API.requestPasswordReset(email: email) { [weak self] result in
        self?.removeActivityView()

        switch result {
        case .success(let response):
            // Always show success (prevents user enumeration)
            self?.setSecondContainer(message: response.message, status: true)
        case .failure(let error):
            let title = Strings.error
            let message = error.localizedDescription
            Utils.showAlertMessage(message, title: title, viewControler: self)
        }
    }
}

func setSecondContainer(message: String, status: Bool) {
    self.containerView.isHidden = true
    self.emailSentCcontainerView.isHidden = false

    // Always show success message (security fix)
    self.isRegisterd = true
    self.userExistsView.isHidden = false
    self.secondSubTitleLabel.isHidden = true
    self.okButton.setTitle("OK", for: .normal)

    // Generic message
    self.sentEmailLeibel.text = message
    self.emailAddressLabel.text = self.emailAddress
}
```

---

### 5.3 Phase 3: Universal Links Configuration (Optional)

#### Step 3.1: Server Configuration

**Host file at:** `https://jabrutouch.page.link/.well-known/apple-app-site-association`

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.il.co.jabrutouch.Jabrutouch",
        "paths": [
          "/reset-password",
          "/reset-password/*"
        ]
      }
    ]
  }
}
```

**Requirements:**
- File must be served over HTTPS
- Content-Type: `application/json`
- No `.json` extension needed
- Must be accessible without authentication

#### Step 3.2: Update AppDelegate for Universal Links

Add to `application(_ application:continue userActivity:)`:

```swift
func application(_ application: UIApplication,
                continue userActivity: NSUserActivity,
                restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

    if let incomingURL = userActivity.webpageURL {
        // Check if it's a password reset link
        if incomingURL.path.contains("reset-password") {
            handlePasswordResetUniversalLink(url: incomingURL)
            return true
        }

        // Existing dynamic links handling
        let linkHandled = DynamicLinks.dynamicLinks()
            .handleUniversalLink(incomingURL) { (dynamicLink, error) in
                // ... existing code ...
            }
        return linkHandled
    }
    return false
}

private func handlePasswordResetUniversalLink(url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let token = components.queryItems?.first(where: { $0.name == "token" })?.value,
          let email = components.queryItems?.first(where: { $0.name == "email" })?.value else {
        showInvalidResetLinkAlert()
        return
    }

    // Use same validation logic as custom scheme
    validateResetToken(token: token, email: email) { [weak self] isValid, userData in
        if isValid, let userData = userData {
            self?.presentResetPasswordViewController(
                token: token,
                email: email,
                userData: userData
            )
        } else {
            self?.showExpiredResetLinkAlert()
        }
    }
}
```

---

## 6. Security Considerations

### 6.1 Token Security

**Token Generation:**
```python
import secrets

# Generate cryptographically secure token
token = secrets.token_urlsafe(32)  # 32 bytes = 43 characters base64
```

**Token Storage:**
- Store hashed version if extra paranoid: `hashlib.sha256(token.encode()).hexdigest()`
- Index token field for fast lookups
- Include email in query for additional validation

**Token Expiration:**
- Default: 1 hour
- Configurable via settings
- Clean up expired tokens regularly

### 6.2 Rate Limiting

**Backend Rate Limiting (Django):**
```python
from django.core.cache import cache

def request_password_reset(request):
    email = request.data.get('email')

    # Rate limit: 3 requests per hour per email
    cache_key = f'password_reset_attempts_{email}'
    attempts = cache.get(cache_key, 0)

    if attempts >= 3:
        return Response({
            'error': 'Demasiadas solicitudes. Intenta de nuevo más tarde.'
        }, status=429)

    cache.set(cache_key, attempts + 1, 3600)  # 1 hour

    # ... rest of logic ...
```

**iOS Rate Limiting:**
```swift
private var lastRequestTime: Date?
private let requestCooldown: TimeInterval = 60 // seconds

@IBAction func sendButtonPressed(_ sender: Any) {
    if let lastRequest = lastRequestTime {
        let elapsed = Date().timeIntervalSince(lastRequest)
        if elapsed < requestCooldown {
            let remaining = Int(requestCooldown - elapsed)
            showAlert(message: "Espera \(remaining) segundos antes de reintentar")
            return
        }
    }

    lastRequestTime = Date()
    // ... proceed with request ...
}
```

### 6.3 Email Validation

**Client-Side:**
```swift
func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return predicate.evaluate(with: email)
}
```

**Server-Side:**
```python
import re

def is_valid_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None
```

### 6.4 Password Strength

**Minimum Requirements:**
- At least 6 characters (8+ recommended)
- Mix of uppercase and lowercase
- Include numbers
- Special characters (optional but recommended)

**Client-Side Validation:**
```swift
func validatePassword(_ password: String) -> (valid: Bool, message: String) {
    if password.count < 6 {
        return (false, "La contraseña debe tener al menos 6 caracteres")
    }

    let hasLetter = password.rangeOfCharacter(from: .letters) != nil
    let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil

    if !hasLetter || !hasNumber {
        return (false, "La contraseña debe contener letras y números")
    }

    return (true, "Contraseña válida")
}
```

### 6.5 Prevention of User Enumeration

**Always return success:**
```python
# BAD: Reveals if user exists
if user:
    return Response({'status': True, 'message': 'Email sent'})
else:
    return Response({'status': False, 'message': 'User not found'})

# GOOD: Same response regardless
response = {
    'success': True,
    'message': 'Si existe una cuenta con este correo, recibirás un enlace.'
}
# Only send email if user exists (internal check)
return Response(response)
```

### 6.6 HTTPS Enforcement

**iOS App Transport Security:**
```xml
<!-- Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

**Backend:**
- Force HTTPS in production
- Use HSTS headers
- Secure cookie flags

---

## 7. Testing Strategy

### 7.1 Backend Testing

**Unit Tests:**
```python
# tests/test_password_reset.py
from django.test import TestCase
from django.utils import timezone
from datetime import timedelta

class PasswordResetTests(TestCase):
    def test_token_generation(self):
        """Test token is generated correctly"""
        user = User.objects.create(email='test@example.com')
        token = generate_reset_token(user)
        self.assertEqual(len(token), 43)  # 32 bytes base64

    def test_token_expiration(self):
        """Test expired tokens are invalid"""
        user = User.objects.create(email='test@example.com')
        reset_token = PasswordResetToken.objects.create(
            user=user,
            token='test_token',
            email=user.email,
            expires_at=timezone.now() - timedelta(hours=1)
        )
        self.assertFalse(reset_token.is_valid())

    def test_user_enumeration_prevention(self):
        """Test same response for existing and non-existing users"""
        # Existing user
        response1 = self.client.post('/api/request-password-reset/', {
            'email': 'existing@example.com'
        })

        # Non-existing user
        response2 = self.client.post('/api/request-password-reset/', {
            'email': 'nonexisting@example.com'
        })

        # Both should return success
        self.assertEqual(response1.status_code, 200)
        self.assertEqual(response2.status_code, 200)
        self.assertEqual(response1.json()['success'], True)
        self.assertEqual(response2.json()['success'], True)

    def test_rate_limiting(self):
        """Test rate limiting works"""
        email = 'test@example.com'

        # First 3 requests should succeed
        for i in range(3):
            response = self.client.post('/api/request-password-reset/', {
                'email': email
            })
            self.assertEqual(response.status_code, 200)

        # 4th request should fail
        response = self.client.post('/api/request-password-reset/', {
            'email': email
        })
        self.assertEqual(response.status_code, 429)
```

### 7.2 iOS Testing

**Unit Tests:**
```swift
import XCTest
@testable import Jabrutouch

class PasswordResetTests: XCTestCase {

    func testEmailValidation() {
        // Valid emails
        XCTAssertTrue(isValidEmail("user@example.com"))
        XCTAssertTrue(isValidEmail("test.user@example.co.uk"))

        // Invalid emails
        XCTAssertFalse(isValidEmail("notanemail"))
        XCTAssertFalse(isValidEmail("@example.com"))
        XCTAssertFalse(isValidEmail("user@"))
    }

    func testPasswordStrength() {
        let weak = getPasswordStrength("123")
        XCTAssertEqual(weak, .weak)

        let medium = getPasswordStrength("Pass123")
        XCTAssertEqual(medium, .medium)

        let strong = getPasswordStrength("Pass123!@#Strong")
        XCTAssertEqual(strong, .strong)
    }

    func testDeepLinkParsing() {
        let url = URL(string: "jabrutouch://reset-password?token=ABC123&email=test@example.com")!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        let token = components?.queryItems?.first(where: { $0.name == "token" })?.value
        let email = components?.queryItems?.first(where: { $0.name == "email" })?.value

        XCTAssertEqual(token, "ABC123")
        XCTAssertEqual(email, "test@example.com")
    }
}
```

### 7.3 Integration Testing

**Test Scenarios:**

1. **Happy Path:**
   - User requests reset → Email sent → Click link → Enter password → Success

2. **Expired Token:**
   - User requests reset → Wait 2 hours → Click link → See expiry error

3. **Invalid Token:**
   - User clicks link with invalid token → See error

4. **Token Already Used:**
   - User resets password → Try to use same link again → See error

5. **Network Failure:**
   - Request reset with no internet → See network error

6. **Rate Limiting:**
   - Request reset 4 times quickly → See rate limit error

### 7.4 Manual Testing Checklist

**Email Testing:**
- [ ] Email arrives within 1 minute
- [ ] Email displays correctly on iPhone Mail app
- [ ] Email displays correctly on Gmail app
- [ ] Reset button/link is clickable
- [ ] Copy-paste link works
- [ ] Email doesn't go to spam

**Deep Link Testing:**
- [ ] Custom URL scheme opens app from Safari
- [ ] Custom URL scheme opens app from Mail app
- [ ] Universal link opens app directly (no browser)
- [ ] Universal link works in iMessage
- [ ] Link works when app is closed
- [ ] Link works when app is backgrounded

**Password Reset Testing:**
- [ ] Can enter new password
- [ ] Password strength indicator works
- [ ] Show/hide password works
- [ ] Passwords must match
- [ ] Minimum length enforced
- [ ] Success navigates to login
- [ ] Can login with new password

**Error Handling:**
- [ ] Expired link shows correct message
- [ ] Invalid link shows correct message
- [ ] Network error shows correctly
- [ ] Server error shows correctly
- [ ] All errors allow retry

---

## 8. Configuration & Environment Variables

### 8.1 Django Backend

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_server/.env`

```bash
# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=noreply@jabrutouch.com
EMAIL_HOST_PASSWORD=your_app_specific_password

# Password Reset
PASSWORD_RESET_TOKEN_EXPIRY_HOURS=1
PASSWORD_RESET_MAX_ATTEMPTS_PER_HOUR=3
PASSWORD_RESET_BASE_URL=https://jabrutouch.page.link

# Email Content
PASSWORD_RESET_SUBJECT=Restablecer tu contraseña - Jabrutouch
PASSWORD_RESET_PREVIEW=Haz clic para restablecer tu contraseña
```

### 8.2 iOS App

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Info.plist`

Ensure `APIBaseUrl` is set correctly:
```xml
<key>APIBaseUrl</key>
<string>https://api.jabrutouch.com</string>
```

---

## 9. Deployment Checklist

### 9.1 Backend Deployment

- [ ] Run database migrations
- [ ] Update environment variables
- [ ] Create email template file
- [ ] Test email sending in staging
- [ ] Configure SMTP credentials
- [ ] Set up rate limiting (Redis/cache)
- [ ] Add monitoring/logging
- [ ] Test all endpoints
- [ ] Update API documentation

### 9.2 iOS Deployment

- [ ] Update Info.plist with URL schemes
- [ ] Add entitlements for universal links
- [ ] Implement deep link handlers
- [ ] Create reset password view controller
- [ ] Add API methods and models
- [ ] Update forgot password flow
- [ ] Test on physical device
- [ ] Submit for App Store review

### 9.3 Server Configuration (for Universal Links)

- [ ] Host `apple-app-site-association` file
- [ ] Verify HTTPS is working
- [ ] Test file is accessible
- [ ] Check Content-Type header
- [ ] Configure CDN if using one
- [ ] Test universal links on device

---

## 10. Monitoring & Analytics

### 10.1 Backend Metrics

**Track:**
- Number of reset requests per day
- Success/failure rates
- Token expiration rates
- Rate limiting hits
- Email delivery failures

**Implementation:**
```python
import logging

logger = logging.getLogger(__name__)

def request_password_reset(request):
    email = request.data.get('email')

    # Log reset request
    logger.info(f'Password reset requested for: {email}')

    # ... existing code ...

    if email_sent:
        logger.info(f'Reset email sent to: {email}')
    else:
        logger.error(f'Failed to send reset email to: {email}')
```

### 10.2 iOS Analytics

**Track with Firebase:**
```swift
import FirebaseAnalytics

// Track reset request
Analytics.logEvent("password_reset_requested", parameters: nil)

// Track successful reset
Analytics.logEvent("password_reset_completed", parameters: nil)

// Track errors
Analytics.logEvent("password_reset_error", parameters: [
    "error_type": errorType
])
```

---

## 11. Timeline Estimate

### Development Phases

**Phase 1: Backend Implementation** (2-3 days)
- Day 1: Database model, token generation, email template
- Day 2: API endpoints, validation logic
- Day 3: Testing, security review

**Phase 2: iOS Implementation** (2-3 days)
- Day 1: Deep link handlers, API integration
- Day 2: Reset password UI, validation
- Day 3: Testing, bug fixes

**Phase 3: Universal Links (Optional)** (1-2 days)
- Day 1: Server configuration, testing
- Day 2: iOS integration, end-to-end testing

**Phase 4: Testing & Deployment** (1-2 days)
- Integration testing
- Security testing
- Staging deployment
- Production deployment

**Total Estimate: 6-10 business days**

---

## 12. Rollback Plan

### If Issues Arise

**Immediate Rollback:**
1. Disable new endpoints
2. Re-enable old password reset endpoint
3. Update iOS to use old flow
4. Communicate with users

**Database Rollback:**
```python
# Migration rollback
python manage.py migrate jabrutouch_api <previous_migration>
```

**iOS Rollback:**
- Revert to previous app version
- Or push hotfix with old flow

---

## Conclusion

This implementation plan provides a complete, secure password reset system using email links for the JabruTouch iOS app. The approach:

1. ✅ **Fixes current security issues** (plain text passwords, user enumeration)
2. ✅ **Uses existing infrastructure** (Django email templates, iOS deep linking)
3. ✅ **Follows security best practices** (secure tokens, expiration, rate limiting)
4. ✅ **Provides excellent UX** (seamless deep linking, clear error messages)
5. ✅ **Is thoroughly tested** (unit, integration, manual testing)

**Recommended Next Steps:**
1. Get approval for timeline and approach
2. Set up staging environment for testing
3. Begin Phase 1 (Backend) implementation
4. Parallel Phase 2 (iOS) development
5. Comprehensive testing before production

**Key Decision Points:**
- ✅ Use Universal Links (recommended) or Custom URL Scheme
- ✅ Token expiry time (1 hour recommended)
- ✅ Rate limiting thresholds (3 per hour recommended)
- ✅ Password strength requirements (6+ chars, letters+numbers)

---

**Document Version:** 1.0
**Last Updated:** October 12, 2025
**Author:** Claude Code Analysis
**Status:** Ready for Implementation
