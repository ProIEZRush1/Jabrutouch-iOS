# Password Reset Refactoring Plan
## From "Email New Password" to "Email Reset Link with Token"

**Date:** 2025-10-12
**Analyst:** Claude Code
**Target:** Refactor password reset from insecure direct password email to secure token-based reset link

---

## Executive Summary

### Current State Analysis

**iOS App:**
- Uses endpoint: `POST /api/reset_password/`
- Request: `{ "email": "user@example.com" }`
- Response: `{ "message": "...", "user_exist_status": bool }`
- Currently connects to Django backend via `$(API_BASE_URL)` from Info.plist

**Django Backend (Legacy - Currently Active):**
- File: `/jabrutouch_server/jabrutouch_api/login_process.py` (lines 190-210)
- **Insecure Implementation:**
  ```python
  def reset_password(request):
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
          return Response({"user_exist_status": True, "message": "mail has bin send"})
      else:
          return Response({"user_exist_status": False, "message": "User doesn't exist..."})
  ```

**Laravel Backend (Active Development - Not Used for Password Reset Yet):**
- No password reset implementation found
- Has `password_reset_tokens` table already defined in migration
- Uses legacy `jabrutouch_api_user` table (Django naming)
- Laravel 11 with built-in password reset infrastructure available

---

## Security Issues with Current Implementation

### Critical Security Flaws

1. **Sending Passwords via Email** ⚠️⚠️⚠️
   - Passwords stored in plain text in email
   - Email is unencrypted (even over TLS, emails are stored unencrypted)
   - Email can be intercepted, forwarded, or leaked
   - Violates OWASP best practices

2. **Weak Password Generation**
   - Uses 4-digit numeric passwords (1000-9999)
   - Only 9,000 possible combinations
   - Can be brute-forced in seconds

3. **User Enumeration Vulnerability**
   - Returns `user_exist_status: false` when email doesn't exist
   - Allows attackers to harvest valid email addresses
   - Enables targeted phishing attacks

4. **No Rate Limiting**
   - Can be abused to spam users with password reset emails
   - Can be used for denial of service

5. **No Token Expiration**
   - Password is permanent until user changes it
   - No time-limited security window

6. **No Email Confirmation**
   - Anyone with access to email can immediately use the password
   - No way to verify the reset was legitimate

---

## Proposed Architecture

### Token-Based Password Reset Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NEW Password Reset Flow                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  iOS App                          Backend (Django/Laravel)           │
│  ────────                         ───────────────────────           │
│                                                                      │
│  1. User enters email                                                │
│     ↓                                                                │
│  POST /api/v2/password/forgot                                        │
│     { "email": "user@example.com" }                                  │
│     ↓                                                                │
│                                  2. Generate secure token            │
│                                     - 32-byte random token           │
│                                     - Store in DB with expiration    │
│                                     - Associate with user            │
│                                  3. Send email with reset link       │
│                                     - Link: app://reset?token=xxx    │
│                                     - Expires in 1 hour              │
│     ↓                                                                │
│  Response (always success):                                          │
│     { "message": "If account exists, email sent" }                   │
│                                                                      │
│  4. User receives email                                              │
│     ↓                                                                │
│  5. User clicks link in email                                        │
│     ↓                                                                │
│  6. App opens via deep link                                          │
│     app://reset?token=abc123...                                      │
│     ↓                                                                │
│  7. App navigates to ResetPasswordViewController                     │
│     ↓                                                                │
│  8. User enters new password (2x for confirmation)                   │
│     ↓                                                                │
│  POST /api/v2/password/reset                                         │
│     { "token": "abc123...", "password": "newpass", "confirm": "..." }│
│     ↓                                                                │
│                                  9. Validate token:                  │
│                                     - Check exists                   │
│                                     - Check not expired              │
│                                     - Check not used                 │
│                                  10. Update password:                │
│                                     - Hash new password              │
│                                     - Mark token as used             │
│                                     - Invalidate all other tokens    │
│                                  11. Send confirmation email         │
│     ↓                                                                │
│  Response:                                                           │
│     { "success": true, "message": "Password updated" }               │
│     ↓                                                                │
│  12. Navigate to login screen                                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Database Schema Requirements

### Django Backend (Active)

**New Table: `jabrutouch_api_passwordresettoken`**

```python
# models.py
class PasswordResetToken(BaseTable):
    """
    Secure token-based password reset
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token = models.CharField(max_length=64, unique=True, db_index=True)
    expires_at = models.DateTimeField()
    used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)

    class Meta:
        ordering = ['-created']
        indexes = [
            models.Index(fields=['token', 'used', 'expires_at']),
        ]

    def is_valid(self):
        """Check if token is valid (not expired, not used)"""
        from django.utils import timezone
        return (
            not self.used and
            self.expires_at > timezone.now()
        )

    def mark_as_used(self):
        """Mark token as used"""
        from django.utils import timezone
        self.used = True
        self.used_at = timezone.now()
        self.save()
```

**Migration Command:**
```bash
cd jabrutouch_server/jabrutouch_server
python manage.py makemigrations jabrutouch_api
python manage.py migrate
```

### Laravel Backend (For Future Use)

**Table Already Exists:** `password_reset_tokens`

Schema from migration `0001_01_01_000000_create_users_table.php`:
```php
Schema::create('password_reset_tokens', function (Blueprint $table) {
    $table->string('email')->primary();
    $table->string('token');
    $table->timestamp('created_at')->nullable();
});
```

**Note:** Laravel's default schema is minimal. If migrating to Laravel, recommend creating enhanced schema:

```php
Schema::create('jabrutouch_api_password_reset_tokens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained('jabrutouch_api_user')->onDelete('cascade');
    $table->string('token', 64)->unique();
    $table->timestamp('expires_at');
    $table->boolean('used')->default(false);
    $table->timestamp('used_at')->nullable();
    $table->ipAddress('ip_address')->nullable();
    $table->text('user_agent')->nullable();
    $table->timestamps();

    $table->index(['token', 'used', 'expires_at']);
});
```

---

## Backend Implementation

### Django Backend (Priority: Immediate)

#### Step 1: Create Model and Migration

