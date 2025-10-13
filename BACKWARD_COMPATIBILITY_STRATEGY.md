# Backward Compatibility Strategy for Password Reset API Changes

## Date: 2025-10-12

---

## Executive Summary

This document outlines a comprehensive backward compatibility strategy to transition the password reset flow from the old approach (returns password via email) to a new approach (sends reset link via email). The strategy ensures seamless coexistence of old and new app versions during the transition period.

---

## Current State Analysis

### iOS App Configuration
- **Current Version**: 7.1.6 (from `project.pbxproj` MARKETING_VERSION)
- **API Base URL**: Configured via `Info.plist` → `$(API_BASE_URL)` environment variable
- **No Built-in API Versioning**: The app does NOT send version headers or use versioned endpoints
- **App Version Tracking**: App sends version number via URL params (e.g., `?app_version=716`) for version check endpoint only

### Current Password Reset Flow

**iOS App → Backend:**
```
POST {baseUrl}/reset_password/
Body: { "email": "user@example.com" }
Headers: {
  "Content-Type": "application/json",
  "Accept": "application/json"
}
```

**Backend Response:**
```json
{
  "message": "Password sent to email",
  "user_exist_status": true
}
```

**Key Files:**
- iOS: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/Network/HTTPRequestFactory.swift` (lines 73-81)
- iOS: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Network/API Response models/ForgotPasswordResponse.swift`
- Backend: Django server endpoint `/reset_password/` (legacy)
- Backend: Laravel has NO password reset endpoint currently

### API Infrastructure
- **No API Versioning System**: Neither URL-based (`/api/v1/`, `/api/v2/`) nor header-based versioning exists
- **No Version Detection**: Backend doesn't currently detect or parse app version from requests
- **Single Backend Instance**: One backend serves all app versions simultaneously

---

## Key Questions Answered

### 1. Does the API currently use versioning?
**NO**. The API does not use any formal versioning system:
- No URL versioning (`/api/v1/`, `/api/v2/`)
- No header-based versioning (`X-API-Version`, `Accept: application/vnd.api+json;version=2`)
- No request body version fields

**Exception**: One endpoint uses versioning in the URL path:
```swift
// HTTPRequestFactory.swift:215
let link = baseUrl.appendingPathComponent("donation_data/v1").absoluteString
```
This is an ad-hoc versioning pattern, not a system-wide convention.

### 2. How can we detect old vs new app versions in backend?
**Current Capability**: NONE directly, but we have options:

**Option A: User-Agent Header** (NOT currently used)
- iOS app does NOT set custom User-Agent header
- AWS SDK sets it for S3 operations only
- Would require iOS app code changes

**Option B: Custom Header** (RECOMMENDED)
- Add `X-App-Version` header to all requests
- Example: `X-App-Version: 7.1.6`
- Requires minimal iOS app changes (modify `HTTPRequestFactory`)

**Option C: Request Body Version Field**
- Add `app_version` field to request body
- Example: `{ "email": "...", "app_version": "7.1.6" }`
- Requires changes to both iOS and backend

**Option D: URL Query Parameter**
- Add version to URL: `/reset_password/?app_version=7.1.6`
- Already used for version check endpoint
- Easy to implement

### 3. Should we use URL versioning, header versioning, or request body version field?
**RECOMMENDATION: Hybrid Approach** (combining Options B + D)

**Primary Strategy: Custom Header** (`X-App-Version`)
- Most RESTful approach
- Doesn't pollute URL or body
- Easy to implement in middleware
- Can be used across all endpoints

**Fallback Strategy: URL Query Parameter**
- For backward compatibility
- Already used pattern in the app
- Easy to implement without app changes

### 4. Can we modify ForgotPasswordResponse to include optional new fields?
**YES**, with proper handling:

**Current Model:**
```swift
struct ForgotPasswordResponse: APIResponseModel {
    let message: String
    let status: Bool  // from "user_exist_status"
}
```

**Enhanced Model (Backward Compatible):**
```swift
struct ForgotPasswordResponse: APIResponseModel {
    let message: String
    let status: Bool
    let resetMethod: String?      // NEW: "email_password" or "email_link"
    let resetLinkSent: Bool?      // NEW: true if reset link sent
    let linkExpiresIn: Int?       // NEW: seconds until link expires

    init?(values: [String : Any]) {
        guard let message = values["message"] as? String,
              let status = values["user_exist_status"] as? Bool else {
            return nil
        }

        self.message = message
        self.status = status

        // Optional new fields (won't break old responses)
        self.resetMethod = values["reset_method"] as? String
        self.resetLinkSent = values["reset_link_sent"] as? Bool
        self.linkExpiresIn = values["link_expires_in"] as? Int
    }
}
```

**Backend Response Examples:**

*Old App (v7.1.6 and below):*
```json
{
  "message": "Password sent to your email",
  "user_exist_status": true
}
```

*New App (v7.2.0+):*
```json
{
  "message": "Reset link sent to your email",
  "user_exist_status": true,
  "reset_method": "email_link",
  "reset_link_sent": true,
  "link_expires_in": 3600
}
```

### 5. What's the deployment strategy (backend first or coordinated)?
**RECOMMENDATION: Backend-First, Phased Rollout**

**Phase 1: Backend Changes (Week 1)**
- Deploy version-aware endpoint
- Support both old and new reset flows
- No client changes required yet

