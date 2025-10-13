# Password Reset Backend API Analysis - Executive Summary

**Date:** 2025-10-12
**Analysis Type:** Backend API Structure for Password Reset Refactoring

---

## Key Findings

### 1. Which Backend Currently Handles Password Reset?

**Answer: Django Backend (Legacy)**

- **Active Endpoint:** `POST /api/reset_password/`
- **Location:** `/jabrutouch_server/jabrutouch_api/login_process.py` (lines 190-210)
- **iOS Configuration:** Uses `$(API_BASE_URL)` from Info.plist
- **Currently Active:** ✅ YES - iOS app connects to Django backend

### 2. Current Implementation Details

#### Django Backend (ACTIVE)

**Endpoint Structure:**
```
POST /api/reset_password/
Body: { "email": "user@example.com" }

Response:
{
  "user_exist_status": true/false,
  "message": "mail has bin send" OR "User doesn't exist..."
}
```

**Critical Issues:**
```python
# INSECURE: Sends password directly via email
new_password = generate_password()  # Random 4-digit number (1000-9999)
user.set_password(new_password)
send_mail(
    'Tu contraseña',
    f"Hola {user.first_name}, tu nueva contraseña es {new_password}",
    ...
)
```

**Security Vulnerabilities:**
1. ⚠️ **Sends passwords via email** (unencrypted storage)
2. ⚠️ **Weak passwords** (4-digit numeric: 1000-9999)
3. ⚠️ **User enumeration** (returns `user_exist_status: false` for non-existent emails)
4. ⚠️ **No rate limiting**
5. ⚠️ **No token expiration**

#### Laravel Backend (NOT USED FOR PASSWORD RESET)

**Status:** Active development but NO password reset implementation
- Has `password_reset_tokens` table defined in migration
- Laravel 11 built-in password reset infrastructure available
- Uses legacy `jabrutouch_api_user` table (Django naming convention)
- **No routes or controllers** for password reset yet

### 3. Database Schema Analysis

#### Django (Current Active Database)

**Existing Tables:**
- `jabrutouch_api_user` - User table (Django AbstractUser)
- No password reset token table exists

**Email Configuration:**
```python
# settings.py
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_HOST_USER = os.getenv("EMAIL_HOST_USER")
EMAIL_HOST_PASSWORD = os.getenv("EMAIL_HOST_PASSWORD")
```

**Required New Table:**
```python
class PasswordResetToken(BaseTable):
    user = ForeignKey(User)
    token = CharField(max_length=64, unique=True)
    expires_at = DateTimeField()
    used = BooleanField(default=False)
    used_at = DateTimeField(null=True)
    ip_address = GenericIPAddressField(null=True)
    user_agent = TextField(blank=True)
```

#### Laravel (Future Ready)

**Existing Migration:** `0001_01_01_000000_create_users_table.php`
```php
Schema::create('password_reset_tokens', function (Blueprint $table) {
    $table->string('email')->primary();
    $table->string('token');
    $table->timestamp('created_at')->nullable();
});
```

**Ready to Use:** ✅ Table exists, just needs implementation

### 4. API Versioning Strategy

#### Backward Compatibility Plan

**V1 Endpoints (KEEP ACTIVE):**
- `POST /api/reset_password/` - Legacy insecure endpoint
- Keep active for old iOS app versions
- Mark as deprecated

**V2 Endpoints (NEW):**
- `POST /api/v2/password/forgot` - Request reset token
- `POST /api/v2/password/validate-token` - Validate token (optional)
- `POST /api/v2/password/reset` - Reset password with token

**Migration Timeline:**
```
Week 1-2:   Implement V2 backend
Week 3:     Deploy iOS app with V2
Month 2-3:  Deprecate V1 (logs warnings)
Month 6:    Sunset V1 (once 95%+ on V2)
```

### 5. Email Infrastructure

#### Current Setup (Django)

**SMTP Configuration:**
- Host: Gmail SMTP (`smtp.gmail.com`)
- Port: 587 (TLS)
- Credentials: Environment variables

**Current Email Templates:**
- Plain text only
- Spanish language
- Basic formatting

**Recommended Enhancements:**
- HTML email template with branding
- Deep link button for mobile app
- Security warnings
- Expiration notice

