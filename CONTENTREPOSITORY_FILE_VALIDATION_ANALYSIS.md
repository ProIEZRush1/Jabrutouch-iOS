# ContentRepository File Validation and Cleanup Analysis

## Date: 2025-10-12

## Overview

This document provides a comprehensive analysis of the ContentRepository's file validation and cleanup mechanisms, focusing on orphaned download detection and removal.

---

## 1. File Validation Functions

### 1.1 `removeOldDownloadedFiles()` - Age-Based Cleanup
**Location:** ContentRepository.swift, lines 494-516

**Purpose:** Remove downloaded files that are older than 30 days

**When Called:**
- App startup in `SplashScreenViewController.viewDidLoad()` (line 39)

**How It Works:**
```swift
func removeOldDownloadedFiles() {
    // Iterates through all downloaded Gemara lessons
    for (sederId, masechet) in downloadedGemaraLessons {
        for (masechetId, value) in masechet {
            for lesson in value {
                removedOldFiles(gemara: lesson, mishna: nil,
                               sederId: sederId, masechetId: masechetId, chapter: nil)
            }
        }
    }

    // Iterates through all downloaded Mishna lessons
    for (sederId, masechet) in downloadedMishnaLessons {
        for (masechetId, chapter) in masechet {
            for (chapterId, value) in chapter {
                for lesson in value {
                    removedOldFiles(gemara: nil, mishna: lesson,
                                   sederId: sederId, masechetId: masechetId, chapter: chapterId)
                }
            }
        }
    }
}
```

**File Directory Fix Applied:**
- **Line 528:** Changed from `FileDirectory.cache` to `FileDirectory.documents`
- This was a critical bug fix - the function was checking the wrong directory
- See DOWNLOADS_PERSISTENCE_FIX_COMPLETE.md for details

---

### 1.2 `removedOldFiles()` - Individual File Validation
**Location:** ContentRepository.swift, lines 518-565

**Purpose:** Check if individual lesson files exist and are older than 30 days, then remove them

**How It Works:**
1. Checks three file types for each lesson:
   - Audio: `{lessonId}_aud.mp3`
   - Video: `{lessonId}_vid.mp4`
   - Text/PDF: `{lessonId}_text.pdf`

2. For each file:
   - Checks if file exists in Documents directory
   - Gets file creation date
   - If file is >= 30 days old, removes it
   - Tracks removal status

3. If ALL files (audio + video) are removed:
   - Removes lesson from in-memory registry
   - Calls `updateDownloadedLessonsStorage()` to persist changes

**Key Logic:**
```swift
// Check file age
if Date().timeIntervalSince(creationDate) >= 60*60*24*30 { // 30 days
    // Remove file
    FilesManagementProvider.shared.removeFiles(currentFile) { ... }
}

// If both audio and video removed, clean up registry
if isRemovedAll.allSatisfy({$0}) {
    if mishna != nil && chapter != nil {
        removeMishnaLessonFromArray(mishna!, sederId, masechetId, chapter!)
    } else if gemara != nil {
        removeGemaraLessonFromArray(gemara!, sederId, masechetId)
    }
    updateDownloadedLessonsStorage()
}
```

---

### 1.3 `refreshDownloadsList()` - Manual Orphan Cleanup
**Location:** ContentRepository.swift, lines 1375-1475

**Purpose:** User-triggered cleanup that removes download registry entries for lessons whose files don't exist

**When Called:**
- Manually triggered by user long-pressing the Downloads screen title (2-second hold)
- See DownloadsViewController.swift, lines 82-134

**How It Works:**
1. Scans ALL downloaded lessons (Gemara and Mishna)
2. For each lesson, checks if ANY of its files exist in Documents directory:
   - Audio file
   - Video file
   - PDF file
3. If NO files exist for a lesson:
   - Marks it as orphaned
   - Logs the orphan: `🧹 Found orphaned [Gemara/Mishna] lesson: {id}`
4. Removes all orphaned entries from in-memory registry
5. Saves updated registry to disk