**Phase 2: iOS App Update (Week 2-3)**
- Add version header to requests
- Update ForgotPasswordResponse model
- Update UI to handle reset links
- Submit to App Store (review takes 1-3 days)

**Phase 3: Monitor & Adjust (Week 4-8)**
- Monitor old vs new app usage
- Track password reset success rates
- Fix any issues discovered

**Phase 4: Deprecation (Week 12+)**
- Remove old password-via-email logic
- Force update for old app versions

### 6. How long should we maintain backward compatibility?
**RECOMMENDATION: 6-12 months minimum**

**Rationale:**
- iOS users don't always update immediately
- App Store review can take time
- Some users may be on older iOS versions
- Enterprise users may have delayed update cycles

**Timeline:**
```
Month 0: Deploy backward-compatible backend
Month 1: Release iOS app v7.2.0 with new flow
Month 2-3: Monitor adoption rates
Month 6: Show "Please Update" message to old versions
Month 12: Hard cutoff - require app update
```

**Tracking Metrics:**
- % of users on old vs new app versions
- Password reset success rates by version
- Support tickets related to password reset
- User complaints about forced updates

### 7. Should old endpoint stay or should one endpoint handle both?
**RECOMMENDATION: One Endpoint, Version-Aware**

**Single Endpoint Approach:**
```
POST /reset_password/
```

**Advantages:**
- No URL proliferation
- Easier to maintain
- Simpler routing
- Better for gradual migration

**Disadvantages:**
- More complex endpoint logic
- Need to maintain two code paths

**Alternative: Dual Endpoint Approach** (NOT recommended)
```
POST /reset_password/        # Old: email password
POST /api/v2/reset_password/ # New: email link
```

**Why NOT recommended:**
- Creates confusion
- Harder to deprecate old endpoint
- URL versioning requires system-wide changes
- Inconsistent with current API structure

---

## Recommended Versioning Approaches

### Strategy 1: Custom Header Versioning (RECOMMENDED)

**Implementation:**

**iOS Changes:**
```swift
// HTTPRequestFactory.swift (modify createRequest method)
private class func createRequest(_ url:URL, method:HttpRequestMethod, body:[String:Any]?, additionalHeaders:[String:String]?) -> URLRequest {

    let timeoutInterval = 10.0
    let request:NSMutableURLRequest = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutInterval)
    request.httpMethod = method.rawValue

    if body != nil {
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body!, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // NEW: Add app version header to ALL requests
    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
        request.addValue(version, forHTTPHeaderField: "X-App-Version")
    }

    if additionalHeaders != nil {
        for (key,value) in additionalHeaders! {
            request.addValue(value, forHTTPHeaderField: key)
        }
    }

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    return request as URLRequest
}
```

**Laravel Backend - New Middleware:**
```php
<?php
// app/Http/Middleware/AppVersionMiddleware.php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AppVersionMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        // Extract app version from header
        $appVersion = $request->header('X-App-Version');

        // Fallback to query parameter (for backward compatibility)
        if (!$appVersion) {
            $appVersion = $request->query('app_version');
        }

        // Fallback to body parameter
        if (!$appVersion && $request->isJson()) {
            $appVersion = $request->input('app_version');
        }

        // Parse version number (e.g., "7.1.6" -> 70106)
        $versionNumber = $this->parseVersion($appVersion);

        // Attach to request for use in controllers
        $request->attributes->add([
            'app_version' => $appVersion,
            'app_version_number' => $versionNumber,
            'is_legacy_version' => $versionNumber < 70200, // < v7.2.0
        ]);

        return $next($request);
    }

    private function parseVersion(?string $version): int
    {
        if (!$version) {
            return 0; // Unknown/very old version
        }

        // Convert "7.1.6" to 70106 for comparison
        $parts = explode('.', $version);
        $major = (int)($parts[0] ?? 0);
        $minor = (int)($parts[1] ?? 0);
        $patch = (int)($parts[2] ?? 0);

        return ($major * 10000) + ($minor * 100) + $patch;
    }
}
```

**Register Middleware:**
```php
// bootstrap/app.php
->withMiddleware(function (Middleware $middleware) {
    $middleware->append(AppVersionMiddleware::class);
})
```

**Controller Implementation:**
```php
<?php
// app/Http/Controllers/AuthController.php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Notifications\PasswordResetNotification;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AuthController extends Controller
{
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $email = $request->input('email');
        $isLegacyVersion = $request->attributes->get('is_legacy_version', true);

        // Check if user exists
        $user = User::where('email', $email)->first();

        if (!$user) {
            // Always return success to prevent user enumeration
            return response()->json([
                'message' => 'If an account exists with this email, you will receive instructions shortly.',
                'user_exist_status' => true,
            ]);
        }

        if ($isLegacyVersion) {
            // OLD FLOW: Send password via email (security issue, but maintains compatibility)
            return $this->sendPasswordViaEmail($user);
        } else {
            // NEW FLOW: Send reset link
            return $this->sendResetLink($user);
        }
    }

    private function sendPasswordViaEmail($user)
    {
        // Legacy implementation - send actual password
        // TODO: This should be removed after grace period

        // Get password from database (assuming it's stored somewhere)
        // This is a security issue and should be deprecated ASAP

        return response()->json([
            'message' => 'Password sent to your email.',
            'user_exist_status' => true,
        ]);
    }

    private function sendResetLink($user)
    {
        // Generate secure reset token
        $token = Str::random(64);

        // Store token in database with expiration
        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $user->email],
            [
                'token' => hash('sha256', $token),
                'created_at' => Carbon::now(),
            ]
        );

        // Send email with reset link
        $resetUrl = config('app.frontend_url') . '/reset-password?token=' . $token . '&email=' . urlencode($user->email);

        // Send notification email
        $user->notify(new PasswordResetNotification($resetUrl));

        return response()->json([
            'message' => 'Reset link sent to your email.',
            'user_exist_status' => true,
            'reset_method' => 'email_link',
            'reset_link_sent' => true,
            'link_expires_in' => 3600, // 1 hour
        ]);
    }
}
```