### 6. Token Generation Pattern

#### Current (INSECURE)
```python
def generate_password():
    return randint(1000, 9999)  # Only 9,000 possibilities!
```

#### Recommended (SECURE)
```python
import secrets

def generate_secure_token():
    return secrets.token_urlsafe(32)  # 256 bits of entropy
```

### 7. iOS App Integration

#### Current Configuration

**Base URL:** Set via build configuration
```swift
// HTTPRequestFactory.swift
static let baseUrlLink = Bundle.main.object(forInfoDictionaryKey: "APIBaseUrl") as! String
```

**Current Request:**
```swift
class func forgotPasswordRequest(email: String) -> URLRequest? {
    let link = baseUrl.appendingPathComponent("reset_password/").absoluteString
    let body: [String:String] = ["email": email]
    // ... creates POST request
}
```

**Deep Link Support:**
- URL Scheme: `jabrutouch://`
- Reset Link: `jabrutouch://reset?token=xxx`
- Handled in AppDelegate

### 8. Security Best Practices for Implementation

#### Token Security
✅ **Must Do:**
- Use `secrets.token_urlsafe(32)` for 256-bit tokens
- Set 1-hour expiration
- Single-use tokens only
- Store token hash in database (optional extra security)
- Track IP address and user agent

#### User Enumeration Prevention
✅ **Must Do:**
- Always return success for any email
- Same response time for existing/non-existing users
- Generic message: "If account exists, email sent"

#### Rate Limiting
✅ **Must Do:**
- Backend: Max 3 requests per email per hour
- iOS: 60-second cooldown between requests
- Track by IP address and email

#### Email Security
✅ **Must Do:**
- Use TLS/SSL for SMTP
- Never include passwords in email
- Include company branding to prevent phishing
- Send confirmation email after password change

### 9. Database Migration Requirements

#### Django Backend

**Create Migration:**
```bash
cd jabrutouch_server/jabrutouch_server
python manage.py makemigrations jabrutouch_api
python manage.py migrate
```

**New Model:** `PasswordResetToken`
- Adds table: `jabrutouch_api_passwordresettoken`
- Indexes on: `(token, used, expires_at)`

#### Laravel Backend (For Future)

**Already Has Table:** `password_reset_tokens`
- No migration needed if using Laravel's default
- Can enhance with additional fields if needed

### 10. Testing Requirements

#### Backend Tests
```python
# Django Tests
test_forgot_password_existing_user()
test_forgot_password_nonexistent_user()  # Same response
test_validate_valid_token()
test_validate_expired_token()
test_reset_password_with_valid_token()
test_reset_password_twice_with_same_token()  # Should fail
```

#### iOS Tests
```swift
// Swift Tests
testForgotPasswordV2Request()
testResetPasswordV2Request()
testDeepLinkParsing()
testPasswordValidation()
```

#### Manual Testing
- [ ] Email delivery (Gmail, Outlook, iPhone Mail)
- [ ] Deep link handling on iOS
- [ ] Token expiration after 1 hour
- [ ] Token single-use enforcement
- [ ] Rate limiting enforcement

---

## Implementation Priority: HIGH

### Why This is Critical

1. **Security Vulnerability:** Sending passwords via email violates OWASP guidelines
2. **Weak Passwords:** 4-digit numeric passwords are easily brute-forced
3. **User Enumeration:** Allows harvesting of valid email addresses
4. **No Rate Limiting:** Can be abused for spam or DoS attacks

### Estimated Effort

**Backend (Django):** 8-12 hours
- Database model & migration: 2h
- API endpoints: 4h
- Email templates: 2h
- Testing: 2-4h

**iOS App:** 12-16 hours
- API integration: 3h
- UI (ResetPasswordViewController): 4h
- Deep link handling: 3h
- Testing: 2-4h

**Total:** 20-28 hours (2.5-3.5 developer-days)

---

## Recommended Implementation Steps

### Phase 1: Backend (Django) - Week 1
1. ✅ Create `PasswordResetToken` model
2. ✅ Run migrations
3. ✅ Create V2 endpoints (`/api/v2/password/*`)
4. ✅ Create email templates (HTML + plain text)
5. ✅ Add tests
6. ✅ Deploy to staging
7. ✅ Test with curl/Postman

