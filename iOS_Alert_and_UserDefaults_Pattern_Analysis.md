# iOS Alert and UserDefaults Pattern Analysis

## Overview
This document analyzes the JabruTouch iOS app's user notification and alert system to provide patterns for implementing one-time migration messages and user communication.

---

## 1. Alert Patterns

### 1.1 Basic Alert Implementation

The app uses a centralized `Utils` class for displaying alerts located at:
`/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Utils/Utils.swift`

#### Standard Alert Methods:

```swift
// Simple alert with message only
class func showAlertMessage(_ message:String, viewControler:UIViewController)

// Alert with title and message
class func showAlertMessage(_ message:String, title:String?, viewControler:UIViewController)

// Alert with callback handler
class func showAlertMessage(_ message:String, title:String?, viewControler:UIViewController, handler:@escaping ((_ action:UIAlertAction)->Void))

// Alert with multiple custom actions
class func showAlertMessage(_ message:String, title:String?, viewControler:UIViewController, actions:[UIAlertAction])
```

### 1.2 Alert Implementation Examples

#### Example 1: Simple Error Alert
```swift
// From GemaraLessonsViewController.swift:89
case .failure(let error):
    let title = Strings.error
    let message = error.message
    Utils.showAlertMessage(message, title: title, viewControler: self)
```

#### Example 2: Alert with Handler (Callback)
```swift
// From SurveyViewController.swift:183
Utils.showAlertMessage(Strings.thankYouVeryMuch.uppercased(), title: "", viewControler: self) { _ in
    self.dismiss(animated: true, completion: nil)
}
```

#### Example 3: Confirmation Alert with Multiple Actions
```swift
// From DownloadsViewController.swift:446-505
func cellDeletePressed(_ cell: DownloadsCellController) {
    let alert = UIAlertController(
        title: Strings.pleaseConfirm,
        message: Strings.deleteThisDownload,
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: Strings.yes, style: .default, handler: { action in
        // Delete action logic
        ContentRepository.shared.removeLessonFromDownloaded(...)
        self.setContent()
    }))

    alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel, handler: nil))

    self.present(alert, animated: true, completion: nil)
}
```

---

## 2. UserDefaults Pattern

### 2.1 UserDefaultsProvider Architecture

Location: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/UserDefaultsProvider.swift`

The app uses a **singleton pattern** with a centralized `UserDefaultsProvider` class that:
- Uses an enum for key management (type-safe)
- Provides computed properties for each setting
- Automatically synchronizes changes

#### Key Structure:

```swift
class UserDefaultsProvider {

    // Private enum for keys (prevents typos and provides autocomplete)
    private enum UserDefaultsKeys: String {
        case currentUsername = "CurrentUsername"
        case currentPassword = "CurrentPassword"
        case seenWalkThrough = "SeenWalkThrough"
        case notFirstTime = "notFirstTime"
        case campaignPopUpDetails = "CampaignPopUpDetails"
        // ... more keys
    }

    // Singleton instance
    class var shared: UserDefaultsProvider {
        if self.provider == nil {
            self.provider = UserDefaultsProvider()
        }
        return self.provider!
    }

    // Example computed property
    var seenWalkThrough: Bool {
        get {
            return self.defaults.bool(forKey: UserDefaultsKeys.seenWalkThrough.rawValue)
        }
        set (value) {
            self.defaults.set(value, forKey: UserDefaultsKeys.seenWalkThrough.rawValue)
            self.defaults.synchronize()
        }
    }
}
```

### 2.2 Existing One-Time Event Tracking

#### Walk-Through Flag (First-Time User Experience)
```swift
// Key definition
case seenWalkThrough = "SeenWalkThrough"

// Default value registration (in init)
self.defaults.register(defaults: [
    UserDefaultsKeys.seenWalkThrough.rawValue: false,
    // ... other defaults
])

// Usage in SplashScreenViewController.swift:221
if UserDefaultsProvider.shared.seenWalkThrough == false {
    self.navigateToWalkThrough()
}

// Setting the flag after completion (WalkThroughViewController.swift:54)
UserDefaultsProvider.shared.seenWalkThrough = true
```

#### Not First Time Flag
```swift
// Key definition
case notFirstTime = "notFirstTime"