**Pros:**
- ✅ Clean separation of concerns
- ✅ Version info available in all controllers
- ✅ Easy to test and debug
- ✅ Follows REST best practices
- ✅ No URL pollution

**Cons:**
- ⚠️ Requires iOS app update to add header
- ⚠️ Old versions won't send header (need fallback)

---

### Strategy 2: URL Query Parameter (FALLBACK)

**Implementation:**

**iOS Changes:**
```swift
// HTTPRequestFactory.swift (modify forgotPasswordRequest)
class func forgotPasswordRequest(email: String?) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    if email == nil { return nil }
    let link = baseUrl.appendingPathComponent("reset_password/").absoluteString
    let body: [String:Any] = ["email": email ?? ""]

    // NEW: Add version to URL query params
    var urlParams: [String: String]?
    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
        urlParams = ["app_version": version]
    }

    guard let url = self.createUrl(fromLink: link, urlParams: urlParams) else { return nil }
    let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
    return request
}
```

**Laravel Backend:**
```php
public function resetPassword(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'app_version' => 'nullable|string',
    ]);

    $appVersion = $request->query('app_version') ?? $request->input('app_version') ?? '0.0.0';
    $versionNumber = $this->parseVersion($appVersion);
    $isLegacyVersion = $versionNumber < 70200;

    // ... rest of implementation same as Strategy 1
}
```

**Pros:**
- ✅ Simple to implement
- ✅ Visible in logs
- ✅ Already used pattern in app
- ✅ Works without middleware

**Cons:**
- ⚠️ Pollutes URL
- ⚠️ Not RESTful
- ⚠️ Version in both query and body is redundant

---

### Strategy 3: Request Body Version Field

**Implementation:**

**iOS Changes:**
```swift
class func forgotPasswordRequest(email: String?) -> URLRequest? {
    guard let baseUrl = URL(string: HttpRequestsFactory.baseUrlLink) else { return nil }
    if email == nil { return nil }
    let link = baseUrl.appendingPathComponent("reset_password/").absoluteString

    // NEW: Add version to body
    var body: [String:Any] = ["email": email ?? ""]
    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
        body["app_version"] = version
    }

    guard let url = self.createUrl(fromLink: link, urlParams: nil) else { return nil }
    let request = self.createRequest(url, method: .post, body: body, additionalHeaders: nil)
    return request
}
```

**Laravel Backend:**
```php
public function resetPassword(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'app_version' => 'nullable|string',
    ]);

    $appVersion = $request->input('app_version', '0.0.0');
    // ... rest of implementation
}
```

**Pros:**
- ✅ Simple to implement
- ✅ Self-contained request

**Cons:**
- ⚠️ Pollutes business data with metadata
- ⚠️ Not RESTful
- ⚠️ Harder to extract in middleware

---

## Comparison Matrix

| Feature | Custom Header | URL Parameter | Request Body |
|---------|---------------|---------------|--------------|
| RESTful | ✅ Best | ❌ Poor | ❌ Poor |
| Middleware Support | ✅ Excellent | ⚠️ Good | ⚠️ Good |
| Backward Compatible | ✅ Yes (fallback) | ✅ Yes | ✅ Yes |
| URL Clean | ✅ Yes | ❌ No | ✅ Yes |
| Easy to Test | ✅ Yes | ✅ Yes | ⚠️ Moderate |
| Visible in Logs | ✅ Yes | ✅ Yes | ⚠️ Depends |
| Industry Standard | ✅ Yes | ❌ No | ❌ No |
| Implementation Effort | ⚠️ Medium | ✅ Low | ✅ Low |

---

## Recommended Implementation Plan

### HYBRID APPROACH: Custom Header + URL Fallback

**Why Hybrid?**
- New apps (v7.2.0+): Use `X-App-Version` header (clean, RESTful)
- Old apps (v7.1.6 and below): Backend infers from behavior (no version info)
- Transition period: Support both methods

**Migration Path:**

**Phase 1: Backend Deployment (Day 1)**
```php
// Detect version from multiple sources
$appVersion = $request->header('X-App-Version')           // New apps
    ?? $request->query('app_version')                    // Fallback 1
    ?? $request->input('app_version')                    // Fallback 2
    ?? null;                                             // Unknown/old

// Treat null version as legacy
$isLegacyVersion = !$appVersion || $this->parseVersion($appVersion) < 70200;
```

**Phase 2: iOS App Update (Week 1-2)**
```swift
// Update HTTPRequestFactory to add header globally
// See "Strategy 1" implementation above
```