**Key Logic:**
```swift
func refreshDownloadsList() {
    guard let documentsURL = FileDirectory.documents.url else { return }

    var orphanedGemara: [(lesson, sederId, masechetId)] = []
    var orphanedMishna: [(lesson, sederId, masechetId, chapter)] = []

    // Check each lesson's files
    for lesson in lessons {
        var hasAnyFile = false

        if lesson.audioLink != nil {
            if fileManager.fileExists(atPath: documentsURL/.../audioFile) {
                hasAnyFile = true
            }
        }
        // ... check video and text files ...

        if !hasAnyFile {
            orphanedGemara.append((lesson, sederId, masechetId))
        }
    }

    // Remove orphaned entries
    for item in orphanedGemara {
        removeGemaraLessonFromArray(item.lesson, item.sederId, item.masechetId)
    }

    updateDownloadedLessonsStorage()
}
```

---

### 1.4 `reloadDownloadsFromStorage()` - Registry Refresh
**Location:** ContentRepository.swift, lines 1361-1365

**Purpose:** Reload the downloads list from disk into memory

**When Called:**
- App startup in `SplashScreenViewController.viewDidLoad()` (line 38)

**How It Works:**
```swift
func reloadDownloadsFromStorage() {
    print("🔄 Reloading downloads from storage...")
    loadDownloadedLessonsFromStorage()
    print("✅ Downloads reloaded from storage")
}
```

Simply calls the private loading function that:
1. Reads `downloadedLessons.json` from Documents directory
2. Parses JSON into Gemara/Mishna data structures
3. Updates in-memory `downloadedGemaraLessons` and `downloadedMishnaLessons` dictionaries

---

## 2. App Initialization Flow

### 2.1 AppDelegate Initialization
**File:** AppDelegate.swift, line 47

```swift
func application(_ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: ...) -> Bool {
    // Initialize ContentRepository singleton
    _ = ContentRepository.shared  // Line 47

    // Firebase and other setup...
    return true
}
```

**What Happens:**
1. `ContentRepository.shared` triggers the singleton initialization
2. `init()` is called (ContentRepository.swift, lines 101-110)

---

### 2.2 ContentRepository Initialization
**File:** ContentRepository.swift, lines 101-110

```swift
private init() {
    self.loadShas()                                    // Load Torah structure
    self.loadDownloadedLessonsFromStorage()           // Load downloads registry
    self.gemaraLessons = self.loadGemaraLessonsFromStorage()
    self.mishnaLessons = self.loadMishnaLessonsFromStorage()

    let lastWatchedLessons = self.loadLastWatchedLessonsStorage()
    self.lastWatchedGemaraLessons = lastWatchedLessons.gemaraLessons
    self.lastWatchedMishnaLessons = lastWatchedLessons.mishnaLessons
}
```

**Note:** At this point, NO cleanup operations run - only loading data

---

### 2.3 SplashScreen Cleanup Operations
**File:** SplashScreenViewController.swift, lines 32-40

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    self.activityIndicator.isHidden = true

    // ONE-TIME MIGRATION: Move files from Caches to Documents
    ContentRepository.shared.migrateDownloadsFromCachesToDocuments()  // Line 36

    // Reload registry to ensure latest state
    ContentRepository.shared.reloadDownloadsFromStorage()             // Line 38

    // Clean up old files (30+ days)
    ContentRepository.shared.removeOldDownloadedFiles()               // Line 39
}
```

**Execution Order:**
1. **Migration** (if not completed before)
   - Moves registry file from Caches → Documents
   - Moves lesson files from Caches → Documents
   - Cleans up orphaned entries during migration
   - Sets `hasCompletedDownloadsCacheToDocumentsMigration = true`

2. **Reload**
   - Re-reads registry from Documents
   - Updates in-memory state

3. **Age-based Cleanup**
   - Checks each downloaded lesson
   - Removes files older than 30 days
   - Updates registry if files removed

---

## 3. Migration System

### 3.1 `migrateDownloadsFromCachesToDocuments()`
**Location:** ContentRepository.swift, lines 1166-1258

**Purpose:** One-time migration from old Caches storage to persistent Documents storage

**When Called:**
- Once at app startup (SplashScreenViewController.viewDidLoad, line 36)
- Skipped if migration already completed (UserDefaults flag)

**Migration Flow:**

```
1. Check Migration Flag
   └─> If completed: Skip (return early)
   └─> If not completed: Continue