**File:** `/jabrutouch_server/jabrutouch_api/models.py`

Add after line 678 (after `OTPRequestorManager`):

```python
class PasswordResetToken(BaseTable):
    """
    Secure token-based password reset.
    Tokens expire after 1 hour and are single-use.
    """
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='password_reset_tokens')
    token = models.CharField(max_length=64, unique=True, db_index=True)
    expires_at = models.DateTimeField()
    used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)

    class Meta:
        ordering = ['-created']
        indexes = [
            models.Index(fields=['token', 'used', 'expires_at'], name='token_lookup_idx'),
        ]

    def __str__(self):
        return f"Reset token for {self.user.email} - Valid: {self.is_valid()}"

    def is_valid(self):
        """Check if token is valid (not expired, not used)"""
        return not self.used and self.expires_at > timezone.now()

    def mark_as_used(self, ip_address=None, user_agent=None):
        """Mark token as used and store metadata"""
        self.used = True
        self.used_at = timezone.now()
        if ip_address:
            self.ip_address = ip_address
        if user_agent:
            self.user_agent = user_agent
        self.save()
```

#### Step 2: Create Serializers

**File:** `/jabrutouch_server/jabrutouch_api/serializer.py`

Add at end of file (after line 508):

```python
###########################
# Password Reset V2       #
###########################

class ForgotPasswordV2Serializer(serializers.Serializer):
    """
    Request password reset - sends email with token
    """
    email = serializers.EmailField(required=True)


class ResetPasswordV2Serializer(serializers.Serializer):
    """
    Complete password reset with token
    """
    token = serializers.CharField(required=True, max_length=64)
    password = serializers.CharField(required=True, min_length=4, max_length=128)
    password_confirm = serializers.CharField(required=True)

    def validate(self, attrs):
        """Validate passwords match"""
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({
                'password_confirm': 'Passwords do not match'
            })
        return attrs


class ValidateResetTokenSerializer(serializers.Serializer):
    """
    Validate if reset token is valid (for UI feedback)
    """
    token = serializers.CharField(required=True, max_length=64)
```

#### Step 3: Create Views

**File:** `/jabrutouch_server/jabrutouch_api/password_reset_v2.py` (NEW FILE)

```python
"""
Password Reset V2 - Secure Token-Based Implementation
Replaces insecure direct password email with token-based reset links.
"""
import secrets
from datetime import timedelta

from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from jabrutouch_api.models import User, PasswordResetToken
from jabrutouch_api.serializer import (
    ForgotPasswordV2Serializer,
    ResetPasswordV2Serializer,
    ValidateResetTokenSerializer
)


def generate_secure_token():
    """Generate cryptographically secure random token"""
    return secrets.token_urlsafe(32)  # 32 bytes = 256 bits


def get_client_ip(request):
    """Extract client IP from request"""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def send_reset_email(user, token, request):
    """
    Send password reset email with token link.
    Uses deep link for mobile app: jabrutouch://reset?token=xxx
    """
    reset_link = f"jabrutouch://reset?token={token}"

    # For web fallback (if needed):
    # web_reset_link = f"{settings.FRONTEND_URL}/reset-password?token={token}"

    subject = "Restablece tu contraseña - Jabrutouch"
    message = f"""
Hola {user.first_name},

Recibimos una solicitud para restablecer tu contraseña de Jabrutouch.

Para restablecer tu contraseña, toca este enlace desde tu dispositivo móvil:

{reset_link}

Este enlace expirará en 1 hora por motivos de seguridad.

Si no solicitaste este cambio, ignora este correo y tu contraseña permanecerá sin cambios.

Si tienes problemas, contáctanos en {settings.EMAIL_HOST_USER}

Saludos,
El equipo de Jabrutouch
"""

    # TODO: Create HTML email template for better UX
    # html_message = render_to_string('password_reset_email.html', {
    #     'user': user,
    #     'reset_link': reset_link,
    #     'expires_hours': 1
    # })

    try:
        send_mail(
            subject,
            message,
            f'Jabrutouch <{settings.EMAIL_HOST_USER}>',
            [user.email],
            fail_silently=False,
            # html_message=html_message,
        )
        print(f"✅ Password reset email sent to {user.email}")
        return True
    except Exception as e:
        print(f"❌ Failed to send password reset email to {user.email}: {e}")
        return False


@api_view(["POST"])
@permission_classes((AllowAny,))
def forgot_password_v2(request):
    """
    Step 1: Request password reset

    POST /api/v2/password/forgot
    Body: { "email": "user@example.com" }

    Response: Always returns success to prevent user enumeration
    { "message": "If an account exists with this email, you will receive a password reset link shortly." }
    """
    serializer = ForgotPasswordV2Serializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    email = serializer.validated_data['email']

    # Generic success message (security: don't reveal if user exists)
    success_message = (
        "Si existe una cuenta con este correo electrónico, "
        "recibirás un enlace para restablecer tu contraseña en breve."
    )

    try:
        user = User.active_users.get(email=email)

        # Invalidate all previous unused tokens for this user
        PasswordResetToken.objects.filter(
            user=user,
            used=False
        ).update(used=True, used_at=timezone.now())

        # Generate new token
        token = generate_secure_token()
        expires_at = timezone.now() + timedelta(hours=1)

        # Create token record
        reset_token = PasswordResetToken.objects.create(
            user=user,
            token=token,
            expires_at=expires_at,
            ip_address=get_client_ip(request),
            user_agent=request.META.get('HTTP_USER_AGENT', '')[:500]
        )

        # Send email
        send_reset_email(user, token, request)

        print(f"🔑 Password reset token created for {email}")

    except User.DoesNotExist:
        # Don't reveal that user doesn't exist (security)
        print(f"⚠️  Password reset requested for non-existent email: {email}")
        pass

    # Always return success
    return Response({
        "message": success_message,
        "success": True
    }, status=status.HTTP_200_OK)


@api_view(["POST"])
@permission_classes((AllowAny,))
def validate_reset_token(request):
    """
    Check if reset token is valid (optional - for UI feedback)

    POST /api/v2/password/validate-token
    Body: { "token": "abc123..." }

    Response:
    { "valid": true } or { "valid": false, "error": "Token expired" }
    """
    serializer = ValidateResetTokenSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    token_value = serializer.validated_data['token']

    try:
        token = PasswordResetToken.objects.get(token=token_value)

        if token.used:
            return Response({
                "valid": False,
                "error": "Este enlace ya fue utilizado"
            }, status=status.HTTP_400_BAD_REQUEST)

        if token.expires_at < timezone.now():
            return Response({
                "valid": False,
                "error": "Este enlace ha expirado. Solicita uno nuevo."
            }, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            "valid": True,
            "email": token.user.email  # Optional: show email for confirmation
        }, status=status.HTTP_200_OK)

    except PasswordResetToken.DoesNotExist:
        return Response({
            "valid": False,
            "error": "Enlace de restablecimiento inválido"
        }, status=status.HTTP_400_BAD_REQUEST)


@api_view(["POST"])
@permission_classes((AllowAny,))
def reset_password_v2(request):
    """
    Step 2: Complete password reset with token

    POST /api/v2/password/reset
    Body: {
        "token": "abc123...",
        "password": "newpassword",
        "password_confirm": "newpassword"
    }

    Response:
    { "success": true, "message": "Password updated successfully" }
    """
    serializer = ResetPasswordV2Serializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    token_value = serializer.validated_data['token']
    new_password = serializer.validated_data['password']

    try:
        token = PasswordResetToken.objects.get(token=token_value)

        # Validate token
        if token.used:
            return Response({
                "success": False,
                "error": "Este enlace ya fue utilizado"
            }, status=status.HTTP_400_BAD_REQUEST)

        if token.expires_at < timezone.now():
            return Response({
                "success": False,
                "error": "Este enlace ha expirado. Solicita uno nuevo."
            }, status=status.HTTP_400_BAD_REQUEST)

        # Update password
        user = token.user
        user.set_password(new_password)
        user.save()

        # Mark token as used
        token.mark_as_used(
            ip_address=get_client_ip(request),
            user_agent=request.META.get('HTTP_USER_AGENT', '')[:500]
        )

        # Invalidate all other tokens for this user
        PasswordResetToken.objects.filter(
            user=user,
            used=False
        ).exclude(id=token.id).update(used=True, used_at=timezone.now())

        # Send confirmation email
        try:
            send_mail(
                'Contraseña actualizada - Jabrutouch',
                f"""
Hola {user.first_name},

Tu contraseña de Jabrutouch ha sido actualizada exitosamente.

Si no realizaste este cambio, contacta a nuestro equipo de soporte inmediatamente.

Saludos,
El equipo de Jabrutouch
""",
                f'Jabrutouch <{settings.EMAIL_HOST_USER}>',
                [user.email],
                fail_silently=True,
            )
        except Exception as e:
            print(f"⚠️  Failed to send confirmation email: {e}")

        print(f"✅ Password reset completed for {user.email}")

        return Response({
            "success": True,
            "message": "Tu contraseña ha sido actualizada exitosamente"
        }, status=status.HTTP_200_OK)

    except PasswordResetToken.DoesNotExist:
        return Response({
            "success": False,
            "error": "Enlace de restablecimiento inválido"
        }, status=status.HTTP_400_BAD_REQUEST)
```

