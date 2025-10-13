# Backward Compatibility Quick Reference

## TL;DR

**Problem:** Need to change password reset from "email password" to "email reset link" without breaking old app versions.

**Solution:** Custom header versioning with graceful degradation.

**Timeline:** 12 months from backend deploy to full deprecation.

---

## Key Findings

### Current State
- **No API Versioning**: App doesn't send version info to backend
- **Current Version**: iOS app v7.1.6
- **Backend**: Django (legacy) + Laravel (active)
- **Endpoint**: `POST /reset_password/`

### Recommended Approach
**Custom Header Versioning** with fallback support

```
X-App-Version: 7.2.0
```

---

## 3 Proposed Strategies

### Strategy 1: Custom Header (RECOMMENDED ⭐)
**Pros:** RESTful, clean, industry standard
**Cons:** Requires app update
**Implementation Effort:** Medium

### Strategy 2: URL Query Parameter
**Pros:** Simple, already used in app
**Cons:** Pollutes URL, not RESTful
**Implementation Effort:** Low

### Strategy 3: Request Body Field
**Pros:** Self-contained
**Cons:** Mixes metadata with data
**Implementation Effort:** Low

---

## Implementation Checklist

### Phase 1: Backend (Week 1)
- [ ] Create `AppVersionMiddleware`
- [ ] Create `AuthController::resetPassword()`
- [ ] Add password reset token table
- [ ] Deploy to production
- [ ] Test both old and new flows

### Phase 2: iOS App (Week 2-3)
- [ ] Add `X-App-Version` header to all requests
- [ ] Update `ForgotPasswordResponse` model
- [ ] Update UI for reset link flow
- [ ] Test backward compatibility
- [ ] Submit to App Store

### Phase 3: Monitor (Month 1-3)
- [ ] Track version distribution
- [ ] Monitor success rates
- [ ] Fix issues as they arise
- [ ] Support old versions

### Phase 4: Deprecate (Month 6-12)
- [ ] Add update warnings (Month 6)
- [ ] Encourage updates (Month 9)
- [ ] Force updates (Month 12)
- [ ] Remove old code

---

## Code Changes Summary

### iOS Changes
**Files Modified:** 2 files, ~35 lines total

```swift
// 1. HTTPRequestFactory.swift - Add version header
if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
    request.addValue(version, forHTTPHeaderField: "X-App-Version")
}

// 2. ForgotPasswordResponse.swift - Add optional fields
let resetMethod: String?      // NEW
let resetLinkSent: Bool?      // NEW
let linkExpiresIn: Int?       // NEW
```

### Backend Changes
**Files Created:** 3 files, ~300 lines total

1. `app/Http/Middleware/AppVersionMiddleware.php` - Version detection
2. `app/Http/Controllers/AuthController.php` - Reset logic
3. `database/migrations/xxx_create_password_reset_tokens_table.php` - Token storage

---

## Request/Response Examples

### Old App (v7.1.6)
**Request:**
```http
POST /reset_password/
Content-Type: application/json

{"email": "user@example.com"}
```

**Response:**
```json
{
  "message": "Password sent to email",
  "user_exist_status": true
}
```

### New App (v7.2.0)
**Request:**
```http
POST /reset_password/
Content-Type: application/json
X-App-Version: 7.2.0

{"email": "user@example.com"}
```

**Response:**
```json
{
  "message": "Reset link sent to email",
  "user_exist_status": true,
  "reset_method": "email_link",
  "reset_link_sent": true,
  "link_expires_in": 3600
}
```

---

## Deployment Sequence

1. **Day 0**: Deploy backend (supports both flows)
2. **Week 2**: Release iOS v7.2.0 (sends version header)
3. **Month 3**: Add "Update Available" message
4. **Month 6**: Show update prompt
5. **Month 12**: Force update, remove old code

---

## Testing Strategy

### Critical Tests
- [ ] Old app + new backend = ✅ Works (legacy flow)
- [ ] New app + new backend = ✅ Works (new flow)
- [ ] Non-existent email = ✅ Same response (security)
- [ ] Rate limiting = ✅ 3 requests/hour max
- [ ] Token expiry = ✅ 1 hour timeout

---

## Version Support Timeline

| Version | Now-3mo | 3-6mo | 6-9mo | 9-12mo | 12mo+ |
|---------|---------|-------|-------|--------|-------|
| < 7.2.0 | ✅ Full | ✅ +Warning | ⚠️ Nag | ⚠️ Force | ❌ Blocked |
| ≥ 7.2.0 | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |

---

## Rollback Plan

### If Backend Fails
```bash
git revert HEAD --no-edit
php artisan migrate:rollback
php artisan deploy:rollback
```

### If iOS App Fails
- Release hotfix v7.2.1
- Or: Enable `FORCE_LEGACY_PASSWORD_RESET=true` on backend

---

## Monitoring Metrics

### Track These
1. **Version Distribution**: % users on each version
2. **Success Rates**: Reset success by version
3. **Error Rates**: Failed resets by cause
4. **Adoption Speed**: How fast users update

### Alert If
- Error rate > 5%
- Old version usage > 50% after Month 3
- Email delivery failures > 2%
- Response time > 2 seconds

---

## Success Criteria

### Month 1
- ✅ Zero downtime during backend deploy
- ✅ Old apps still work
- ✅ New app approved by Apple
- ✅ Error rate < 0.1%

### Month 3
- ✅ >50% users on new version
- ✅ New flow success rate >95%
- ✅ <5 support tickets/week

### Month 12
- ✅ >95% users on new version
- ✅ Old flow code removed
- ✅ Security vulnerabilities fixed

---

## Key Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Backend breaks old apps | Extensive testing, gradual rollout, instant rollback |
| Users don't update | Gradual deprecation warnings, forced update after 12mo |
| Email deliverability | Use SendGrid/SES, monitor bounces, SPF/DKIM setup |
| Security issues | Penetration testing, rate limiting, token hashing |

---

## Security Improvements

### Current Issues
- ❌ Password sent via email (insecure)
- ❌ User enumeration vulnerability
- ❌ No rate limiting
- ❌ No token expiry

### New Implementation
- ✅ Secure reset link (not password)
- ✅ Same response for all emails
- ✅ Rate limit: 3 requests/hour
- ✅ Tokens expire in 1 hour
- ✅ Tokens are single-use
- ✅ Tokens hashed in database

---

## Quick Decision Tree

**Should I use Custom Header versioning?**
- ✅ YES if you want best practice
- ✅ YES if planning future API changes
- ✅ YES if RESTful design matters
- ⚠️ MAYBE if urgent (URL param is faster)

**Should I maintain backward compatibility?**
- ✅ YES - Always support old versions during transition
- ✅ YES - Give users 12 months to update
- ❌ NO - Don't maintain forever (deprecate after 12mo)

**Should I use one endpoint or two?**
- ✅ ONE endpoint, version-aware
- ❌ NOT two endpoints (creates confusion)

---

## Resources

- **Full Documentation**: `BACKWARD_COMPATIBILITY_STRATEGY.md`
- **Password Reset Analysis**: `PASSWORD_RESET_ANALYSIS.md`
- **Architecture Overview**: `/tashema-back/ARCHITECTURE_ANALYSIS.md`
- **iOS Project**: `/jabrutouch_ios/`
- **Laravel Backend**: `/tashema-back/`

---

## Contact

**Questions?** Review the full `BACKWARD_COMPATIBILITY_STRATEGY.md` document for detailed implementation steps, code examples, and testing procedures.

**Last Updated:** 2025-10-12