// Usage in MainViewController.swift:136
UserDefaultsProvider.shared.notFirstTime = true
```

### 2.3 UserDefaults Key Naming Convention

Based on existing keys, the app uses:
- **PascalCase** for key enum values: `seenWalkThrough`, `notFirstTime`, `currentUsername`
- **String values** match enum names or use legacy names: `"SeenWalkThrough"`, `"notFirstTime"`
- **Boolean flags** for one-time events
- **Descriptive names** that indicate purpose

---

## 3. User Messaging Patterns

### 3.1 Localization System

Location: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Resources/Strings.swift`

The app uses a centralized `Strings` class with computed properties that map to localized strings:

```swift
class Strings {
    class var welcomeToJabrutouch: String {
        return NSLocalizedString("welcomeToJabrutouch", comment: "")
    }

    class var error: String {
        return NSLocalizedString("error", comment: "")
    }

    class var ok: String {
        return NSLocalizedString("ok", comment: "")
    }
}
```

Localization files are in:
- English: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Supporting Files/Strings/en.lproj/Localizable.strings`
- Spanish: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Supporting Files/Strings/es.lproj/Localizable.strings`

### 3.2 Version Alert Pattern

The app has an existing pattern for version alerts:

**Controller**: `NewVersionAlertViewController.swift`
**Trigger**: Called from `SplashScreenViewController` → `MainViewController.presentNewVersionAlert()`

This uses a **custom view controller** presented as a modal rather than a simple `UIAlertController`.

---

## 4. Recommended Migration Message Implementation

### 4.1 Pattern for One-Time Migration Alert

Based on the codebase patterns, here's the recommended approach:

#### Step 1: Add UserDefaults Key

Add to `UserDefaultsProvider.swift`:

```swift
// In UserDefaultsKeys enum
private enum UserDefaultsKeys: String {
    // ... existing keys
    case hasSeenDatabaseMigration = "HasSeenDatabaseMigration"
}

// Add computed property
var hasSeenDatabaseMigration: Bool {
    get {
        return self.defaults.bool(forKey: UserDefaultsKeys.hasSeenDatabaseMigration.rawValue)
    }
    set (value) {
        self.defaults.set(value, forKey: UserDefaultsKeys.hasSeenDatabaseMigration.rawValue)
        self.defaults.synchronize()
    }
}
```

#### Step 2: Add Localized Strings

Add to `Strings.swift`:

```swift
class var databaseMigrationTitle: String {
    return NSLocalizedString("databaseMigrationTitle", comment: "")
}

class var databaseMigrationMessage: String {
    return NSLocalizedString("databaseMigrationMessage", comment: "")
}

class var understood: String {
    return NSLocalizedString("understood", comment: "")
}
```

Add to `Localizable.strings` files:

**English (en.lproj/Localizable.strings)**:
```
"databaseMigrationTitle" = "Database Updated";
"databaseMigrationMessage" = "We've upgraded your local database to improve performance and reliability. Your downloaded lessons and progress have been preserved.";
"understood" = "Got It";
```

**Spanish (es.lproj/Localizable.strings)**:
```
"databaseMigrationTitle" = "Base de Datos Actualizada";
"databaseMigrationMessage" = "Hemos actualizado tu base de datos local para mejorar el rendimiento y la confiabilidad. Tus lecciones descargadas y progreso han sido preservados.";
"understood" = "Entendido";
```

#### Step 3: Show Alert in MainViewController

Add method to `MainViewController.swift`:

```swift
func showDatabaseMigrationAlertIfNeeded() {
    // Check if migration alert was already shown
    guard !UserDefaultsProvider.shared.hasSeenDatabaseMigration else {
        return
    }

    // Create alert
    let alert = UIAlertController(
        title: Strings.databaseMigrationTitle,
        message: Strings.databaseMigrationMessage,
        preferredStyle: .alert
    )

    // Add action
    let okAction = UIAlertAction(title: Strings.understood, style: .default) { _ in
        // Mark as seen
        UserDefaultsProvider.shared.hasSeenDatabaseMigration = true
    }
    alert.addAction(okAction)

    // Present on main thread with slight delay to ensure view is ready
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.present(alert, animated: true, completion: nil)
    }
}
```

#### Step 4: Trigger Alert