#### Step 4: Update URLs

**File:** `/jabrutouch_server/jabrutouch_server/urls.py`

Add new imports (line 21):
```python
from jabrutouch_api.password_reset_v2 import (
    forgot_password_v2,
    validate_reset_token,
    reset_password_v2
)
```

Add new routes (after line 61, before API Masechtot section):
```python
    # API Password Reset V2 (Secure Token-Based)
    re_path('api/v2/password/forgot/?$', forgot_password_v2, name='password_forgot_v2'),
    re_path('api/v2/password/validate-token/?$', validate_reset_token, name='password_validate_token'),
    re_path('api/v2/password/reset/?$', reset_password_v2, name='password_reset_v2'),
```

**Keep old endpoint for backward compatibility:**
```python
    # API Login (Legacy - keep for old app versions)
    re_path('api/reset_password/?$', reset_password),  # OLD - deprecated
```

---

## iOS App Implementation

### Step 1: Update Models

**File:** `Jabrutouch/App/Models/ForgotPasswordResponse.swift`

Create new response models for V2:

```swift
// MARK: - V2 Models (Token-Based)

struct ForgotPasswordV2Response: Codable {
    let message: String
    let success: Bool
}

struct ValidateTokenResponse: Codable {
    let valid: Bool
    let error: String?
    let email: String?
}

struct ResetPasswordV2Response: Codable {
    let success: Bool
    let message: String?
    let error: String?
}
```

### Step 2: Update HTTPRequestFactory

**File:** `Jabrutouch/App/Services/Network/HTTPRequestFactory.swift`

Add new methods after line 81:

```swift
// MARK: - Password Reset V2 (Token-Based)

class func forgotPasswordV2Request(email: String) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    let link = baseUrl.appendingPathComponent("v2/password/forgot/").absoluteString
    let body: [String:Any] = ["email": email]
    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
    return request
}

class func validateResetTokenRequest(token: String) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    let link = baseUrl.appendingPathComponent("v2/password/validate-token/").absoluteString
    let body: [String:Any] = ["token": token]
    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
    return request
}

class func resetPasswordV2Request(token: String, password: String, passwordConfirm: String) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    let link = baseUrl.appendingPathComponent("v2/password/reset/").absoluteString
    let body: [String:Any] = [
        "token": token,
        "password": password,
        "password_confirm": passwordConfirm
    ]
    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
    return request
}
```

### Step 3: Update API Layer

**File:** `Jabrutouch/App/Services/Network/API.swift`

Add new methods:

```swift
// MARK: - Password Reset V2

class func forgotPasswordV2(email: String, completion: @escaping (APIResult<ForgotPasswordV2Response>) -> Void) {
    guard let request = HttpRequestsFactory.forgotPasswordV2Request(email: email) else {
        completion(.failure(APIError.invalidRequest))
        return
    }

    API.makeRequest(request: request) { (result: APIResult<ForgotPasswordV2Response>) in
        completion(result)
    }
}

class func validateResetToken(token: String, completion: @escaping (APIResult<ValidateTokenResponse>) -> Void) {
    guard let request = HttpRequestsFactory.validateResetTokenRequest(token: token) else {
        completion(.failure(APIError.invalidRequest))
        return
    }

    API.makeRequest(request: request) { (result: APIResult<ValidateTokenResponse>) in
        completion(result)
    }
}

class func resetPasswordV2(token: String, password: String, passwordConfirm: String, completion: @escaping (APIResult<ResetPasswordV2Response>) -> Void) {
    guard let request = HttpRequestsFactory.resetPasswordV2Request(token: token, password: password, passwordConfirm: passwordConfirm) else {
        completion(.failure(APIError.invalidRequest))
        return
    }

    API.makeRequest(request: request) { (result: APIResult<ResetPasswordV2Response>) in
        completion(result)
    }
}
```

### Step 4: Update LoginManager

**File:** `Jabrutouch/App/Manager/LoginManager.swift`

Add new methods:

```swift
// MARK: - Password Reset V2 (Token-Based)

func forgotPasswordV2(email: String, completion: @escaping (APIResult<ForgotPasswordV2Response>) -> Void) {
    API.forgotPasswordV2(email: email) { result in
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

func validateResetToken(token: String, completion: @escaping (APIResult<ValidateTokenResponse>) -> Void) {
    API.validateResetToken(token: token) { result in
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

func resetPasswordV2(token: String, password: String, passwordConfirm: String, completion: @escaping (APIResult<ResetPasswordV2Response>) -> Void) {
    API.resetPasswordV2(token: token, password: password, passwordConfirm: passwordConfirm) { result in
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
```

### Step 5: Update ForgotPasswordViewController

**File:** `Jabrutouch/Controller/ForgotPassword/ForgotPasswordViewController.swift`

Update `forgotPassword` method (line 115):

```swift
private func forgotPassword(_ email: String) {
    // Use V2 API (token-based)
    LoginManager.shared.forgotPasswordV2(email: email) { [weak self] result in
        guard let self = self else { return }

        self.hideActivityView()

        switch result {
        case .success(let response):
            // Always show success message (V2 doesn't reveal if user exists)
            self.setSecondContainer(message: response.message, status: true)

        case .failure(let error):
            let title = Strings.error
            let message = error.localizedDescription
            Utils.showAlertMessage(message, title: title, viewControler: self)
        }
    }
}
```

Update `setSecondContainer` method (line 88):

```swift
private func setSecondContainer(message: String, status: Bool) {
    self.containerView.isHidden = true
    self.emailSentCcontainerView.isHidden = false

    // V2: Always show success (generic message for security)
    self.isRegisterd = true
    self.userExistsView.isHidden = false
    self.secondSubTitleLabel.isHidden = true
    self.okButton.setTitle("OK", for: .normal)
    self.setSucssesStrings()  // Set success UI

    // Show the message from server
    self.sentEmailLeibel.text = message
    self.emailAddressLabel.text = self.emailAddress
}
```

### Step 6: Create ResetPasswordViewController (NEW FILE)

**File:** `Jabrutouch/Controller/ResetPassword/ResetPasswordViewController.swift`

```swift
//בעזרת ה׳ החונן לאדם דעת
//  ResetPasswordViewController.swift
//  Jabrutouch
//
//  Created for Password Reset V2 (Token-Based)
//  Copyright © 2025 Ravtech. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordStrengthView: UIView!
    @IBOutlet weak var passwordStrengthLabel: UILabel!

    // MARK: - Properties

    var resetToken: String?
    private var isValidatingToken = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        validateToken()
    }

    // MARK: - Setup

    private func setupUI() {
        titleLabel.text = "Restablecer Contraseña"
        descriptionLabel.text = "Ingresa tu nueva contraseña"

        passwordTextField.placeholder = "Nueva contraseña"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .newPassword
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.delegate = self

        confirmPasswordTextField.placeholder = "Confirmar contraseña"
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.textContentType = .newPassword
        confirmPasswordTextField.autocapitalizationType = .none
        confirmPasswordTextField.autocorrectionType = .no
        confirmPasswordTextField.delegate = self

        resetButton.setTitle("Restablecer Contraseña", for: .normal)
        resetButton.isEnabled = false

        passwordStrengthView.isHidden = true

        // Hide activity indicator
        activityIndicator.isHidden = true
    }

    private func validateToken() {
        guard let token = resetToken else {
            showError("Enlace inválido", message: "No se proporcionó un token de restablecimiento válido.")
            return
        }

        isValidatingToken = true
        showActivityIndicator()

        LoginManager.shared.validateResetToken(token: token) { [weak self] result in
            guard let self = self else { return }

            self.hideActivityIndicator()
            self.isValidatingToken = false

            switch result {
            case .success(let response):
                if response.valid {
                    // Token is valid, enable password entry
                    self.enablePasswordEntry()
                    if let email = response.email {
                        self.descriptionLabel.text = "Restableciendo contraseña para \(email)"
                    }
                } else {
                    self.showError("Enlace Inválido", message: response.error ?? "Este enlace no es válido.")
                }

            case .failure(let error):
                self.showError("Error", message: error.localizedDescription)
            }
        }
    }

    private func enablePasswordEntry() {
        passwordTextField.isEnabled = true
        confirmPasswordTextField.isEnabled = true
        resetButton.isEnabled = true
    }

    // MARK: - Actions

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        guard let password = passwordTextField.text, !password.isEmpty else {
            Utils.showAlertMessage("Por favor ingresa una contraseña", title: "Contraseña Requerida", viewControler: self)
            return
        }

        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            Utils.showAlertMessage("Por favor confirma tu contraseña", title: "Confirmación Requerida", viewControler: self)
            return
        }

        guard password == confirmPassword else {
            Utils.showAlertMessage("Las contraseñas no coinciden", title: "Error", viewControler: self)
            return
        }

        guard password.count >= 4 else {
            Utils.showAlertMessage("La contraseña debe tener al menos 4 caracteres", title: "Contraseña Débil", viewControler: self)
            return
        }

        guard let token = resetToken else {
            showError("Error", message: "Token inválido")
            return
        }

        performPasswordReset(token: token, password: password, passwordConfirm: confirmPassword)
    }

    private func performPasswordReset(token: String, password: String, passwordConfirm: String) {
        showActivityIndicator()
        resetButton.isEnabled = false

        LoginManager.shared.resetPasswordV2(token: token, password: password, passwordConfirm: passwordConfirm) { [weak self] result in
            guard let self = self else { return }

            self.hideActivityIndicator()
            self.resetButton.isEnabled = true

            switch result {
            case .success(let response):
                if response.success {
                    self.showSuccessAndDismiss(message: response.message ?? "Contraseña actualizada exitosamente")
                } else {
                    self.showError("Error", message: response.error ?? "No se pudo actualizar la contraseña")
                }

            case .failure(let error):
                self.showError("Error", message: error.localizedDescription)
            }
        }
    }

    // MARK: - UI Helpers

    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    private func showError(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true, completion: nil)
    }

    private func showSuccessAndDismiss(message: String) {
        let alert = UIAlertController(title: "Éxito", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Navigate to login screen
            self?.navigateToLogin()
        })
        present(alert, animated: true, completion: nil)
    }

    private func navigateToLogin() {
        // Dismiss this view controller and any other modals
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true) {
                // Post notification to show login screen
                NotificationCenter.default.post(name: NSNotification.Name("ShowLoginScreen"), object: nil)
            }
        }
    }

    // MARK: - Password Strength

    private func updatePasswordStrength() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            passwordStrengthView.isHidden = true
            return
        }

        passwordStrengthView.isHidden = false

        let strength = calculatePasswordStrength(password)

        switch strength {
        case .weak:
            passwordStrengthLabel.text = "Débil"
            passwordStrengthLabel.textColor = .red
        case .medium:
            passwordStrengthLabel.text = "Media"
            passwordStrengthLabel.textColor = .orange
        case .strong:
            passwordStrengthLabel.text = "Fuerte"
            passwordStrengthLabel.textColor = .green
        }
    }

    private func calculatePasswordStrength(_ password: String) -> PasswordStrength {
        let length = password.count
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigits = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecialChars = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil

        var score = 0
        if length >= 8 { score += 1 }
        if length >= 12 { score += 1 }
        if hasUppercase { score += 1 }
        if hasLowercase { score += 1 }
        if hasDigits { score += 1 }
        if hasSpecialChars { score += 1 }

        if score <= 2 { return .weak }
        if score <= 4 { return .medium }
        return .strong
    }

    enum PasswordStrength {
        case weak, medium, strong
    }
}

// MARK: - UITextFieldDelegate

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == passwordTextField {
            updatePasswordStrength()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            textField.resignFirstResponder()
            if resetButton.isEnabled {
                resetButtonPressed(resetButton)
            }
        }
        return true
    }
}
```

