# Password Reset Quick Reference

**Last Updated:** 2025-10-12

---

## Deep Link Format

```
https://jabrutouch.page.link/?type=reset_password&token={TOKEN}&email={EMAIL}
```

**Required:** `type=reset_password`, `token={TOKEN}`
**Optional:** `email={EMAIL}`

---

## API Endpoints

### 1. Request Reset

```
POST /reset_password/
```

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Password reset email sent successfully",
    "user_exist_status": true,
    "reset_method": "email_link",
    "reset_link_sent": true,
    "link_expires_in": 3600
  }
}
```

---

### 2. Confirm Reset

```
POST /confirm_reset_password/
```

**Request:**
```json
{
  "token": "abc123...",
  "new_password": "NewPassword123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "success": true,
    "message": "Password reset successfully",
    "user_email": "user@example.com"
  }
}
```

---

## Headers

All requests include:
```
Content-Type: application/json
Accept: application/json
X-App-Version: {version}
```

---

## Password Validation

- **Minimum Length:** 6 characters
- **Must Match:** Confirmation field
- **Cannot Be Empty**

---

## Response Wrapper

All responses use this structure:
```json
{
  "success": true/false,
  "data": { ... },
  "errors": [
    {"message": "error description"}
  ]
}
```

---

## Key Files

- **Deep Link Handler:** `AppDelegate.swift` (lines 73-96)
- **Reset UI:** `ResetPasswordViewController.swift`
- **API Calls:** `LoginManager.swift` (lines 110-145)
- **HTTP Factory:** `HTTPRequestFactory.swift` (lines 73-90)

---

## Testing

**Happy Path:**
1. POST /reset_password/ → Email sent
2. User clicks link → App opens
3. POST /confirm_reset_password/ → Success
4. User logs in with new password

**Error Cases:**
- Invalid/expired token → 400 error
- Password too short → Client validation
- Mismatched passwords → Client validation
- Email not found → 400 error

---

For complete documentation, see: **IOS_PASSWORD_RESET_BACKEND_REQUIREMENTS.md**
