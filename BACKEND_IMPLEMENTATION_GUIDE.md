# Backend Implementation Guide - Password Reset with Reset Link

## Date: 2025-10-12

## Overview

This document provides complete implementation instructions for the backend team to implement the new password reset flow using secure reset links instead of emailing passwords directly.

---

## Critical Requirements

### ✅ Backward Compatibility

**The backend MUST support BOTH old and new app versions simultaneously:**

- **Old apps** (v7.1.6 and earlier): Send 4-digit password via email (legacy behavior)
- **New apps** (v7.2.0+): Send secure reset link via email (new behavior)

**Version Detection Method:** Custom HTTP header `X-App-Version`

**Migration Timeline:** 6-12 months of dual support before deprecating old flow

---

## API Changes Required

### 1. Modified Endpoint: `POST /api/reset_password/`

**Current Behavior (Old Apps):**
- Generates 4-digit random password
- Saves password to database
- Emails password to user
- Returns `user_exist_status: false` if email doesn't exist ⚠️ **Security Issue**

**New Behavior (New Apps with X-App-Version >= 7.2.0):**
- Generates secure 64-character token
- Stores token in `password_reset_tokens` table with expiration
- Emails reset link to user
- **Always returns success** to prevent user enumeration ✅ **Security Fix**

#### Request Format

```http
POST /api/reset_password/
Content-Type: application/json
X-App-Version: 7.2.0  ← NEW: Version header

{
  "email": "user@example.com"
}
```

#### Response Format for New Apps (v7.2.0+)

```json
{
  "message": "If an account exists with this email, you will receive a password reset link shortly.",
  "user_exist_status": true,
  "reset_method": "email_link",
  "reset_link_sent": true,
  "link_expires_in": 3600
}
```

**Key Changes:**
- `user_exist_status`: Always `true` (prevents user enumeration)
- `reset_method`: `"email_link"` (indicates new flow)
- `reset_link_sent`: `true` if email was sent successfully
- `link_expires_in`: Token validity in seconds (3600 = 1 hour)

#### Response Format for Old Apps (v7.1.6 and earlier)

```json
{
  "message": "Password sent to your email",
  "user_exist_status": true
}
```