2. Migrate Registry File
   ├─> Check if downloadedLessons.json exists in Caches
   ├─> If exists in Documents: Delete Caches version
   └─> If not in Documents: Move from Caches → Documents

3. Migrate Lesson Files (for each lesson)
   ├─> Check audio file
   │   ├─> If in Documents: Delete Caches duplicate
   │   └─> If in Caches only: Move to Documents
   ├─> Check video file
   │   ├─> If in Documents: Delete Caches duplicate
   │   └─> If in Caches only: Move to Documents
   └─> Check PDF file
       ├─> If in Documents: Delete Caches duplicate
       └─> If in Caches only: Move to Documents

4. Clean Up Orphans
   └─> Remove registry entries with no files in either location

5. Mark Migration Complete
   └─> Set UserDefaults flag: hasCompletedDownloadsCacheToDocumentsMigration = true
```

**Migration Results:**
```swift
private enum MigrationResult {
    case migrated           // Moved from Caches to Documents
    case alreadyInDocuments // File already in Documents, deleted from Caches
    case deleted            // Duplicate found, deleted from Caches
    case orphaned           // No files found in either location
    case error              // Error during migration
}
```

**Console Output:**
```
🔄 Starting downloads migration from Caches to Documents...
📦 Migrated audio: 247_aud.mp3
📦 Migrated video: 247_vid.mp4
🗑️  Deleted duplicate PDF from Caches: 247_text.pdf
🧹 Cleaning up 0 orphaned download entries...
✅ Migration completed:
   📦 Migrated: 2 lessons
   🗑️  Deleted duplicates: 1 lessons
   🧹 Cleaned orphans: 0 entries
