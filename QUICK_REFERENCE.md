# Password Reset Refactoring - Quick Reference

## TL;DR

**Current:** Django backend sends 4-digit passwords via email (INSECURE)
**Target:** Token-based reset with 1-hour expiration and deep links (SECURE)
**Effort:** 20-28 hours total
**Priority:** HIGH (security vulnerability)

---

## Current State

### Active Backend: Django
- Endpoint: `POST /api/reset_password/`
- File: `/jabrutouch_server/jabrutouch_api/login_process.py:190-210`
- Issues: Sends password via email, weak 4-digit passwords, user enumeration

### Laravel Status
- Has `password_reset_tokens` table ready
- No implementation yet
- Can be used in future migration

---

## New Architecture (V2)

### Flow
```
User enters email → Backend creates secure token → Email sent with deep link
→ User clicks link → App opens → User sets new password → Token validated → Password updated
```

### Endpoints (Django)
```
POST /api/v2/password/forgot          # Request reset
POST /api/v2/password/validate-token  # Check token validity
POST /api/v2/password/reset           # Complete reset
```

### Deep Link
```
jabrutouch://reset?token=<secure_token>
```

---

## Implementation Checklist

### Backend (Django)
- [ ] Add `PasswordResetToken` model to `models.py`
- [ ] Create migration and run `python manage.py migrate`
- [ ] Create `password_reset_v2.py` with 3 endpoints
- [ ] Add V2 serializers to `serializer.py`
- [ ] Update `urls.py` with V2 routes
- [ ] Create HTML email template
- [ ] Add tests in `test_password_reset_v2.py`
- [ ] Deploy to staging and test

### iOS App
- [ ] Add V2 response models to `ForgotPasswordResponse.swift`
- [ ] Add V2 request methods to `HTTPRequestFactory.swift`
- [ ] Add V2 API methods to `API.swift`
- [ ] Add V2 manager methods to `LoginManager.swift`
- [ ] Update `ForgotPasswordViewController.swift` to use V2
- [ ] Create `ResetPasswordViewController.swift`
- [ ] Add deep link handling to `AppDelegate.swift`
- [ ] Add URL scheme to `Info.plist` (if not exists)
- [ ] Add tests and test on devices
- [ ] Submit to App Store

---

## Key Code Snippets

### Token Generation (Backend)
```python
import secrets

def generate_secure_token():
    return secrets.token_urlsafe(32)  # 256 bits
```

### Email Template Location
```
/jabrutouch_server/jabrutouch_api/templates/password_reset_email.html
```

### Deep Link Handling (iOS)
```swift
// AppDelegate.swift
func application(_ app: UIApplication, open url: URL, ...) -> Bool {
    if url.scheme == "jabrutouch" && url.host == "reset" {
        handlePasswordResetLink(url)
        return true
    }
    return false
}
```

---

## Testing Commands

### Backend
```bash
# Run migrations
python manage.py migrate

# Test endpoint
curl -X POST http://localhost:8000/api/v2/password/forgot/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# Run tests
python manage.py test jabrutouch_api.tests.test_password_reset_v2
```

### iOS
```swift
// Run unit tests
Cmd + U in Xcode

// Test deep link
xcrun simctl openurl booted "jabrutouch://reset?token=test123"
```

---

## Files to Modify

### Django (8 files)
1. `models.py` - Add model
2. `serializer.py` - Add serializers
3. `password_reset_v2.py` - NEW: Views
4. `urls.py` - Add routes
5. `admin.py` - Add admin interface
6. `templates/password_reset_email.html` - NEW: Email template
7. `tests/test_password_reset_v2.py` - NEW: Tests
8. Migration file - AUTO-GENERATED

### iOS (9 files)
1. `ForgotPasswordResponse.swift` - Add V2 models
2. `HTTPRequestFactory.swift` - Add V2 requests
3. `API.swift` - Add V2 methods
4. `LoginManager.swift` - Add V2 manager
5. `ForgotPasswordViewController.swift` - Use V2
6. `ResetPasswordViewController.swift` - NEW: Reset UI
7. `AppDelegate.swift` - Deep link handling
8. `Info.plist` - URL scheme
9. `PasswordResetV2Tests.swift` - NEW: Tests

---

## Security Checklist

- [ ] Use `secrets.token_urlsafe()` for tokens
- [ ] Set 1-hour token expiration
- [ ] Enforce single-use tokens
- [ ] Return same message for all emails (no enumeration)
- [ ] Implement rate limiting (3 per hour per email)
- [ ] Use TLS for SMTP
- [ ] Never send passwords via email
- [ ] Send confirmation email after password change
- [ ] Log all reset attempts with IP/user agent
- [ ] Invalidate all tokens after successful reset

---

## Deployment Steps

### Backend
```bash
1. git checkout -b feature/password-reset-v2
2. Make code changes
3. python manage.py makemigrations
4. python manage.py migrate
5. python manage.py test
6. git commit -m "Add password reset V2"
7. Deploy to staging
8. Test with curl/Postman
9. Deploy to production
10. Monitor logs
```

### iOS
```bash
1. Make code changes
2. Run tests (Cmd+U)
3. Test on physical device
4. Update version number
5. Archive and submit to App Store
6. Monitor TestFlight feedback
7. Release to production
8. Monitor crash reports
```

---

## Monitoring

### Metrics to Track
- Number of reset requests per hour
- Token usage rate (% of tokens used)
- Time to reset (token creation → password update)
- Failed reset attempts (expired/invalid tokens)
- V1 vs V2 usage (track migration progress)

### Alerts to Set Up
- Spike in reset requests (>100/hour)
- High token expiration rate (>50%)
- Email delivery failures (>10%)
- V1 endpoint still receiving traffic after sunset date

---

## Timeline

| Week | Task | Owner |
|------|------|-------|
| 1 | Backend implementation & testing | Backend Dev |
| 2 | iOS implementation & testing | iOS Dev |
| 3 | Deploy backend + Submit iOS app | DevOps + iOS Dev |
| 4-8 | Monitor adoption rate | Team |
| Month 2-3 | Add deprecation warnings to V1 | Backend Dev |
| Month 6 | Sunset V1 endpoint | DevOps |

---

## Rollback Plan

**If Backend Issues:**
1. Revert migration: `python manage.py migrate jabrutouch_api <previous>`
2. Disable V2 routes
3. V1 still works as fallback

**If iOS Issues:**
1. Users can still use V1 flow
2. Submit hotfix if critical
3. Expedite App Store review

---

## Contact & Resources

**Documentation:**
- Full Plan: `PASSWORD_RESET_REFACTORING_PLAN.md`
- Summary: `PASSWORD_RESET_SUMMARY.md`
- Original Analysis: `PASSWORD_RESET_ANALYSIS.md`
- This Guide: `QUICK_REFERENCE.md`

**Key Resources:**
- Django Docs: https://docs.djangoproject.com/en/stable/
- Laravel Docs: https://laravel.com/docs/11.x/passwords
- iOS Deep Links: https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content
- OWASP Password Reset: https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html

---

**Last Updated:** 2025-10-12