### Step 7: Setup Deep Links

**File:** `Jabrutouch/AppDelegate.swift`

Add URL scheme handling:

```swift
// MARK: - URL Handling (Deep Links)

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Handle password reset deep link: jabrutouch://reset?token=xxx

    if url.scheme == "jabrutouch" && url.host == "reset" {
        handlePasswordResetLink(url)
        return true
    }

    // Handle other deep links (Firebase, etc.)
    // ... existing code ...

    return false
}

private func handlePasswordResetLink(_ url: URL) {
    // Extract token from URL
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems,
          let tokenItem = queryItems.first(where: { $0.name == "token" }),
          let token = tokenItem.value else {
        print("❌ Invalid password reset link: missing token")
        return
    }

    print("🔑 Password reset deep link received with token")

    // Navigate to ResetPasswordViewController
    DispatchQueue.main.async {
        self.navigateToResetPassword(token: token)
    }
}

private func navigateToResetPassword(token: String) {
    guard let window = self.window,
          let rootViewController = window.rootViewController else {
        return
    }

    // Get or create ResetPasswordViewController
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let resetVC = storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController else {
        print("❌ Could not instantiate ResetPasswordViewController")
        return
    }

    resetVC.resetToken = token

    // Present modally
    if let navController = rootViewController as? UINavigationController {
        navController.pushViewController(resetVC, animated: true)
    } else if let presentedVC = rootViewController.presentedViewController {
        presentedVC.present(resetVC, animated: true, completion: nil)
    } else {
        rootViewController.present(resetVC, animated: true, completion: nil)
    }
}
```

**File:** `Jabrutouch/Info.plist`

Add URL scheme (if not already present):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.ravtech.jabrutouch</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>jabrutouch</string>
        </array>
    </dict>