**Phase 3: Monitoring (Week 2-8)**
```php
// Log version distribution
Log::info('Password reset request', [
    'version' => $appVersion,
    'method' => $isLegacyVersion ? 'email_password' : 'email_link',
    'email_domain' => substr(strrchr($email, "@"), 1),
]);
```

**Phase 4: Gradual Cutoff (Month 3-6)**
```php
// Show warning to old versions
if ($isLegacyVersion) {
    return response()->json([
        'message' => 'Password sent. Please update your app for better security.',
        'user_exist_status' => true,
        'warning' => 'Your app version is outdated. Please update.',
        'update_required' => false, // Will become true later
    ]);
}
```

**Phase 5: Hard Cutoff (Month 12)**
```php
// Reject old versions
if ($isLegacyVersion) {
    return response()->json([
        'success' => false,
        'errors' => [[
            'field' => 'app_version',
            'message' => 'This app version is no longer supported. Please update to continue.'
        ]]
    ], 426); // 426 Upgrade Required
}
```

---

## Request/Response Examples

### Scenario 1: Old App (v7.1.6) - No Version Sent

**Request:**
```http
POST /reset_password/ HTTP/1.1
Host: api.jabrutouch.com
Content-Type: application/json
Accept: application/json

{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "message": "Password sent to your email",
  "user_exist_status": true
}
```

**Backend Behavior:**
- Detects no version header/parameter
- Assumes legacy version
- Sends password via email (old insecure method)
- Returns simple response

---

### Scenario 2: New App (v7.2.0) - Header Version

**Request:**
```http
POST /reset_password/ HTTP/1.1
Host: api.jabrutouch.com
Content-Type: application/json
Accept: application/json
X-App-Version: 7.2.0

{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "message": "Reset link sent to your email",
  "user_exist_status": true,
  "reset_method": "email_link",
  "reset_link_sent": true,
  "link_expires_in": 3600
}
```

**Backend Behavior:**
- Detects version 7.2.0 from header
- Generates secure reset token
- Sends email with reset link
- Returns enhanced response

---

### Scenario 3: Transition Period - URL Parameter

**Request:**
```http
POST /reset_password/?app_version=7.2.0 HTTP/1.1
Host: api.jabrutouch.com
Content-Type: application/json
Accept: application/json

{
  "email": "user@example.com"
}
```

**Response:** (Same as Scenario 2)

---

### Scenario 4: Old App During Deprecation

**Request:** (Same as Scenario 1)

**Response:**
```json
{
  "message": "Password sent to your email. Please update your app.",
  "user_exist_status": true,
  "warning": "Your app version is outdated. Update required by 2025-12-01.",
  "update_required": true,
  "min_version": "7.2.0",
  "update_url": "https://apps.apple.com/app/jabrutouch/id123456789"
}
```

---

### Scenario 5: Post-Cutoff - Old App Blocked

**Request:** (Same as Scenario 1)

**Response:**
```json
{
  "success": false,
  "errors": [
    {
      "field": "app_version",
      "message": "This app version is no longer supported. Please update to v7.2.0 or higher."
    }
  ],
  "update_required": true,
  "min_version": "7.2.0",
  "update_url": "https://apps.apple.com/app/jabrutouch/id123456789"
}
```

**HTTP Status:** 426 Upgrade Required

---

## Deployment Sequence

### Step 1: Backend Preparation (Day 0-3)

**Tasks:**
1. Create `AppVersionMiddleware` middleware
2. Create `AuthController::resetPassword()` method
3. Create password reset token migration
4. Create `PasswordResetNotification` email template
5. Add configuration for frontend reset URL
6. Write unit tests for version detection
7. Write integration tests for both flows

**Verification:**
```bash
# Test legacy flow (no version)
curl -X POST http://localhost:8000/reset_password/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# Test new flow (with version header)
curl -X POST http://localhost:8000/reset_password/ \
  -H "Content-Type: application/json" \
  -H "X-App-Version: 7.2.0" \
  -d '{"email":"test@example.com"}'
```

---

### Step 2: Backend Deployment (Day 3-4)

**Deployment Checklist:**
- [ ] Merge feature branch to main
- [ ] Run database migrations
- [ ] Deploy to staging environment
- [ ] Run smoke tests on staging
- [ ] Deploy to production
- [ ] Monitor logs for errors
- [ ] Verify both flows work

**Rollback Plan:**
```bash
# If issues detected, rollback deployment
git revert HEAD
php artisan migrate:rollback --step=1
```

---

### Step 3: iOS App Development (Week 1-2)

**Tasks:**
1. Modify `HTTPRequestFactory.createRequest()` to add `X-App-Version` header
2. Update `ForgotPasswordResponse` model with optional new fields
3. Update `ForgotPasswordViewController` to display reset link instructions
4. Add unit tests for version header addition
5. Add UI tests for password reset flow
6. Test with both old and new backend responses

**Code Changes Summary:**
- `HTTPRequestFactory.swift`: ~5 lines added
- `ForgotPasswordResponse.swift`: ~10 lines added
- `ForgotPasswordViewController.swift`: ~20 lines modified
- Total: ~35 lines of code

---

### Step 4: iOS App Testing (Week 2-3)