### Phase 2: iOS App - Week 2
1. ✅ Create V2 request models
2. ✅ Update HTTPRequestFactory
3. ✅ Update API layer
4. ✅ Create ResetPasswordViewController
5. ✅ Implement deep link handling
6. ✅ Add password strength indicator
7. ✅ Add tests
8. ✅ Test on physical devices

### Phase 3: Deployment - Week 3
1. ✅ Deploy backend to production
2. ✅ Submit iOS app to App Store
3. ✅ Monitor adoption rate
4. ✅ Track metrics (reset requests, success rate)

### Phase 4: Deprecation - Month 2-6
1. ✅ Add deprecation warnings to V1 endpoint
2. ✅ Email users to update app
3. ✅ Monitor V1 usage decline
4. ✅ Sunset V1 when <5% traffic

---

## Files Requiring Changes

### Django Backend

**New Files:**
- `/jabrutouch_api/password_reset_v2.py` - Views for V2 endpoints
- `/jabrutouch_api/templates/password_reset_email.html` - Email template
- `/jabrutouch_api/tests/test_password_reset_v2.py` - Tests

**Modified Files:**
- `/jabrutouch_api/models.py` - Add PasswordResetToken model
- `/jabrutouch_api/serializer.py` - Add V2 serializers
- `/jabrutouch_server/urls.py` - Add V2 routes
- `/jabrutouch_api/admin.py` - Add admin interface for tokens

### iOS App

**New Files:**
- `/Controller/ResetPassword/ResetPasswordViewController.swift` - UI for password reset
- `/Tests/PasswordResetV2Tests.swift` - Unit tests

**Modified Files:**
- `/App/Models/ForgotPasswordResponse.swift` - Add V2 response models
- `/App/Services/Network/HTTPRequestFactory.swift` - Add V2 request methods
- `/App/Services/Network/API.swift` - Add V2 API methods
- `/App/Manager/LoginManager.swift` - Add V2 manager methods
- `/Controller/ForgotPassword/ForgotPasswordViewController.swift` - Use V2 API
- `/AppDelegate.swift` - Handle deep links
- `/Info.plist` - Add URL scheme (if not exists)

---

## Risk Assessment

### Low Risk
- Backend implementation (straightforward Django)
- Email sending (already configured)
- Database migration (simple schema)

### Medium Risk
- Deep link handling (OS version compatibility)
- Email delivery rate (Gmail spam filters)
- User adoption (need to update app)

### Mitigation
- Test deep links on iOS 12.0+ devices
- Use authenticated SMTP with good domain reputation
- Keep V1 active until 95%+ adoption
- Add in-app prompts to update

---

## Success Metrics

### Security Metrics
- 0% passwords sent via email (should be 100% token-based)
- 0% user enumeration attempts succeed
- 100% tokens single-use
- 100% tokens expire within 1 hour

### Performance Metrics
- <2 seconds email delivery time
- >95% token validation success rate
- <5% token expiration without use
- >90% password reset completion rate

### Adoption Metrics
- Week 1: 20% users on V2
- Month 1: 60% users on V2
- Month 3: 90% users on V2
- Month 6: 95%+ users on V2 (sunset V1)

---

## Questions for Stakeholders

1. **Timeline:** When do we want this deployed to production?
2. **V1 Sunset:** How long should we keep the old endpoint active?
3. **Email Design:** Do we need designer input for HTML email template?
4. **Monitoring:** What monitoring/alerting do we need in place?
5. **User Communication:** Should we notify users about the change?

---

## Next Actions

- [ ] Review this analysis with development team
- [ ] Get approval for implementation timeline
- [ ] Create feature branch: `feature/password-reset-v2`
- [ ] Assign tasks to developers
- [ ] Set up monitoring/alerting
- [ ] Schedule code review sessions
- [ ] Plan deployment window
- [ ] Prepare rollback plan

---

**For detailed implementation guide, see:** `PASSWORD_RESET_REFACTORING_PLAN.md`

**For existing analysis, see:** `PASSWORD_RESET_ANALYSIS.md`