</array>
```

---

## API Versioning Strategy

### Backward Compatibility

**Keep Old Endpoint Active:**
- `POST /api/reset_password/` - Legacy endpoint (insecure, but needed for old app versions)
- Old iOS app versions will continue to work

**New Endpoints:**
- `POST /api/v2/password/forgot` - Request reset token
- `POST /api/v2/password/validate-token` - Validate token (optional)
- `POST /api/v2/password/reset` - Reset password with token

### Migration Timeline

**Phase 1: Implement V2 (Week 1-2)**
- Add V2 endpoints to backend
- Add V2 functionality to iOS app
- Keep V1 endpoint active

**Phase 2: Update iOS App (Week 3)**
- Submit new app version with V2 to App Store
- Monitor adoption rate

**Phase 3: Deprecation (Month 2-3)**
- Add deprecation notice to V1 endpoint logs
- Track V1 usage vs V2 usage
- Email users to update app

**Phase 4: Sunset V1 (Month 6)**
- Once 95%+ of users on V2, disable V1
- Return HTTP 410 Gone with update message

---

## Email Configuration

### Current Setup (Django)

**File:** `/jabrutouch_server/jabrutouch_server/settings.py`

```python
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_HOST_USER = os.getenv("EMAIL_HOST_USER")
EMAIL_HOST_PASSWORD = os.getenv("EMAIL_HOST_PASSWORD")
EMAIL_USE_TLS = True  # Ensure this is set
```

### Email Template (HTML - Recommended)

**Create:** `/jabrutouch_server/jabrutouch_api/templates/password_reset_email.html`

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restablecer Contraseña - Jabrutouch</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            text-align: center;
            padding: 20px;
            background-color: #4A90E2;
            color: white;
            border-radius: 8px 8px 0 0;
        }
        .content {
            background-color: #f9f9f9;
            padding: 30px;
            border-radius: 0 0 8px 8px;
        }
        .button {
            display: inline-block;
            padding: 15px 30px;
            background-color: #4A90E2;
            color: white !important;
            text-decoration: none;
            border-radius: 5px;
            margin: 20px 0;
            font-weight: bold;
        }
        .button:hover {
            background-color: #357ABD;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            font-size: 12px;
            color: #666;
        }
        .warning {
            background-color: #FFF3CD;
            border-left: 4px solid #FFC107;
            padding: 10px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Restablecer Contraseña</h1>
    </div>
    <div class="content">
        <p>Hola {{ user.first_name }},</p>

        <p>Recibimos una solicitud para restablecer tu contraseña de Jabrutouch.</p>

        <p>Para restablecer tu contraseña, toca el siguiente botón desde tu dispositivo móvil:</p>

        <p style="text-align: center;">
            <a href="{{ reset_link }}" class="button">Restablecer Contraseña</a>
        </p>

        <div class="warning">
            <strong>⚠️ Importante:</strong> Este enlace expirará en {{ expires_hours }} hora(s) por motivos de seguridad.
        </div>

        <p><strong>Si no solicitaste este cambio:</strong></p>
        <ul>
            <li>Ignora este correo</li>
            <li>Tu contraseña permanecerá sin cambios</li>
            <li>Considera cambiar tu contraseña si recibes múltiples correos no solicitados</li>
        </ul>

        <p>Si tienes problemas para tocar el botón, copia y pega este enlace en tu navegador móvil:</p>
        <p style="word-break: break-all; font-size: 12px; background-color: #f0f0f0; padding: 10px; border-radius: 4px;">
            {{ reset_link }}
        </p>

        <p>Saludos,<br>El equipo de Jabrutouch</p>
    </div>
    <div class="footer">
        <p>Este es un correo automático, por favor no respondas a este mensaje.</p>
        <p>Si necesitas ayuda, contáctanos en {{ support_email }}</p>
    </div>
</body>
</html>
```

**Update send_reset_email function to use template:**

```python
from django.template.loader import render_to_string

def send_reset_email(user, token, request):
    """Send password reset email with HTML template"""
    reset_link = f"jabrutouch://reset?token={token}"

    context = {
        'user': user,
        'reset_link': reset_link,
        'expires_hours': 1,
        'support_email': settings.EMAIL_HOST_USER
    }

    html_message = render_to_string('password_reset_email.html', context)
    plain_message = f"""
Hola {user.first_name},

Recibimos una solicitud para restablecer tu contraseña de Jabrutouch.

Para restablecer tu contraseña, toca este enlace desde tu dispositivo móvil:
{reset_link}

Este enlace expirará en 1 hora por motivos de seguridad.

Si no solicitaste este cambio, ignora este correo.

Saludos,
El equipo de Jabrutouch
"""

    try:
        send_mail(
            'Restablecer Contraseña - Jabrutouch',
            plain_message,
            f'Jabrutouch <{settings.EMAIL_HOST_USER}>',
            [user.email],
            fail_silently=False,
            html_message=html_message,
        )
        return True
    except Exception as e:
        print(f"❌ Email send failed: {e}")
        return False
```

---

## Security Best Practices

### Token Generation

✅ **DO:**
- Use `secrets.token_urlsafe()` (cryptographically secure)
- Generate 32+ bytes (256+ bits of entropy)
- Use URL-safe encoding for deep links

❌ **DON'T:**
- Use `random.randint()` (not cryptographically secure)
- Use sequential IDs
- Use predictable patterns (timestamp + user ID)

### Token Storage

✅ **DO:**
- Store tokens in database with indexes
- Track creation time, expiration, and usage
- Log IP address and user agent for security audits
- Invalidate all unused tokens when creating new one

❌ **DON'T:**
- Store tokens in session storage
- Allow multiple active tokens per user
- Reuse tokens

### Token Validation

✅ **DO:**
- Check token exists
- Check token not expired
- Check token not already used
- Mark token as used immediately after password reset
- Use constant-time comparison to prevent timing attacks

❌ **DON'T:**
- Allow expired tokens
- Allow token reuse
- Reveal why token is invalid (timing attack vector)

### Email Security

✅ **DO:**
- Use HTTPS/TLS for SMTP connection
- Include company branding in email
- Warn users about phishing
- Send confirmation email after password change
- Rate limit reset requests per email

❌ **DON'T:**
- Include passwords in email
- Include sensitive user data in email
- Use HTTP links in email

### User Enumeration Prevention

✅ **DO:**
- Return same success message for all emails
- Take same amount of time for existing/non-existing users
- Log all attempts for security monitoring

❌ **DON'T:**
- Reveal if email exists in system
- Return different error messages
- Return different HTTP status codes

---

## Testing Strategy

### Backend Tests

**File:** `/jabrutouch_server/jabrutouch_api/tests/test_password_reset_v2.py` (NEW)