**Test Cases:**
- [ ] Password reset with email that exists (v7.2.0)
- [ ] Password reset with email that doesn't exist (v7.2.0)
- [ ] Password reset with old backend (backward compatibility)
- [ ] Network error handling
- [ ] Invalid email format
- [ ] Rate limiting behavior
- [ ] UI displays correct messages

**Beta Testing:**
1. Deploy to TestFlight (internal)
2. Test with 5-10 internal users
3. Fix any reported issues
4. Deploy to TestFlight (external beta)
5. Collect feedback from 50-100 beta testers

---

### Step 5: App Store Submission (Week 3)

**Submission Checklist:**
- [ ] Increment version to 7.2.0
- [ ] Update release notes
- [ ] Update screenshots (if UI changed)
- [ ] Submit for review
- [ ] Wait for approval (1-3 days typically)
- [ ] Release to production (phased rollout)

**Release Notes Example:**
```
Version 7.2.0

What's New:
• Improved password reset security - you'll now receive a secure reset link instead of your password via email
• Bug fixes and performance improvements

Security Enhancements:
• Enhanced password reset flow for better account protection
```

---

### Step 6: Monitoring & Support (Week 4-8)

**Metrics to Track:**
```sql
-- Version distribution
SELECT
    app_version,
    COUNT(*) as request_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentage
FROM password_reset_logs
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY app_version
ORDER BY request_count DESC;

-- Success rates by version
SELECT
    CASE
        WHEN app_version IS NULL THEN 'legacy'
        WHEN app_version < '7.2.0' THEN 'old'
        ELSE 'new'
    END as version_group,
    COUNT(*) as total_requests,
    SUM(CASE WHEN success = true THEN 1 ELSE 0 END) as successful,
    AVG(CASE WHEN success = true THEN 1 ELSE 0 END) * 100 as success_rate
FROM password_reset_logs
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY version_group;
```

**Support Documentation:**
- Update help docs with new reset flow
- Train support team on differences
- Create FAQ for common questions
- Monitor support tickets

---

### Step 7: Deprecation Planning (Week 12)

**Gradual Deprecation:**

**Month 3:**
- Add warning message to old app versions
- Include update URL in response

**Month 6:**
- Show "Update Required" alert on app launch
- Allow one more use before forcing update

**Month 12:**
- Hard cutoff - return 426 status for old versions
- Remove old password-via-email code
- Clean up version detection code

---

## Testing Strategy

### Unit Tests

**Backend Tests:**
```php
// tests/Unit/AppVersionMiddlewareTest.php
public function test_extracts_version_from_header()
{
    $request = Request::create('/test', 'GET');
    $request->headers->set('X-App-Version', '7.2.0');

    $middleware = new AppVersionMiddleware();
    $middleware->handle($request, function($req) {
        $this->assertEquals('7.2.0', $req->attributes->get('app_version'));
        $this->assertEquals(70200, $req->attributes->get('app_version_number'));
        $this->assertFalse($req->attributes->get('is_legacy_version'));
    });
}

public function test_treats_no_version_as_legacy()
{
    $request = Request::create('/test', 'GET');

    $middleware = new AppVersionMiddleware();
    $middleware->handle($request, function($req) {
        $this->assertNull($req->attributes->get('app_version'));
        $this->assertTrue($req->attributes->get('is_legacy_version'));
    });
}

public function test_password_reset_sends_link_for_new_version()
{
    // Mock user
    $user = User::factory()->create(['email' => 'test@example.com']);

    // Mock request with new version
    $response = $this->postJson('/reset_password/', [
        'email' => 'test@example.com'
    ], [
        'X-App-Version' => '7.2.0'
    ]);

    $response->assertStatus(200)
        ->assertJson([
            'user_exist_status' => true,
            'reset_method' => 'email_link',
            'reset_link_sent' => true,
        ]);

    // Verify token was created
    $this->assertDatabaseHas('password_reset_tokens', [
        'email' => 'test@example.com'
    ]);
}
```

**iOS Tests:**
```swift
// JabroutouchTests/HTTPRequestFactoryTests.swift
func testForgotPasswordRequestIncludesVersionHeader() {
    let request = HttpRequestsFactory.forgotPasswordRequest(email: "test@example.com")

    XCTAssertNotNil(request)
    XCTAssertEqual(request?.value(forHTTPHeaderField: "X-App-Version"), "7.1.6")
}

func testForgotPasswordResponseParsesNewFields() {
    let json: [String: Any] = [
        "message": "Reset link sent",
        "user_exist_status": true,
        "reset_method": "email_link",
        "reset_link_sent": true,
        "link_expires_in": 3600
    ]

    let response = ForgotPasswordResponse(values: json)

    XCTAssertNotNil(response)
    XCTAssertEqual(response?.message, "Reset link sent")
    XCTAssertTrue(response?.status ?? false)
    XCTAssertEqual(response?.resetMethod, "email_link")
    XCTAssertTrue(response?.resetLinkSent ?? false)
    XCTAssertEqual(response?.linkExpiresIn, 3600)
}

func testForgotPasswordResponseBackwardCompatible() {
    // Old response format
    let json: [String: Any] = [
        "message": "Password sent",
        "user_exist_status": true
    ]

    let response = ForgotPasswordResponse(values: json)

    XCTAssertNotNil(response)
    XCTAssertEqual(response?.message, "Password sent")
    XCTAssertTrue(response?.status ?? false)
    XCTAssertNil(response?.resetMethod)
    XCTAssertNil(response?.resetLinkSent)
}
```