```

---

### 3.2 Migration Flag Storage
**File:** UserDefaultsProvider.swift, lines 245-253

```swift
var hasCompletedDownloadsCacheToDocumentsMigration: Bool {
    get {
        return self.defaults.bool(forKey:
            UserDefaultsKeys.downloadsCacheToDocumentsMigration.rawValue)
    }
    set (value) {
        self.defaults.set(value, forKey:
            UserDefaultsKeys.downloadsCacheToDocumentsMigration.rawValue)
        self.defaults.synchronize()
    }
}
```

**Key:** `"DownloadsCacheToDocumentsMigration_v1"`

This ensures migration runs only once per device, even across app updates.

---

## 4. Manual Refresh UI Feature

### 4.1 Hidden Gesture Implementation
**File:** DownloadsViewController.swift, lines 75-134

**Setup (viewDidLoad):**
```swift
fileprivate func setupRefreshGesture() {
    // Long press gesture on Downloads title
    let longPress = UILongPressGestureRecognizer(
        target: self,
        action: #selector(titleLongPressed(_:))
    )
    longPress.minimumPressDuration = 2.0  // 2 seconds
    titleLabel.isUserInteractionEnabled = true
    titleLabel.addGestureRecognizer(longPress)
}
```

**Gesture Handler:**
```swift
@objc func titleLongPressed(_ gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began else { return }

    // Show confirmation alert
    let alert = UIAlertController(
        title: Strings.refreshDownloadsTitle,        // "Refresh Downloads"
        message: Strings.refreshDownloadsMessage,    // Explanation message
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: Strings.refresh, style: .default) { _ in
        // Show progress indicator
        let activityAlert = UIAlertController(
            title: nil,
            message: Strings.refreshingDownloads,  // "Refreshing downloads..."
            preferredStyle: .alert
        )
        // Add spinner...
        self.present(activityAlert, animated: true)

        // Run refresh on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            ContentRepository.shared.refreshDownloadsList()

            DispatchQueue.main.async {
                activityAlert.dismiss(animated: true) {
                    self.setContent(openSections: false)  // Reload UI

                    // Show completion
                    Utils.showAlertMessage(
                        Strings.refreshDownloadsComplete,  // Success message
                        title: Strings.done,
                        viewControler: self
                    )
                }
            }
        }
    })

    alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel))
    present(alert, animated: true)
}
```

---

### 4.2 Localized Strings

**English (en.lproj/Localizable.strings):**
```
"refreshDownloadsTitle" = "Refresh Downloads";
"refreshDownloadsMessage" = "This will remove lessons from your downloads list if their files are missing. This can fix issues where lessons appear downloaded but can't be played.";
"refreshingDownloads" = "Refreshing downloads...";
"refreshDownloadsComplete" = "Downloads list refreshed successfully.";
```

**Spanish (es.lproj/Localizable.strings):**
```
"refreshDownloadsTitle" = "Actualizar Descargas";
"refreshDownloadsMessage" = "Esto eliminará las clases de tu lista de descargas si faltan sus archivos. Puede solucionar problemas donde las clases aparecen descargadas pero no se pueden reproducir.";
"refreshingDownloads" = "Actualizando descargas...";
"refreshDownloadsComplete" = "Lista de descargas actualizada exitosamente.";
```

---

## 5. Current File Validation Flow Summary

### 5.1 On App Launch (Complete Flow)

```
1. AppDelegate.didFinishLaunchingWithOptions
   └─> Initialize ContentRepository.shared
       └─> ContentRepository.init()
           ├─> loadShas()
           ├─> loadDownloadedLessonsFromStorage()  ← Loads registry from Documents
           ├─> loadGemaraLessonsFromStorage()
           ├─> loadMishnaLessonsFromStorage()
           └─> loadLastWatchedLessonsStorage()

2. SplashScreenViewController.viewDidLoad
   ├─> migrateDownloadsFromCachesToDocuments()
   │   ├─> Check migration flag (skip if done)
   │   ├─> Migrate registry file
   │   ├─> Migrate lesson files
   │   ├─> Clean up orphans
   │   └─> Set migration flag = true
   │
   ├─> reloadDownloadsFromStorage()
   │   └─> loadDownloadedLessonsFromStorage()  ← Refresh in-memory state
   │
   └─> removeOldDownloadedFiles()
       ├─> For each downloaded lesson:
       │   └─> removedOldFiles()
       │       ├─> Check file age (30+ days)
       │       ├─> Remove old files
       │       └─> Update registry if all removed
       └─> updateDownloadedLessonsStorage()

3. User Navigates to Downloads Screen
   └─> DownloadsViewController loads
       └─> setContent() displays downloads list
```

---

### 5.2 User-Triggered Validation

**Via Long Press on Downloads Title:**
```
1. User long-presses "Downloads" title (2 seconds)
2. Alert shown: "Refresh Downloads" with explanation
3. User confirms
4. Progress indicator shown
5. Background thread executes:
   └─> refreshDownloadsList()
       ├─> Scan all lessons
       ├─> Check file existence
       ├─> Collect orphaned entries
       ├─> Remove orphans from registry
       └─> Save updated registry