```python
from django.test import TestCase, Client
from django.utils import timezone
from datetime import timedelta
from jabrutouch_api.models import User, PasswordResetToken


class PasswordResetV2TestCase(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='oldpassword123',
            first_name='Test'
        )

    def test_forgot_password_existing_user(self):
        """Test requesting password reset for existing user"""
        response = self.client.post('/api/v2/password/forgot/', {
            'email': 'test@example.com'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()['success'])

        # Check token was created
        token = PasswordResetToken.objects.filter(user=self.user).first()
        self.assertIsNotNone(token)
        self.assertFalse(token.used)

    def test_forgot_password_nonexistent_user(self):
        """Test requesting password reset for non-existent user returns success (security)"""
        response = self.client.post('/api/v2/password/forgot/', {
            'email': 'nonexistent@example.com'
        }, content_type='application/json')

        # Should return success to prevent user enumeration
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()['success'])

        # No token should be created
        self.assertEqual(PasswordResetToken.objects.count(), 0)

    def test_validate_valid_token(self):
        """Test validating a valid token"""
        token = PasswordResetToken.objects.create(
            user=self.user,
            token='valid_token_123',
            expires_at=timezone.now() + timedelta(hours=1)
        )

        response = self.client.post('/api/v2/password/validate-token/', {
            'token': 'valid_token_123'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()['valid'])

    def test_validate_expired_token(self):
        """Test validating an expired token"""
        token = PasswordResetToken.objects.create(
            user=self.user,
            token='expired_token_123',
            expires_at=timezone.now() - timedelta(hours=1)
        )

        response = self.client.post('/api/v2/password/validate-token/', {
            'token': 'expired_token_123'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 400)
        self.assertFalse(response.json()['valid'])

    def test_reset_password_with_valid_token(self):
        """Test resetting password with valid token"""
        token = PasswordResetToken.objects.create(
            user=self.user,
            token='reset_token_123',
            expires_at=timezone.now() + timedelta(hours=1)
        )

        response = self.client.post('/api/v2/password/reset/', {
            'token': 'reset_token_123',
            'password': 'newpassword456',
            'password_confirm': 'newpassword456'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()['success'])

        # Check password was updated
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password('newpassword456'))

        # Check token was marked as used
        token.refresh_from_db()
        self.assertTrue(token.used)

    def test_reset_password_with_mismatched_passwords(self):
        """Test that mismatched passwords are rejected"""
        token = PasswordResetToken.objects.create(
            user=self.user,
            token='reset_token_456',
            expires_at=timezone.now() + timedelta(hours=1)
        )

        response = self.client.post('/api/v2/password/reset/', {
            'token': 'reset_token_456',
            'password': 'newpassword456',
            'password_confirm': 'differentpassword'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 400)

    def test_reset_password_twice_with_same_token(self):
        """Test that tokens can only be used once"""
        token = PasswordResetToken.objects.create(
            user=self.user,
            token='onetime_token',
            expires_at=timezone.now() + timedelta(hours=1)
        )

        # First reset
        response1 = self.client.post('/api/v2/password/reset/', {
            'token': 'onetime_token',
            'password': 'newpassword789',
            'password_confirm': 'newpassword789'
        }, content_type='application/json')

        self.assertEqual(response1.status_code, 200)

        # Second reset with same token
        response2 = self.client.post('/api/v2/password/reset/', {
            'token': 'onetime_token',
            'password': 'anotherpassword',
            'password_confirm': 'anotherpassword'
        }, content_type='application/json')

        self.assertEqual(response2.status_code, 400)
        self.assertFalse(response2.json()['success'])
```

**Run tests:**
```bash
cd jabrutouch_server/jabrutouch_server
python manage.py test jabrutouch_api.tests.test_password_reset_v2
```

### iOS Tests (Unit Tests)

**File:** `JabrutouchTests/PasswordResetV2Tests.swift` (NEW)

```swift
import XCTest
@testable import Jabrutouch

class PasswordResetV2Tests: XCTestCase {

    func testForgotPasswordV2Request() {
        let email = "test@example.com"
        let request = HttpRequestsFactory.forgotPasswordV2Request(email: email)

        XCTAssertNotNil(request)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertTrue(request?.url?.absoluteString.contains("v2/password/forgot") ?? false)

        if let body = request?.httpBody,
           let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            XCTAssertEqual(json["email"] as? String, email)
        } else {
            XCTFail("Request body is invalid")
        }
    }

    func testResetPasswordV2Request() {
        let token = "test_token_123"
        let password = "newpassword"
        let request = HttpRequestsFactory.resetPasswordV2Request(
            token: token,
            password: password,
            passwordConfirm: password
        )

        XCTAssertNotNil(request)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertTrue(request?.url?.absoluteString.contains("v2/password/reset") ?? false)

        if let body = request?.httpBody,
           let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            XCTAssertEqual(json["token"] as? String, token)
            XCTAssertEqual(json["password"] as? String, password)
            XCTAssertEqual(json["password_confirm"] as? String, password)
        } else {
            XCTFail("Request body is invalid")
        }
    }

    func testDeepLinkParsing() {
        let urlString = "jabrutouch://reset?token=abc123xyz"
        guard let url = URL(string: urlString) else {
            XCTFail("Invalid URL")
            return
        }

        XCTAssertEqual(url.scheme, "jabrutouch")
        XCTAssertEqual(url.host, "reset")

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let tokenItem = queryItems.first(where: { $0.name == "token" }) {
            XCTAssertEqual(tokenItem.value, "abc123xyz")
        } else {
            XCTFail("Failed to parse token from URL")
        }
    }
}
```

### Manual Testing Checklist

#### Backend Testing

- [ ] **Forgot Password - Existing User**
  ```bash
  curl -X POST http://localhost:8000/api/v2/password/forgot/ \
    -H "Content-Type: application/json" \
    -d '{"email":"existing@user.com"}'
  ```
  - Should return success message
  - Should create token in database
  - Should send email

- [ ] **Forgot Password - Non-Existent User**
  ```bash
  curl -X POST http://localhost:8000/api/v2/password/forgot/ \
    -H "Content-Type: application/json" \
    -d '{"email":"nonexistent@user.com"}'
  ```
  - Should return SAME success message
  - Should NOT create token
  - Should NOT send email

- [ ] **Validate Token - Valid**
  ```bash
  curl -X POST http://localhost:8000/api/v2/password/validate-token/ \
    -H "Content-Type: application/json" \
    -d '{"token":"<valid_token>"}'
  ```
  - Should return `{"valid": true}`

- [ ] **Validate Token - Expired**
  - Manually set token `expires_at` to past date
  - Should return `{"valid": false, "error": "...expired..."}`

- [ ] **Reset Password - Valid Token**
  ```bash
  curl -X POST http://localhost:8000/api/v2/password/reset/ \
    -H "Content-Type: application/json" \
    -d '{
      "token":"<valid_token>",
      "password":"newpass123",
      "password_confirm":"newpass123"
    }'
  ```
  - Should return success
  - Should update password in database
  - Should mark token as used
  - Should send confirmation email

- [ ] **Reset Password - Reuse Token**
  - Try using same token twice
  - Should fail with "already used" error