---

### Integration Tests

**Full Flow Test:**
```php
public function test_complete_password_reset_flow_for_new_version()
{
    // 1. Request reset
    $user = User::factory()->create(['email' => 'test@example.com']);

    $response = $this->postJson('/reset_password/', [
        'email' => 'test@example.com'
    ], [
        'X-App-Version' => '7.2.0'
    ]);

    $response->assertStatus(200);

    // 2. Verify email sent
    Notification::assertSentTo($user, PasswordResetNotification::class);

    // 3. Verify token created
    $token = DB::table('password_reset_tokens')
        ->where('email', 'test@example.com')
        ->first();

    $this->assertNotNull($token);

    // 4. Test reset with token
    $response = $this->postJson('/reset_password/confirm', [
        'email' => 'test@example.com',
        'token' => $token->token,
        'password' => 'NewPassword123!',
        'password_confirmation' => 'NewPassword123!',
    ]);

    $response->assertStatus(200);

    // 5. Verify password changed
    $user->refresh();
    $this->assertTrue(Hash::check('NewPassword123!', $user->password));
}
```

---

### Manual Testing Checklist

**Pre-Deployment:**
- [ ] Test old app (v7.1.6) against new backend
- [ ] Test new app (v7.2.0) against old backend (if still running)
- [ ] Test new app against new backend
- [ ] Test with non-existent email
- [ ] Test with multiple rapid requests (rate limiting)
- [ ] Test network failures and timeouts
- [ ] Test with special characters in email

**Post-Deployment:**
- [ ] Monitor error logs for 1 hour
- [ ] Test from production iOS app
- [ ] Verify emails are being sent
- [ ] Check database for token creation
- [ ] Verify metrics are being collected

---

## Rollback Strategy

### If Issues Occur During Backend Deployment

**Immediate Actions:**
```bash
# 1. Rollback git commit
git revert HEAD --no-edit

# 2. Rollback database migration
php artisan migrate:rollback --step=1

# 3. Redeploy previous version
php artisan deploy:rollback

# 4. Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

**Communication:**
- Post status update: "Password reset temporarily unavailable"
- Estimate time to fix
- Provide workaround (contact support)

---

### If Issues Occur After iOS App Release

**Scenario 1: Minor Bug**
- Release hotfix version (v7.2.1)
- Expedited review request to Apple
- Expected timeline: 1-2 days

**Scenario 2: Critical Bug**
- Pull app from App Store (if possible)
- Release emergency hotfix
- Communicate via push notification
- Option: Backend can force old flow for v7.2.0 temporarily

**Backend Emergency Switch:**
```php
// Add to .env
FORCE_LEGACY_PASSWORD_RESET=true

// In controller
if (config('app.force_legacy_password_reset')) {
    return $this->sendPasswordViaEmail($user);
}
```

---

## Deprecation Timeline

### Recommended Timeline

| Date | Action | Details |
|------|--------|---------|
| **Week 0** | Backend deployment | Deploy version-aware endpoint |
| **Week 1-2** | iOS development | Add version header |
| **Week 3** | App Store submission | Submit v7.2.0 |
| **Week 4** | Public release | Phased rollout (10% → 50% → 100%) |
| **Month 2** | Monitor adoption | Track version distribution |
| **Month 3** | Add update warning | Soft reminder to update |
| **Month 6** | Update encouraged | Show "Update Recommended" |
| **Month 9** | Update strongly recommended | Show update modal on launch |
| **Month 12** | Hard cutoff | Block old versions |

### Version Support Matrix

| App Version | Month 0-3 | Month 3-6 | Month 6-9 | Month 9-12 | Month 12+ |
|-------------|-----------|-----------|-----------|------------|-----------|
| < 7.2.0 | ✅ Full support | ✅ + Warning | ⚠️ Nag screen | ⚠️ Force update | ❌ Blocked |
| >= 7.2.0 | ✅ Full support | ✅ Full support | ✅ Full support | ✅ Full support | ✅ Full support |

---

## Monitoring & Metrics

### Key Metrics to Track

**Version Distribution:**
```sql
CREATE TABLE password_reset_logs (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255),
    app_version VARCHAR(20),
    reset_method VARCHAR(50), -- 'email_password' or 'email_link'
    success BOOLEAN,
    error_message TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Query version distribution
SELECT
    COALESCE(app_version, 'unknown') as version,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM password_reset_logs
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY app_version
ORDER BY count DESC;
```

**Success Rates:**
```sql
SELECT
    reset_method,
    COUNT(*) as total,
    SUM(CASE WHEN success THEN 1 ELSE 0 END) as successful,
    ROUND(AVG(CASE WHEN success THEN 1 ELSE 0 END) * 100, 2) as success_rate
FROM password_reset_logs
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY reset_method;
```

**Daily Trends:**
```sql
SELECT
    DATE(created_at) as date,
    reset_method,
    COUNT(*) as count