6. UI reloads with updated list
7. Completion alert shown
```

---

## 6. When Cleanup Operations Execute

### 6.1 Age-Based Cleanup (30+ Days)
**Function:** `removeOldDownloadedFiles()`

**Triggers:**
- ✅ App startup (SplashScreenViewController.viewDidLoad)
- ❌ Not on background/foreground transitions
- ❌ Not user-triggered

**What It Does:**
- Removes files older than 30 days
- Updates registry if files removed
- Runs automatically every app launch

---

### 6.2 Orphan Cleanup (Missing Files)
**Function:** `refreshDownloadsList()`

**Triggers:**
- ✅ User long-press on Downloads title (hidden feature)
- ✅ Migration process (one-time)
- ❌ Not automatic on app startup

**What It Does:**
- Removes registry entries with no files
- Does NOT delete files
- User must manually trigger (except during migration)

---

### 6.3 Migration (One-Time)
**Function:** `migrateDownloadsFromCachesToDocuments()`

**Triggers:**
- ✅ App startup (if not completed)
- ✅ Only runs once per device (UserDefaults flag)

**What It Does:**
- Moves files from Caches → Documents
- Moves registry file
- Cleans up orphans during migration
- Sets completion flag

---

## 7. Key Findings

### 7.1 Initialization vs. Cleanup
❗ **Important Discovery:**
- `ContentRepository.init()` ONLY loads data (lines 101-110)
- NO cleanup operations run during initialization
- Cleanup happens LATER in SplashScreenViewController

**Why This Matters:**
- Registry loads first without validation
- If migration/cleanup fails, invalid data persists in memory
- Must wait for SplashScreenViewController to complete cleanup

---

### 7.2 removeOldDownloadedFiles() Behavior
✅ **Fixed in Recent Update:**
- Previously checked wrong directory (Caches instead of Documents)
- Now correctly checks Documents directory (line 528)
- This was causing ALL downloads to be marked as orphaned

**Current Behavior:**
- Only removes files 30+ days old
- Does NOT remove orphaned entries (no files)
- Updates registry only if files actually removed

---

### 7.3 Manual Refresh Availability
✅ **Hidden Feature for Users:**
- Long press Downloads title for 2 seconds
- Shows confirmation dialog
- Removes orphaned entries (lessons with no files)
- Good for troubleshooting missing files

**UI/UX Consideration:**
- Feature is "hidden" (no documentation or UI hint)
- Could be made more discoverable with:
  - Settings menu option
  - Pull-to-refresh gesture
  - Info button with tooltip

---

### 7.4 Opportunities for UI-Triggered Validation

**Potential Enhancement Opportunities:**

1. **Pull-to-Refresh on Downloads Screen:**
   ```swift
   // Add UIRefreshControl to table view
   let refreshControl = UIRefreshControl()
   refreshControl.addTarget(self, action: #selector(refreshDownloads),
                           for: .valueChanged)
   tableView.refreshControl = refreshControl

   @objc func refreshDownloads() {
       ContentRepository.shared.refreshDownloadsList()
       setContent()
       refreshControl.endRefreshing()
   }
   ```

2. **Settings Menu Option:**
   - Add "Validate Downloads" button in app settings
   - Could combine with storage usage display
   - Show count of files and total size

3. **Automatic Background Validation:**
   ```swift
   // In AppDelegate.applicationDidBecomeActive
   func applicationDidBecomeActive(_ application: UIApplication) {
       // Run validation if not done in last 24 hours
       if shouldRunValidation() {
           ContentRepository.shared.refreshDownloadsList()
       }
   }
   ```

4. **Download List Empty State:**
   - If downloads screen is empty, offer "Scan for Downloads" button
   - Could help recover from registry corruption

---

## 8. Code Patterns and Best Practices

### 8.1 File Existence Checking Pattern
```swift
let fileManager = FileManager.default
let filePath = documentsURL.appendingPathComponent(fileName).path

if fileManager.fileExists(atPath: filePath) {
    // File exists, can use it
} else {
    // File missing, handle orphaned entry
}
```

Used in:
- `removedOldFiles()` - line 535
- `refreshDownloadsList()` - lines 1395, 1403, 1410, 1432, 1440, 1447
- `migrateLessonFiles()` - lines 1278, 1286, 1304, 1310, 1328, 1334

---

### 8.2 Registry Update Pattern
```swift
// 1. Modify in-memory structures
removeGemaraLessonFromArray(lesson, sederId, masechetId)