#### iOS App Testing

- [ ] **Forgot Password Flow**
  - Enter valid email
  - Should show success message
  - Should receive email

- [ ] **Email Deep Link**
  - Click link in email
  - Should open app
  - Should navigate to ResetPasswordViewController

- [ ] **Reset Password Form**
  - Enter new password
  - Confirm password
  - Should update password
  - Should navigate to login

- [ ] **Password Validation**
  - Test weak passwords (rejected)
  - Test mismatched passwords (rejected)
  - Test valid passwords (accepted)

- [ ] **Error Handling**
  - Test expired token
  - Test invalid token
  - Test network errors

---

## Monitoring & Logging

### Backend Logs to Add

```python
import logging

logger = logging.getLogger(__name__)

# In forgot_password_v2:
logger.info(f"Password reset requested for email: {email[:3]}***@{email.split('@')[1]}")

# In reset_password_v2:
logger.info(f"Password reset completed for user ID: {user.id}")
logger.warning(f"Password reset attempted with expired token for user ID: {token.user.id}")
logger.error(f"Password reset failed with invalid token: {token_value[:10]}...")
```

### Metrics to Track

1. **Reset Request Rate**
   - Number of forgot password requests per hour
   - Alert if spike (possible abuse)

2. **Token Usage Rate**
   - Percentage of tokens that get used
   - Low rate may indicate email delivery issues

3. **Time to Reset**
   - Time between token creation and password reset
   - Helps optimize token expiration time

4. **Failed Reset Attempts**
   - Number of expired/invalid token errors
   - May indicate UX issues

### Admin Dashboard

Create Django admin views for monitoring:

```python
# admin.py
from django.contrib import admin
from jabrutouch_api.models import PasswordResetToken

@admin.register(PasswordResetToken)
class PasswordResetTokenAdmin(admin.ModelAdmin):
    list_display = ('user', 'created', 'expires_at', 'used', 'used_at')
    list_filter = ('used', 'created', 'expires_at')
    search_fields = ('user__email', 'user__first_name', 'user__last_name')
    readonly_fields = ('token', 'created', 'updated', 'user', 'used', 'used_at', 'ip_address', 'user_agent')

    def has_add_permission(self, request):
        return False  # Don't allow manual token creation

    def has_delete_permission(self, request, obj=None):
        return True  # Allow cleanup of old tokens
```

---

## Deployment Checklist

### Backend Deployment

- [ ] Run migrations
  ```bash
  python manage.py makemigrations
  python manage.py migrate
  ```

- [ ] Update environment variables
  ```bash
  EMAIL_HOST_USER=<gmail-account>
  EMAIL_HOST_PASSWORD=<app-password>
  ```

- [ ] Test email sending in production
  ```bash
  python manage.py shell
  from django.core.mail import send_mail
  send_mail('Test', 'Test message', 'from@example.com', ['to@example.com'])
  ```

- [ ] Deploy code to server
  ```bash
  git pull
  systemctl restart gunicorn
  ```

- [ ] Verify endpoints are accessible
  ```bash
  curl https://api.jabrutouch.com/api/v2/password/forgot/
  ```

- [ ] Setup monitoring alerts

### iOS Deployment

- [ ] Test on physical devices (not just simulator)
  - Test deep link handling
  - Test email client integration

- [ ] Update version number
  - Increment CFBundleShortVersionString
  - Increment CFBundleVersion

- [ ] Submit to App Store
  - Add release notes mentioning improved password reset
  - Test TestFlight build before release

- [ ] Monitor crash reports
  - Check for deep link parsing errors
  - Check for network errors

---

## Rollback Plan

### If Issues Arise

1. **Backend Issues:**
   - Revert migration if database issues
     ```bash
     python manage.py migrate jabrutouch_api <previous_migration>
     ```
   - Disable V2 endpoints temporarily
   - V1 still works as fallback

2. **iOS Issues:**
   - Users can still use V1 flow
   - Submit hotfix if critical bug
   - Expedite App Store review if needed

3. **Email Issues:**
   - Check SMTP credentials
   - Check rate limits
   - Fall back to V1 if email completely broken

---

## Future Enhancements

### Phase 2 Improvements

1. **SMS Reset Option**
   - Add SMS-based reset for users without email

2. **Two-Factor Authentication**
   - Require 2FA code before password reset

3. **Social Login Recovery**
   - Allow password reset via Google/Facebook

4. **Account Recovery Flow**
   - Comprehensive flow for locked accounts

5. **Security Notifications**
   - Email when password changed from new device
   - Email when suspicious reset attempts

6. **Password History**
   - Prevent reusing last 5 passwords

7. **Biometric Reset**
   - Use Face ID/Touch ID for password reset on same device

---

## Summary

### Current State
- **Insecure:** Sends 4-digit passwords via email
- **Backend:** Django (legacy) actively handling password reset
- **Laravel:** Available but not implemented
- **User Enumeration:** Vulnerable to email harvesting

### Target State
- **Secure:** Token-based reset with 1-hour expiration
- **Deep Links:** Seamless app integration
- **User Enumeration:** Protected (generic success messages)
- **Backward Compatible:** Old app versions still work

### Estimated Effort
- **Backend (Django):** 8-12 hours
  - Models & migrations: 2 hours
  - Views & serializers: 4 hours
  - Email templates: 2 hours
  - Testing: 2-4 hours

- **iOS App:** 12-16 hours
  - Models & API layer: 3 hours
  - UI (ResetPasswordViewController): 4 hours
  - Deep link handling: 3 hours
  - Testing & polish: 2-4 hours

- **Total:** 20-28 hours (2.5-3.5 developer-days)

### Priority
**HIGH** - Security vulnerability should be addressed soon

### Next Steps
1. Get approval for implementation timeline
2. Create feature branch: `feature/password-reset-v2`
3. Implement backend first (can be tested with curl)
4. Implement iOS app second
5. Test end-to-end flow
6. Submit iOS app update
7. Monitor adoption
8. Deprecate V1 after 95%+ adoption

---

**Document Version:** 1.0
**Last Updated:** 2025-10-12
**Author:** Claude Code Analysis
**Status:** Ready for Implementation