FROM password_reset_logs
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at), reset_method
ORDER BY date DESC, reset_method;
```

---

### Alerting Rules

**Set up alerts for:**
1. **Error Rate > 5%**: Alert if password reset success rate drops below 95%
2. **Old Version Usage > 50%**: Alert if majority still on old version after Month 3
3. **Email Delivery Failures**: Alert if email bounce rate > 2%
4. **Performance Degradation**: Alert if response time > 2 seconds
5. **Security Issues**: Alert on unusual patterns (rapid requests from same IP)

**Example Alert Configuration (Laravel):**
```php
// app/Listeners/PasswordResetFailedListener.php
public function handle(PasswordResetFailed $event)
{
    // Calculate failure rate
    $recentAttempts = PasswordResetLog::where('created_at', '>', now()->subHour())->count();
    $recentFailures = PasswordResetLog::where('created_at', '>', now()->subHour())
        ->where('success', false)
        ->count();

    $failureRate = $recentAttempts > 0 ? ($recentFailures / $recentAttempts) : 0;

    // Alert if failure rate exceeds threshold
    if ($failureRate > 0.05) { // 5%
        Notification::route('slack', config('services.slack.alert_webhook'))
            ->notify(new HighPasswordResetFailureRate($failureRate, $recentAttempts));
    }
}
```

---

## Security Considerations

### Password Reset Token Security

**Requirements:**
- Tokens must be cryptographically secure (use `Str::random(64)`)
- Tokens must be hashed before storage (use `hash('sha256', $token)`)
- Tokens must expire after 1 hour
- Tokens must be single-use only
- Rate limiting: Max 3 requests per email per hour

**Implementation:**
```php
// Generate token
$token = Str::random(64);
$hashedToken = hash('sha256', $token);

// Store in database
DB::table('password_reset_tokens')->updateOrInsert(
    ['email' => $email],
    [
        'token' => $hashedToken,
        'created_at' => now(),
        'used' => false,
    ]
);

// Validate token
$resetRecord = DB::table('password_reset_tokens')
    ->where('email', $email)
    ->where('token', hash('sha256', $token))
    ->where('used', false)
    ->where('created_at', '>', now()->subHour())
    ->first();

if (!$resetRecord) {
    return response()->json(['error' => 'Invalid or expired token'], 400);
}

// Mark as used
DB::table('password_reset_tokens')
    ->where('email', $email)
    ->update(['used' => true]);
```

---

### Rate Limiting

**Prevent Abuse:**
```php
// app/Http/Controllers/AuthController.php
use Illuminate\Support\Facades\RateLimiter;

public function resetPassword(Request $request)
{
    $email = $request->input('email');
    $key = 'password-reset:' . $email;

    // Check rate limit (3 requests per hour per email)
    if (RateLimiter::tooManyAttempts($key, 3)) {
        $seconds = RateLimiter::availableIn($key);

        return response()->json([
            'success' => false,
            'errors' => [[
                'field' => 'email',
                'message' => "Too many password reset requests. Please try again in " . ceil($seconds / 60) . " minutes."
            ]]
        ], 429);
    }

    // Increment attempt counter
    RateLimiter::hit($key, 3600); // 1 hour decay

    // ... rest of logic
}
```

---

### User Enumeration Prevention

**Best Practice:**
Always return the same success message, regardless of whether the email exists.

**Implementation:**
```php
// ✅ GOOD: Same response for all emails
return response()->json([
    'message' => 'If an account exists with this email, you will receive instructions shortly.',
    'user_exist_status' => true, // Always true
]);