// 2. Persist to disk
updateDownloadedLessonsStorage()
```

This two-step pattern ensures:
- In-memory state always matches disk state
- Changes are atomic (all or nothing)
- Consistent behavior across app

---

### 8.3 Background Operation Pattern
```swift
DispatchQueue.global(qos: .userInitiated).async {
    // Heavy operation
    ContentRepository.shared.refreshDownloadsList()

    DispatchQueue.main.async {
        // Update UI
        self.setContent()
        // Show completion
        Utils.showAlertMessage(...)
    }
}
```

Used in:
- Manual refresh (DownloadsViewController, lines 112-128)
- Prevents UI blocking during file system operations

---

## 9. Diagnostic Logging

### 9.1 Load Operation Logging
**Location:** ContentRepository.swift, lines 698-775

**Console Output:**
```
📖 Loading downloads registry from: /path/to/downloadedLessons.json
   File exists: true
   File size: 445 characters
   JSON parsed successfully
   Keys found: gemara, mishna
   ✅ Loaded 1 Gemara lessons
   ✅ Loaded 0 Mishna lessons
📖 Loaded downloads registry: 1 Gemara + 0 Mishna lessons
```

**Error Cases:**
```
❌ Cannot load registry: Invalid storage URL
❌ Failed to parse registry JSON
   First 200 chars: {"gemara":[...]
⚠️  'gemara' key not found or wrong type
⚠️  5 Gemara lessons failed to initialize
```

---

### 9.2 Save Operation Logging
**Location:** ContentRepository.swift, lines 777-823

**Console Output:**
```
💾 Saving downloads registry: 1 Gemara + 0 Mishna lessons to /path/to/downloadedLessons.json
   Gemara structure: 1 seders
     Seder 1: 1 masechtot, 1 lessons
   Mishna structure: 0 seders
   📦 After mapping Gemara: 1 seders
     Seder 1: 1 masechtot, 1 lesson dictionaries
   📄 JSON content size: 445 characters
   📄 JSON preview (first 500 chars): {"gemara":{"1":{"1":[[{...}]]}},"mishna":{}}
✅ Downloads registry saved successfully
```

**Error Cases:**
```
❌ Cannot save registry: Invalid storage URL
❌ CRITICAL ERROR saving downloads registry: [error details]
   This means downloads will NOT persist after app restart!
```

---

### 9.3 Migration Logging
**Location:** ContentRepository.swift, lines 1173-1257

**Console Output:**
```
🔄 Starting downloads migration from Caches to Documents...
📋 Registry already exists in Documents, removing old cache version
📦 Migrated audio: 247_aud.mp3
📦 Migrated video: 247_vid.mp4
🗑️  Deleted duplicate PDF from Caches: 247_text.pdf
🧹 Cleaning up 0 orphaned download entries...
✅ Migration completed:
   📦 Migrated: 2 lessons
   🗑️  Deleted duplicates: 1 lessons
   🧹 Cleaned orphans: 0 entries
```

---

### 9.4 Refresh Logging
**Location:** ContentRepository.swift, lines 1375-1475

**Console Output:**
```
🔄 Refreshing downloads list...
🧹 Found orphaned Gemara lesson: 247
🧹 Found orphaned Mishna lesson: 123
✅ Removed 2 orphaned download entries
```

Or:
```
🔄 Refreshing downloads list...
✅ No orphaned downloads found
```

---

## 10. Storage Locations

### 10.1 Registry File
**Path:** `~/Documents/downloadedLessons.json`

**Structure:**
```json
{
  "gemara": {
    "1": {           // sederId
      "1": [         // masechetId
        [{lesson1}], // Array of lesson dictionaries
        [{lesson2}]
      ]
    }
  },
  "mishna": {
    "2": {           // sederId
      "5": {         // masechetId
        "3": [       // chapter
          [{lesson1}]
        ]
      }
    }
  }
}
```

---

### 10.2 Media Files
**Path:** `~/Documents/`

**File Naming:**
- Audio: `{lessonId}_aud.mp3`
- Video: `{lessonId}_vid.mp4`
- PDF/Text: `{lessonId}_text.pdf`

**Example:**
```
~/Documents/
  ├── downloadedLessons.json  (registry)
  ├── 247_aud.mp3            (audio)
  ├── 247_vid.mp4            (video)
  ├── 247_text.pdf           (text)
  ├── 248_aud.mp3
  └── ...
```

---

## 11. Related Files

### Core Files
- **ContentRepository.swift** - Main repository (lines 1-1476)
- **SplashScreenViewController.swift** - App initialization (lines 32-40)
- **DownloadsViewController.swift** - UI and manual refresh (lines 67-134)
- **UserDefaultsProvider.swift** - Migration flag storage (lines 245-253)

### Documentation
- **DOWNLOADS_PERSISTENCE_FIX_COMPLETE.md** - Bug fix documentation
- **IOS_DOWNLOADS_FIX_FINAL.md** - Original analysis
- **IOS_DOWNLOADS_DATA_TRANSFORMATION_ANALYSIS.md** - Data structures

---

## 12. Recommendations

### 12.1 Immediate Improvements
1. ✅ **Already Fixed:** Directory mismatch in `removeOldDownloadedFiles()` (line 528)
2. ✅ **Already Added:** Comprehensive diagnostic logging
3. ✅ **Already Implemented:** Migration system for Caches → Documents

### 12.2 Future Enhancements
1. **Make Manual Refresh More Discoverable:**
   - Add pull-to-refresh on Downloads screen
   - Add button in Settings
   - Add info tooltip explaining the feature

2. **Automatic Validation Improvements:**
   - Run `refreshDownloadsList()` on app startup (not just migration)
   - Add periodic validation (e.g., once per day)
   - Validate on network reconnection

3. **User Feedback:**
   - Show progress during cleanup operations
   - Display storage usage statistics
   - Notify user when orphaned entries are removed

4. **Error Recovery:**
   - Auto-retry migration on failure
   - Backup registry before major operations
   - Restore from backup on corruption

---

## 13. Testing Checklist

### Startup Validation
- [ ] App starts and loads registry successfully
- [ ] Migration runs once on first launch
- [ ] Old files (30+ days) are removed
- [ ] Console shows expected log messages

### Manual Refresh
- [ ] Long press on Downloads title works
- [ ] Confirmation dialog appears
- [ ] Progress indicator shows
- [ ] Orphaned entries are removed
- [ ] Success message displays

### Edge Cases
- [ ] Empty downloads list handled correctly
- [ ] Corrupted registry file recovery
- [ ] Partial file downloads (only audio/video)
- [ ] App crash during cleanup
- [ ] Low storage scenarios

---

## 14. Console Log Quick Reference

### Success Indicators
```
✅ Downloads registry saved successfully
✅ Loaded X Gemara lessons
✅ Migration completed
✅ Downloads reloaded from storage
✅ No orphaned downloads found
```

### Warning Signs
```
⚠️  X lessons failed to initialize
⚠️  'gemara' key not found or wrong type
ℹ️  Registry file does not exist
```

### Critical Errors
```
❌ Cannot load/save registry: Invalid storage URL
❌ CRITICAL ERROR saving downloads registry
❌ Error migrating [file]: [error details]
```

---

## Summary

The ContentRepository implements a robust file validation and cleanup system with:

1. **Automatic age-based cleanup** on app startup (30+ days)
2. **One-time migration** from Caches to persistent Documents storage
3. **Manual refresh feature** via hidden gesture (long press)
4. **Comprehensive logging** for debugging
5. **Atomic registry updates** to prevent data loss

The recent bug fix (line 528) corrected a critical directory mismatch that was causing all downloads to be removed on app restart. The system now correctly validates files in the Documents directory where they are actually stored.

For users experiencing orphaned downloads, the manual refresh feature (long press Downloads title for 2 seconds) provides a self-service recovery option.

---

**Last Updated:** 2025-10-12
**Analysis Version:** 1.0
**Files Analyzed:** 5 core files + 3 documentation files