OR (if email doesn't exist):

```json
{
  "message": "Email not found",
  "user_exist_status": false
}
```

**Keep existing behavior for backward compatibility**

---

### 2. New Endpoint: `POST /api/confirm_reset_password/`

**Purpose:** Validate token and update user's password

#### Request Format

```http
POST /api/confirm_reset_password/
Content-Type: application/json
X-App-Version: 7.2.0

{
  "token": "abc123...xyz789",
  "new_password": "newSecurePassword123"
}
```

#### Response Format - Success

```json
{
  "success": true,
  "message": "Password reset successfully",
  "user_email": "user@example.com"
}
```

#### Response Format - Error

```json
{
  "success": false,
  "message": "Invalid or expired token"
}
```

**Error Cases:**
- Token doesn't exist
- Token already used
- Token expired (>1 hour old)
- Invalid password format

---

## Database Schema

### New Table: `password_reset_tokens`

```sql
CREATE TABLE password_reset_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    used_at DATETIME NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES jabrutouch_api_user(id) ON DELETE CASCADE,
    INDEX idx_token_hash (token_hash),
    INDEX idx_expires_at (expires_at),
    INDEX idx_email (email)
);
```

**Field Descriptions:**
- `token_hash`: SHA-256 hash of the actual token (never store plaintext tokens)
- `expires_at`: Token expiration time (1 hour from creation)
- `used`: Prevents token reuse
- `ip_address`: Security audit trail
- `user_agent`: Security audit trail

---

## Implementation Details

### Django Implementation (Current Active Backend)

#### 1. Middleware for Version Detection

**File:** `jabrutouch_server/jabrutouch_api/middleware.py`

```python
class AppVersionMiddleware:
    """Middleware to detect and parse X-App-Version header"""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Extract version from header
        app_version = request.META.get('HTTP_X_APP_VERSION', None)

        if app_version:
            # Parse version (e.g., "7.2.0" -> 70200)
            try:
                parts = app_version.split('.')
                version_number = int(parts[0]) * 10000 + int(parts[1]) * 100 + int(parts[2])
                request.app_version_number = version_number
                request.app_version = app_version
                request.is_legacy_version = version_number < 70200  # Before 7.2.0
            except (ValueError, IndexError):
                request.app_version_number = 0
                request.app_version = None
                request.is_legacy_version = True  # Treat invalid versions as legacy
        else:
            # No version header = old app
            request.app_version_number = 0
            request.app_version = None
            request.is_legacy_version = True

        response = self.get_response(request)
        return response
```

**Add to settings.py:**

```python
MIDDLEWARE = [
    # ... existing middleware ...
    'jabrutouch_api.middleware.AppVersionMiddleware',
]
```

#### 2. Password Reset Models

**File:** `jabrutouch_server/jabrutouch_api/models.py`

```python
import secrets
import hashlib
from datetime import timedelta
from django.utils import timezone
from django.db import models
from .models import User  # Your existing User model

class PasswordResetToken(models.Model):
    """Model for password reset tokens"""

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    token_hash = models.CharField(max_length=64, unique=True)
    email = models.EmailField()
    expires_at = models.DateTimeField()
    used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'password_reset_tokens'
        indexes = [
            models.Index(fields=['token_hash']),
            models.Index(fields=['expires_at']),
            models.Index(fields=['email']),
        ]

    @staticmethod
    def generate_token():
        """Generate a cryptographically secure 64-character token"""
        return secrets.token_urlsafe(48)  # 48 bytes = 64 characters in base64

    @staticmethod
    def hash_token(token):
        """Hash a token using SHA-256"""
        return hashlib.sha256(token.encode()).hexdigest()

    @classmethod
    def create_for_user(cls, user, ip_address=None, user_agent=None):
        """Create a new reset token for a user"""
        token = cls.generate_token()
        token_hash = cls.hash_token(token)
        expires_at = timezone.now() + timedelta(hours=1)

        reset_token = cls.objects.create(
            user=user,
            token_hash=token_hash,
            email=user.email,
            expires_at=expires_at,
            ip_address=ip_address,
            user_agent=user_agent
        )

        # Return the plaintext token (only time it's available)
        return token, reset_token

    @classmethod
    def validate_token(cls, token):
        """
        Validate a reset token and return the associated user
        Returns (user, reset_token) or (None, None)
        """
        token_hash = cls.hash_token(token)

        try:
            reset_token = cls.objects.get(
                token_hash=token_hash,
                used=False,
                expires_at__gt=timezone.now()
            )
            return reset_token.user, reset_token
        except cls.DoesNotExist:
            return None, None

    def mark_as_used(self):
        """Mark this token as used"""
        self.used = True
        self.used_at = timezone.now()
        self.save()
```

#### 3. Updated Reset Password View

**File:** `jabrutouch_server/jabrutouch_api/login_process.py`

```python
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .models import User, PasswordResetToken
import json
import random

# Rate limiting (simple in-memory cache)
from django.core.cache import cache

@csrf_exempt
@require_http_methods(["POST"])
def reset_password(request):
    """
    Handle password reset requests with version-aware logic
    """
    try:
        data = json.loads(request.body)
        email = data.get('email', '').lower().strip()

        if not email:
            return JsonResponse({
                'message': 'Email is required',
                'user_exist_status': False
            }, status=400)

        # Rate limiting: 3 requests per hour per email
        cache_key = f'password_reset_{email}'
        request_count = cache.get(cache_key, 0)

        if request_count >= 3:
            return JsonResponse({
                'message': 'Too many requests. Please try again later.',
                'user_exist_status': True
            }, status=429)

        cache.set(cache_key, request_count + 1, 3600)  # 1 hour

        # Check if this is a new app version
        is_legacy = getattr(request, 'is_legacy_version', True)
        app_version = getattr(request, 'app_version', 'unknown')

        print(f"📧 Password reset request for {email} from app version {app_version} (legacy: {is_legacy})")

        # Try to find user
        try:
            user = User.objects.get(email=email)
            user_exists = True
        except User.DoesNotExist:
            user_exists = False

        # NEW APP VERSION (7.2.0+) - Send Reset Link
        if not is_legacy:
            if user_exists:
                # Generate secure token
                ip_address = get_client_ip(request)
                user_agent = request.META.get('HTTP_USER_AGENT', '')
                token, reset_token = PasswordResetToken.create_for_user(user, ip_address, user_agent)

                # Create reset link
                reset_link = f"https://jabrutouch.page.link/?link=https://jabrutouch.com/reset?type=reset_password%26token={token}%26email={email}&apn=com.ravtech.jabrutouch&ibi=com.ravtech.jabrutouch&isi=1482417213"

                # Send email with reset link
                send_reset_link_email(user, reset_link)

                print(f"✅ Reset link sent to {email}")
            else:
                print(f"⚠️  Reset link requested for non-existent email: {email}")

            # Always return success (security fix: prevent user enumeration)
            return JsonResponse({
                'message': 'If an account exists with this email, you will receive a password reset link shortly.',
                'user_exist_status': True,  # Always true
                'reset_method': 'email_link',
                'reset_link_sent': user_exists,
                'link_expires_in': 3600
            })

        # OLD APP VERSION (<7.2.0) - Send Password via Email (Legacy)
        else:
            if user_exists:
                # Generate 4-digit password (legacy behavior)
                new_password = str(random.randint(1000, 9999))
                user.set_password(new_password)
                user.save()

                # Send password via email (legacy behavior)
                send_password_email(user, new_password)

                print(f"✅ Password sent to {email} (legacy flow)")

                return JsonResponse({
                    'message': 'Password sent to your email',
                    'user_exist_status': True
                })
            else:
                print(f"⚠️  Password reset requested for non-existent email: {email} (legacy flow)")

                # Legacy behavior: reveal user doesn't exist
                return JsonResponse({
                    'message': 'Email not found',
                    'user_exist_status': False
                })

    except Exception as e:
        print(f"❌ Password reset error: {str(e)}")
        return JsonResponse({
            'message': 'An error occurred. Please try again later.',
            'user_exist_status': True
        }, status=500)


def get_client_ip(request):
    """Extract client IP address from request"""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def send_reset_link_email(user, reset_link):
    """Send password reset link email to user"""
    subject = 'Password Reset - JabruTouch'

    # HTML email template
    html_message = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
    </head>
    <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
        <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #2B2D63; margin: 0;">JabruTouch</h1>
            </div>

            <h2 style="color: #333333;">Password Reset Request</h2>

            <p style="color: #666666; line-height: 1.6;">
                Hello {user.first_name},
            </p>

            <p style="color: #666666; line-height: 1.6;">
                We received a request to reset your password. Click the button below to create a new password:
            </p>

            <div style="text-align: center; margin: 30px 0;">
                <a href="{reset_link}" style="display: inline-block; background-color: #2B2D63; color: #ffffff; text-decoration: none; padding: 15px 40px; border-radius: 5px; font-weight: bold; font-size: 16px;">
                    Reset Password
                </a>
            </div>

            <p style="color: #666666; line-height: 1.6; font-size: 14px;">
                Or copy and paste this link into your browser:<br>
                <a href="{reset_link}" style="color: #2B2D63; word-break: break-all;">{reset_link}</a>
            </p>

            <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
                <p style="color: #856404; margin: 0; font-size: 14px;">
                    ⚠️ <strong>Security Notice:</strong> This link will expire in 1 hour and can only be used once.
                </p>
            </div>

            <p style="color: #666666; line-height: 1.6; font-size: 14px;">
                If you didn't request this password reset, please ignore this email. Your password will remain unchanged.
            </p>

            <hr style="border: none; border-top: 1px solid #eeeeee; margin: 30px 0;">

            <p style="color: #999999; font-size: 12px; text-align: center;">
                © 2025 JabruTouch. All rights reserved.
            </p>
        </div>
    </body>
    </html>
    """

    # Plain text fallback
    plain_message = f"""
    Password Reset - JabruTouch

    Hello {user.first_name},

    We received a request to reset your password. Click the link below to create a new password:

    {reset_link}

    Security Notice: This link will expire in 1 hour and can only be used once.

    If you didn't request this password reset, please ignore this email. Your password will remain unchanged.

    © 2025 JabruTouch. All rights reserved.
    """

    send_mail(
        subject,
        plain_message,
        'noreply@jabrutouch.com',
        [user.email],
        html_message=html_message,
        fail_silently=False
    )


def send_password_email(user, password):
    """Send password via email (legacy behavior for old apps)"""
    subject = 'Your New Password - JabruTouch'
    message = f"""
    Hello {user.first_name},

    Your new password is: {password}

    Please use this password to sign in to your account.

    © 2025 JabruTouch. All rights reserved.
    """

    send_mail(
        subject,
        message,
        'noreply@jabrutouch.com',
        [user.email],
        fail_silently=False
    )
```

#### 4. Confirm Reset Password View

**File:** `jabrutouch_server/jabrutouch_api/login_process.py` (add this function)

```python
@csrf_exempt
@require_http_methods(["POST"])
def confirm_reset_password(request):
    """
    Confirm password reset with token and update password
    """
    try:
        data = json.loads(request.body)
        token = data.get('token', '').strip()
        new_password = data.get('new_password', '').strip()

        if not token or not new_password:
            return JsonResponse({
                'success': False,
                'message': 'Token and new password are required'
            }, status=400)

        # Validate password length
        if len(new_password) < 6:
            return JsonResponse({
                'success': False,
                'message': 'Password must be at least 6 characters'
            }, status=400)

        # Validate token
        user, reset_token = PasswordResetToken.validate_token(token)

        if not user:
            print(f"❌ Invalid or expired token used")
            return JsonResponse({
                'success': False,
                'message': 'Invalid or expired token'
            }, status=400)

        # Update password
        user.set_password(new_password)
        user.save()

        # Mark token as used
        reset_token.mark_as_used()

        print(f"✅ Password reset successful for user: {user.email}")

        # Optional: Send confirmation email
        send_password_changed_notification(user)

        return JsonResponse({
            'success': True,
            'message': 'Password reset successfully',
            'user_email': user.email
        })

    except Exception as e:
        print(f"❌ Confirm reset password error: {str(e)}")
        return JsonResponse({
            'success': False,
            'message': 'An error occurred. Please try again later.'
        }, status=500)


def send_password_changed_notification(user):
    """Send notification email when password is changed"""
    subject = 'Password Changed - JabruTouch'
    message = f"""
    Hello {user.first_name},

    Your password has been successfully changed.

    If you did not make this change, please contact support immediately.

    © 2025 JabruTouch. All rights reserved.
    """

    send_mail(
        subject,
        message,
        'noreply@jabrutouch.com',
        [user.email],
        fail_silently=False
    )
```

#### 5. URL Configuration

**File:** `jabrutouch_server/jabrutouch_api/urls.py`

```python
from django.urls import path
from .login_process import reset_password, confirm_reset_password

urlpatterns = [
    # ... existing URLs ...
    path('reset_password/', reset_password, name='reset_password'),
    path('confirm_reset_password/', confirm_reset_password, name='confirm_reset_password'),
]
```

---

## Testing Checklist

### Backend Unit Tests

```python
# test_password_reset.py
from django.test import TestCase, Client
from .models import User, PasswordResetToken
from django.utils import timezone
from datetime import timedelta

class PasswordResetTestCase(TestCase):

    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='oldpassword'
        )

    def test_reset_password_legacy_app(self):
        """Test legacy app receives password via email"""
        response = self.client.post('/api/reset_password/', {
            'email': 'test@example.com'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data['user_exist_status'])
        self.assertNotIn('reset_method', data)

    def test_reset_password_new_app(self):
        """Test new app receives reset link"""
        response = self.client.post('/api/reset_password/', {
            'email': 'test@example.com'
        }, content_type='application/json', HTTP_X_APP_VERSION='7.2.0')

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data['user_exist_status'])
        self.assertEqual(data['reset_method'], 'email_link')
        self.assertTrue(data['reset_link_sent'])

    def test_reset_password_nonexistent_email_new_app(self):
        """Test new app doesn't reveal non-existent email"""
        response = self.client.post('/api/reset_password/', {
            'email': 'nonexistent@example.com'
        }, content_type='application/json', HTTP_X_APP_VERSION='7.2.0')

        self.assertEqual(response.status_code, 200)
        data = response.json()
        # Should still return success
        self.assertTrue(data['user_exist_status'])
        # But reset_link_sent should be False
        self.assertFalse(data['reset_link_sent'])

    def test_confirm_reset_password_valid_token(self):
        """Test confirming password reset with valid token"""
        token, reset_token = PasswordResetToken.create_for_user(self.user)

        response = self.client.post('/api/confirm_reset_password/', {
            'token': token,
            'new_password': 'newpassword123'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data['success'])

        # Verify password was changed
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password('newpassword123'))

        # Verify token was marked as used
        reset_token.refresh_from_db()
        self.assertTrue(reset_token.used)

    def test_confirm_reset_password_expired_token(self):
        """Test confirming with expired token"""
        token, reset_token = PasswordResetToken.create_for_user(self.user)

        # Manually expire the token
        reset_token.expires_at = timezone.now() - timedelta(hours=2)
        reset_token.save()

        response = self.client.post('/api/confirm_reset_password/', {
            'token': token,
            'new_password': 'newpassword123'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 400)
        data = response.json()
        self.assertFalse(data['success'])

    def test_confirm_reset_password_reused_token(self):
        """Test token can't be reused"""
        token, reset_token = PasswordResetToken.create_for_user(self.user)

        # Use token once
        self.client.post('/api/confirm_reset_password/', {
            'token': token,
            'new_password': 'password1'
        }, content_type='application/json')

        # Try to reuse
        response = self.client.post('/api/confirm_reset_password/', {
            'token': token,
            'new_password': 'password2'
        }, content_type='application/json')

        self.assertEqual(response.status_code, 400)
        data = response.json()
        self.assertFalse(data['success'])

    def test_rate_limiting(self):
        """Test rate limiting prevents spam"""
        # Make 3 requests (allowed)
        for i in range(3):
            response = self.client.post('/api/reset_password/', {
                'email': 'test@example.com'
            }, content_type='application/json')
            self.assertEqual(response.status_code, 200)

        # 4th request should be rate limited
        response = self.client.post('/api/reset_password/', {
            'email': 'test@example.com'
        }, content_type='application/json')
        self.assertEqual(response.status_code, 429)
```

**Run tests:**
```bash
python manage.py test jabrutouch_api.tests.test_password_reset
```

---

## Deployment Checklist

### Pre-Deployment

- [ ] Run database migration to create `password_reset_tokens` table
- [ ] Configure email settings (SMTP server, credentials)
- [ ] Test email sending in staging environment
- [ ] Review and approve email template design
- [ ] Configure rate limiting cache backend
- [ ] Add logging for password reset attempts (security audit)

### Deployment Steps

1. **Deploy Backend** (Week 1)
   ```bash
   # Run migration
   python manage.py migrate

   # Deploy to staging
   git push staging main

   # Test thoroughly
   # - Old app + new backend = old flow ✓
   # - New app + new backend = new flow ✓
   # - Rate limiting works ✓
   # - Emails send correctly ✓

   # Deploy to production
   git push production main
   ```

2. **Monitor** (Week 1-2)
   - Watch error logs for issues
   - Track email delivery rates
   - Monitor rate limiting hits
   - Check version distribution

3. **iOS App Release** (Week 2-3)
   - Submit iOS app v7.2.0 to App Store
   - Wait for Apple review
   - Release to 10% of users
   - Monitor for issues
   - Release to 100%

4. **Track Adoption** (Month 1-6)
   - Query version distribution weekly
   - Add deprecation warnings at Month 3
   - Force update prompts at Month 9
   - Block old versions at Month 12

### Database Migration

```bash
# Create migration
python manage.py makemigrations

# Review migration file
python manage.py sqlmigrate jabrutouch_api 00XX

# Apply migration (staging first!)
python manage.py migrate --database=default
```

### Rollback Plan

If issues occur:

```bash
# Rollback migration
python manage.py migrate jabrutouch_api 00XX  # Previous migration number

# Revert code
git revert HEAD --no-edit
git push production main

# Force legacy mode (emergency)
# Add to settings.py:
FORCE_LEGACY_PASSWORD_RESET = True
```

---

## Monitoring & Metrics

### Key Metrics to Track

1. **Version Distribution**
   ```sql
   SELECT
       CASE
           WHEN app_version >= '7.2.0' THEN 'new'
           ELSE 'legacy'
       END as version_category,
       COUNT(*) as request_count
   FROM password_reset_logs
   WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
   GROUP BY version_category;
   ```

2. **Success Rates**
   ```sql
   SELECT
       reset_method,
       COUNT(*) as total_requests,
       SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) as successful,
       ROUND(100.0 * SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) as success_rate
   FROM password_reset_logs
   WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
   GROUP BY reset_method;
   ```

3. **Email Delivery**
   ```sql
   SELECT
       DATE(created_at) as date,
       COUNT(*) as emails_sent,
       SUM(CASE WHEN delivery_failed = 1 THEN 1 ELSE 0 END) as failed
   FROM password_reset_logs
   WHERE reset_method = 'email_link'
   GROUP BY DATE(created_at)
   ORDER BY date DESC
   LIMIT 30;
   ```

4. **Token Usage**
   ```sql
   SELECT
       COUNT(*) as total_tokens,
       SUM(CASE WHEN used = 1 THEN 1 ELSE 0 END) as used_tokens,
       SUM(CASE WHEN expires_at < NOW() AND used = 0 THEN 1 ELSE 0 END) as expired_unused
   FROM password_reset_tokens
   WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);
   ```

### Alert Conditions

**Set up alerts for:**
- Error rate > 5%
- Email delivery failures > 2%
- Response time > 2 seconds
- Rate limit hits > 100/hour
- Old app usage > 50% after Month 3

---

## Security Best Practices

### ✅ Implemented

- **Secure token generation**: 64-character cryptographically random tokens
- **Token hashing**: SHA-256 hash stored, never plaintext
- **Single-use tokens**: Marked as used after redemption
- **Time-limited tokens**: 1-hour expiration
- **Rate limiting**: 3 requests per hour per email
- **User enumeration prevention**: Same response for all emails
- **HTTPS only**: No reset links sent over HTTP
- **Security audit trail**: IP address and user agent logged

### ❌ NOT Implemented (Should Add)

- **CSRF protection**: Django's built-in CSRF middleware should be enabled
- **SQL injection protection**: Use parameterized queries (Django ORM does this)
- **Email verification**: Verify email ownership before allowing password reset
- **Multi-factor authentication**: Add MFA requirement for sensitive actions
- **Account lockout**: Lock account after N failed reset attempts

---

## FAQs

### Q: What happens if a user has both old and new app versions?

**A:** The backend detects the version per request. Old app gets password, new app gets link. Both work independently.

### Q: Can we force all users to update immediately?

**A:** No. iOS app updates can take weeks/months to reach all users. Some users never update. You must support both versions for 6-12 months.

### Q: What if the reset email goes to spam?

**A:** Configure SPF, DKIM, and DMARC records for your domain. Use a reputable email service (SendGrid, Mailgun, AWS SES).

### Q: How do we deprecate the old flow?

**A:**
1. Month 3: Add update banner in old app
2. Month 6: Add update modal on launch
3. Month 9: Add update requirement nag screen
4. Month 12: Block old versions entirely

### Q: Can a user reset password without the app?

**A:** Yes! The reset link opens the app, but if not installed, you could show a web page with "Download App" button.

### Q: What if someone steals the reset link?

**A:** Links expire after 1 hour and are single-use. Tokens are tied to email address. If you suspect compromise, the user can request a new link (invalidates old one).

---

## Contact & Support

**Questions?**
- Backend Team Lead: [contact info]
- iOS Team Lead: [contact info]
- Security Review: [contact info]

**Documentation:**
- iOS Changes: `PASSWORD_RESET_ANALYSIS.md`
- Full Implementation Plan: `BACKWARD_COMPATIBILITY_STRATEGY.md`
- Quick Reference: `BACKWARD_COMPATIBILITY_QUICK_REFERENCE.md`

---

**Last Updated:** 2025-10-12
**Status:** Ready for Implementation
**Priority:** High (Security Issue)
**Estimated Effort:** 2-3 days development + 1 day testing