// ❌ BAD: Different response reveals user existence
if ($user) {
    return response()->json(['message' => 'Email sent', 'user_exist_status' => true]);
} else {
    return response()->json(['message' => 'User not found', 'user_exist_status' => false]);
}
```

**Note**: The current iOS app expects `user_exist_status`, so we continue returning it but always set to `true` for security.

---

## Documentation Requirements

### Developer Documentation

**Update the following docs:**

1. **API Documentation** (`/docs/api/authentication.md`):
   - Add `/reset_password/` endpoint specification
   - Document version header requirement
   - Document request/response formats
   - Include example calls

2. **Architecture Documentation** (`ARCHITECTURE_ANALYSIS.md`):
   - Document version detection strategy
   - Document migration timeline
   - Document backward compatibility approach

3. **Deployment Guide** (`DEPLOYMENT.md`):
   - Add password reset deployment steps
   - Add rollback procedures
   - Add monitoring setup

---

### User Documentation

**Update help articles:**

1. **"How to Reset Your Password"**:
   - Update screenshots
   - Explain new email link process
   - Add troubleshooting section

2. **"Didn't Receive Reset Email?"**:
   - Check spam folder
   - Verify email address
   - Check email delivery issues
   - Contact support

3. **"Update Required"** (for forced updates):
   - Why update is needed
   - How to update
   - What's new in latest version

---

### Support Team Training

**Training Materials:**

**Topic 1: New Password Reset Flow**
- How the new flow works
- Differences from old flow
- Common user questions
- How to troubleshoot

**Topic 2: Version Compatibility**
- Which versions use which flow
- How to identify user's version
- When to tell users to update

**Topic 3: Common Issues**
- Email not received (check spam)
- Link expired (request new one)
- Link doesn't work (browser issues)
- Old app version (need to update)

---

## Conclusion & Recommendations

### Final Recommendation: HYBRID APPROACH

**Primary Strategy:** Custom Header (`X-App-Version`)
- Implement `AppVersionMiddleware` to detect version
- Add header in iOS app's `HTTPRequestFactory`
- Fall back to "unknown" if no version provided

**Why This Approach:**
1. ✅ **RESTful & Clean**: Follows HTTP standards
2. ✅ **Future-Proof**: Can be used for all API changes
3. ✅ **Backward Compatible**: Old apps continue working
4. ✅ **Easy to Deprecate**: Clear version detection
5. ✅ **Industry Standard**: Used by major APIs (Stripe, GitHub, etc.)

---

### Implementation Priorities

**MUST DO (Critical):**
1. Deploy backend with version detection
2. Test backward compatibility thoroughly
3. Add comprehensive logging
4. Update iOS app to send version header
5. Submit iOS app to App Store

**SHOULD DO (Important):**
1. Add rate limiting
2. Fix user enumeration vulnerability
3. Add monitoring dashboard
4. Create support documentation
5. Set up alerting

**NICE TO HAVE (Optional):**
1. A/B testing different deprecation messages
2. Analytics on adoption rates
3. Automated rollback triggers
4. Performance benchmarking

---

### Timeline Summary

- **Week 0**: Backend development & testing
- **Week 1**: Backend deployment & monitoring
- **Week 2-3**: iOS development & testing
- **Week 4**: App Store submission & release
- **Month 2-3**: Monitor adoption
- **Month 6**: Encourage updates
- **Month 12**: Deprecate old versions

**Total Time to Full Migration**: 12 months

---

### Success Criteria

**Phase 1 Success (Month 1):**
- ✅ Backend deployed with no downtime
- ✅ Old app versions still work
- ✅ New app version approved by Apple
- ✅ < 0.1% error rate

**Phase 2 Success (Month 3):**
- ✅ > 50% of users on new version
- ✅ New flow success rate > 95%
- ✅ < 5 support tickets per week
- ✅ No critical security issues

**Phase 3 Success (Month 12):**
- ✅ > 95% of users on new version
- ✅ Old flow code removed
- ✅ User enumeration vulnerability fixed
- ✅ Password reset security improved

---

### Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Backend deployment breaks old apps | Low | High | Extensive testing, gradual rollout, immediate rollback plan |
| New app rejected by Apple | Medium | Medium | Follow App Store guidelines, prepare appeal |
| Users don't update | High | Low | Gradual deprecation, clear messaging, forced update after 12mo |
| Email deliverability issues | Medium | High | Use reputable email service, SPF/DKIM/DMARC setup, monitor bounces |
| Security vulnerability | Low | High | Security review, penetration testing, bug bounty |

---

## Appendix

### A. Version Comparison Table

| Version | Release Date | Password Reset Method | Status |
|---------|--------------|----------------------|--------|
| < 7.0.0 | Legacy | Email password | Unsupported |
| 7.0.0 - 7.1.6 | Current | Email password | Supported (deprecated) |
| 7.2.0+ | New | Email reset link | Supported (recommended) |

---

### B. API Endpoint Specification

**Endpoint:** `POST /reset_password/`

**Headers:**
```
Content-Type: application/json
Accept: application/json
X-App-Version: 7.2.0 (optional)
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (Old Flow):**
```json
{
  "message": "Password sent to your email",
  "user_exist_status": true
}
```

**Response (New Flow):**
```json
{
  "message": "Reset link sent to your email",
  "user_exist_status": true,
  "reset_method": "email_link",
  "reset_link_sent": true,
  "link_expires_in": 3600
}
```

**Error Response:**
```json
{
  "success": false,
  "errors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

---

### C. Database Schema

**Migration: create_password_reset_tokens_table**
```php
Schema::create('password_reset_tokens', function (Blueprint $table) {
    $table->string('email')->index();
    $table->string('token');
    $table->boolean('used')->default(false);
    $table->timestamp('created_at')->nullable();

    $table->primary('email');
});
```

**Migration: create_password_reset_logs_table**
```php
Schema::create('password_reset_logs', function (Blueprint $table) {
    $table->id();
    $table->string('email')->index();
    $table->string('app_version')->nullable();
    $table->string('reset_method'); // 'email_password' or 'email_link'
    $table->boolean('success')->default(false);
    $table->text('error_message')->nullable();
    $table->ipAddress('ip_address')->nullable();
    $table->text('user_agent')->nullable();
    $table->timestamps();

    $table->index(['created_at', 'reset_method']);
});
```

---

### D. Environment Variables

**Add to `.env`:**
```bash
# Password Reset Configuration
PASSWORD_RESET_TOKEN_EXPIRY=3600           # 1 hour in seconds
PASSWORD_RESET_RATE_LIMIT=3                # Max attempts per hour
PASSWORD_RESET_FRONTEND_URL=https://app.jabrutouch.com
FORCE_LEGACY_PASSWORD_RESET=false          # Emergency switch
PASSWORD_RESET_MIN_SUPPORTED_VERSION=7.2.0 # For forced updates
```

---

### E. Contact & Support

**Technical Questions:**
- Development Team: dev@jabrutouch.com
- Architecture Review: architect@jabrutouch.com

**Production Issues:**
- Support Team: support@jabrutouch.com
- Emergency Hotline: +1-XXX-XXX-XXXX

**Documentation:**
- API Docs: https://docs.jabrutouch.com
- Developer Portal: https://developers.jabrutouch.com

---

**Document Version:** 1.0
**Last Updated:** 2025-10-12
**Author:** Claude Code Analysis
**Review Status:** Pending Technical Review