Call from `viewDidAppear` in `MainViewController.swift`:

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Show migration alert if needed (only once)
    if firstOnScreen {
        showDatabaseMigrationAlertIfNeeded()
        firstOnScreen = false
    }
}
```

---

## 5. Alternative: Using Utils Helper

For simpler implementation using the existing `Utils` class:

```swift
func showDatabaseMigrationAlertIfNeeded() {
    guard !UserDefaultsProvider.shared.hasSeenDatabaseMigration else {
        return
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        Utils.showAlertMessage(
            Strings.databaseMigrationMessage,
            title: Strings.databaseMigrationTitle,
            viewControler: self
        ) { _ in
            UserDefaultsProvider.shared.hasSeenDatabaseMigration = true
        }
    }
}
```

---

## 6. Recommended User Message Content

### 6.1 Technical but User-Friendly

**Title**: "Database Updated" / "Base de Datos Actualizada"

**Message Options**:

**Option 1 (Simple)**:
```
"We've upgraded your local database to improve performance.
Your downloaded lessons and progress are safe."
```

**Option 2 (More Detail)**:
```
"We've updated the app's database structure to improve performance and reliability.
Your downloaded lessons, progress, and preferences have been preserved."
```

**Option 3 (Technical)**:
```
"The app has migrated to an improved database system.
All your data including downloaded lessons, watch history, and user preferences
have been safely transferred to the new format."
```

### 6.2 Spanish Translations

**Opción 1 (Simple)**:
```
"Hemos actualizado tu base de datos local para mejorar el rendimiento.
Tus lecciones descargadas y progreso están seguros."
```

**Opción 2 (Más Detalle)**:
```
"Hemos actualizado la estructura de la base de datos de la aplicación para mejorar
el rendimiento y la confiabilidad. Tus lecciones descargadas, progreso y preferencias
han sido preservados."
```

**Opción 3 (Técnica)**:
```
"La aplicación ha migrado a un sistema de base de datos mejorado.
Todos tus datos, incluyendo lecciones descargadas, historial de visualización y
preferencias de usuario han sido transferidos de forma segura al nuevo formato."
```

---

## 7. Key Considerations

### 7.1 Timing
- Show alert in `viewDidAppear` with a 0.5-second delay to ensure UI is ready
- Use `firstOnScreen` flag to prevent showing on every view appearance
- Check UserDefaults flag BEFORE presenting

### 7.2 Thread Safety
- Always present alerts on main thread using `DispatchQueue.main`
- The app pattern uses `DispatchQueue.main.async` or `asyncAfter`

### 7.3 User Experience
- Keep message concise and reassuring
- Use familiar terminology ("downloaded lessons", "progress")
- Provide single "Got It" or "OK" action (not multiple choices for info alerts)
- Don't block critical functionality

### 7.4 Testing
- Test with clean install (no UserDefaults set)
- Test with existing UserDefaults (flag already set)
- Test language switching between English and Spanish
- Test on both iPhone and iPad orientations

---

## 8. File Locations Summary

| Component | File Path |
|-----------|-----------|
| UserDefaultsProvider | `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/UserDefaultsProvider.swift` |
| Utils (Alert Helper) | `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Utils/Utils.swift` |
| Strings Class | `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Resources/Strings.swift` |
| English Strings | `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Supporting Files/Strings/en.lproj/Localizable.strings` |
| Spanish Strings | `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Supporting Files/Strings/es.lproj/Localizable.strings` |
| MainViewController | `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Main/MainViewController.swift` |

---

## 9. Example Implementation Checklist

- [ ] Add `hasSeenDatabaseMigration` key to `UserDefaultsProvider.swift`
- [ ] Add `databaseMigrationTitle`, `databaseMigrationMessage`, `understood` to `Strings.swift`
- [ ] Add English translations to `en.lproj/Localizable.strings`
- [ ] Add Spanish translations to `es.lproj/Localizable.strings`
- [ ] Add `showDatabaseMigrationAlertIfNeeded()` method to `MainViewController.swift`
- [ ] Call method from `viewDidAppear` with `firstOnScreen` check
- [ ] Test on fresh install
- [ ] Test on upgrade (existing user)
- [ ] Test language switching
- [ ] Verify flag is set after viewing alert
- [ ] Verify alert doesn't show again after dismissal

---

## Document Version
- Created: 2025-10-10
- Analysis of: JabruTouch iOS App (jabrutouch_ios)
- Purpose: Database migration user notification pattern
