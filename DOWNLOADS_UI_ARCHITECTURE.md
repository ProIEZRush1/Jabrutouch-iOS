# iOS Downloads UI Architecture Analysis

## Executive Summary

This document provides a comprehensive analysis of how downloaded lessons are displayed in the iOS app's Downloads screen, including data flow from `ContentRepository` to the UI, refresh mechanisms, and integration points for syncing after file validation.

---

## UI Component Architecture

### 1. Main View Controller

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/DownloadsViewController.swift`

**Class:** `DownloadsViewController`

**Key Responsibilities:**
- Displays downloaded Gemara and Mishna lessons in separate table views
- Manages tab switching between Gemara/Mishna views
- Handles lesson playback, deletion, and section expansion/collapse
- Implements `ContentRepositoryDownloadDelegate` for real-time download updates

**UI Components:**
```swift
@IBOutlet weak var gemaraTableView: UITableView!
@IBOutlet weak var mishnaTableView: UITableView!
@IBOutlet weak var gemaraButton: UIButton!           // Tab selector
@IBOutlet weak var mishnaButton: UIButton!           // Tab selector
@IBOutlet weak var deleteButton: UIButton!
@IBOutlet weak var titleLabel: UILabel!              // Used for hidden refresh gesture
```

**State Properties:**
```swift
fileprivate var gemaraDownloads: [JTSederDownloadedGemaraLessons] = []
fileprivate var mishnaDownloads: [JTSederDownloadedMishnaLessons] = []
fileprivate var isGemaraSelected = true
fileprivate var isDeleting = false
fileprivate var gemaraOpenSections: Set<Int> = []
fileprivate var mishnaOpenSections: Set<Int> = []
```

---

### 2. Cell Controllers

#### a) **DownloadsCellController** (Lesson Row Cell)

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Downloads/Cells/DownloadsCellController.swift`

**Displays:**
- Book/masechet name
- Chapter (for Mishna)
- Lesson number (page/mishna)
- Audio/video download indicators
- Progress bar for watched progress
- Delete button (when in delete mode)

**Key Outlets:**
```swift
@IBOutlet weak var book: UILabel!
@IBOutlet weak var chapter: UILabel!
@IBOutlet weak var number: UILabel!
@IBOutlet weak var audioButton: UIButton!
@IBOutlet weak var videoButton: UIButton!
@IBOutlet weak var deleteButton: UIButton!
@IBOutlet weak var progressBar: JBProgressBar!
```

#### b) **HeaderCellController** (Section Header)

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Downloads/DownloadsHeaderCellController.swift`

**Displays:**
- Seder name (e.g., "Zeraim", "Moed", "Nezikin")
- Lesson count badge
- Expand/collapse arrow
- Tap gesture to toggle section

---

## Data Flow Architecture

### From ContentRepository to UI

```
ContentRepository
    ↓
[downloadedGemaraLessons] & [downloadedMishnaLessons]
    ↓
getDownloadedGemaraLessons() / getDownloadedMishnaLessons()
    ↓ (transforms data into UI-friendly structures)
[JTSederDownloadedGemaraLessons] / [JTSederDownloadedMishnaLessons]
    ↓
DownloadsViewController.setContent()
    ↓
gemaraDownloads / mishnaDownloads (local state)
    ↓
UITableView.reloadData()
    ↓
Cells rendered with lesson data
```

### Data Models

**ContentRepository Internal Storage:**
```swift
// In-memory registry of downloaded lessons
private var downloadedGemaraLessons: [SederId:[MasechetId:Set<JTGemaraLesson>]] = [:]
private var downloadedMishnaLessons: [SederId:[MasechetId:[Chapter:Set<JTMishnaLesson>]]] = [:]

// Persisted to: ~/Documents/downloadedLessons.json
```

**UI Display Models:**
```swift
// Gemara lessons grouped by seder
struct JTSederDownloadedGemaraLessons {
    var sederId: String
    var sederName: String
    var records: [JTGemaraLessonRecord]
    var order: Int
}

// Mishna lessons grouped by seder
struct JTSederDownloadedMishnaLessons {
    var sederId: String
    var sederName: String
    var records: [JTMishnaLessonRecord]
    var order: Int
}
```

**Lesson Record Models:**
```swift
struct JTGemaraLessonRecord {
    var lesson: JTGemaraLesson
    var masechetName: String
    var masechetId: String
    var sederId: String
}

struct JTMishnaLessonRecord {
    var lesson: JTMishnaLesson
    var masechetName: String
    var masechetId: String
    var chapter: String
    var sederId: String
}
```

---

## Download State Detection

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTLesson.swift`

Lessons dynamically check if their files exist in the file system:

```swift
var isAudioDownloaded: Bool {
    guard let filesNames = FilesManagementProvider.shared.filesList(.documents) else { return false }
    return filesNames.contains(self.audioLocalFileName)
}

var isVideoDownloaded: Bool {
    guard let filesNames = FilesManagementProvider.shared.filesList(.documents) else { return false }
    return filesNames.contains(self.videoLocalFileName)
}

var isTextFileDownloaded: Bool {
    guard let filesNames = FilesManagementProvider.shared.filesList(.documents) else { return false }
    return filesNames.contains(self.textLocalFileName)
}
```

**Important:** These properties are computed properties that check the actual file system. This means:
- ✅ They reflect the real-time state of downloaded files
- ❌ They query the file system on every access (performance consideration)
- 🔍 They're the source of truth for what's actually downloaded

---

## Refresh & Sync Mechanisms

### 1. Automatic Refresh on View Appearance

**Location:** `DownloadsViewController.viewWillAppear()`

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setContent(openSections: true)              // Reloads data from ContentRepository
    setSelectedPage()                           // Updates UI state
    ContentRepository.shared.addDelegate(self)  // Register for download updates
    self.lessonWatched = UserDefaultsProvider.shared.lessonWatched
}
```

**When triggered:**
- Every time the Downloads screen appears
- After navigating back from lesson player
- After app returns to foreground (if Downloads view is visible)

**What happens:**
1. Calls `ContentRepository.shared.getDownloadedGemaraLessons()` and `getDownloadedMishnaLessons()`
2. Updates local `gemaraDownloads` and `mishnaDownloads` arrays
3. Reloads both table views
4. Opens all sections by default
5. Shows/hides "no downloads" message

---

### 2. Real-Time Download Completion Updates

**Protocol:** `ContentRepositoryDownloadDelegate`

```swift
extension DownloadsViewController: ContentRepositoryDownloadDelegate {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType) {
        self.setContent()  // Immediately refresh the entire list
    }

    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType) {
        // Not implemented in Downloads view (used in other views)
    }
}
```

**When triggered:**
- When a download completes successfully via `DownloadTask`
- Triggered from `ContentRepository.downloadCompleted()` method
- Called on main thread via delegate pattern

**What happens:**
1. `ContentRepository` adds the lesson to its internal registry
2. Notifies all registered delegates via `downloadCompleted()`
3. `DownloadsViewController` receives callback and calls `setContent()`
4. UI updates with new downloaded lesson

**Delegate Registration:**
```swift
// Register when view appears
viewWillAppear() → ContentRepository.shared.addDelegate(self)

// Unregister when view disappears
viewWillDisappear() → ContentRepository.shared.removeDelegate(self)
```

---

### 3. Manual Refresh via Hidden Gesture (NEW!)

**Location:** `DownloadsViewController.setupRefreshGesture()` and `titleLongPressed()`

**Activation:** Long-press (2 seconds) on the "Downloads" title label

**Purpose:** Manually clean up orphaned download entries (lessons in registry but files missing)

```swift
fileprivate func setupRefreshGesture() {
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(titleLongPressed(_:)))
    longPress.minimumPressDuration = 2.0
    titleLabel.isUserInteractionEnabled = true
    titleLabel.addGestureRecognizer(longPress)
}

@objc func titleLongPressed(_ gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began else { return }

    // Show confirmation alert
    let alert = UIAlertController(
        title: Strings.refreshDownloadsTitle,
        message: Strings.refreshDownloadsMessage,
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: Strings.refresh, style: .default) { _ in
        // Show activity indicator
        let activityAlert = UIAlertController(...)
        self.present(activityAlert, animated: true)

        // Perform refresh on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            ContentRepository.shared.refreshDownloadsList()

            DispatchQueue.main.async {
                activityAlert.dismiss(animated: true) {
                    self.setContent(openSections: false)
                    Utils.showAlertMessage(
                        Strings.refreshDownloadsComplete,
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

**What `refreshDownloadsList()` does:**
1. Iterates through all registered Gemara/Mishna downloads
2. Checks if ANY media file (audio/video/text) exists in Documents directory
3. Identifies orphaned entries (in registry but no files)
4. Removes orphaned entries from in-memory registry
5. Updates persistent storage (`downloadedLessons.json`)
6. Returns count of cleaned entries

**Implementation in ContentRepository:**
```swift
func refreshDownloadsList() {
    print("🔄 Refreshing downloads list...")

    guard let documentsURL = FileDirectory.documents.url else {
        print("❌ Could not access Documents directory")
        return
    }

    let fileManager = FileManager.default
    var orphanedGemara: [(lesson: JTGemaraLesson, sederId: String, masechetId: String)] = []
    var orphanedMishna: [(lesson: JTMishnaLesson, sederId: String, masechetId: String, chapter: String)] = []

    // Check Gemara downloads for orphaned entries
    for (sederId, masechtotDict) in downloadedGemaraLessons {
        for (masechetId, lessons) in masechtotDict {
            for lesson in lessons {
                var hasAnyFile = false

                // Check if ANY file exists
                if lesson.audioLink != nil {
                    let audioPath = documentsURL.appendingPathComponent(lesson.audioLocalFileName).path
                    if fileManager.fileExists(atPath: audioPath) {
                        hasAnyFile = true
                    }
                }

                if lesson.videoLink != nil {
                    let videoPath = documentsURL.appendingPathComponent(lesson.videoLocalFileName).path
                    if fileManager.fileExists(atPath: videoPath) {
                        hasAnyFile = true
                    }
                }

                if lesson.textLink != nil {
                    let textPath = documentsURL.appendingPathComponent(lesson.textLocalFileName).path
                    if fileManager.fileExists(atPath: textPath) {
                        hasAnyFile = true
                    }
                }

                if !hasAnyFile {
                    orphanedGemara.append((lesson, sederId, masechetId))
                    print("🧹 Found orphaned Gemara lesson: \(lesson.id)")
                }
            }
        }
    }

    // Same logic for Mishna downloads...

    // Remove orphaned entries
    for item in orphanedGemara {
        removeGemaraLessonFromArray(item.lesson, sederId: item.sederId, masechetId: item.masechetId)
    }

    for item in orphanedMishna {
        removeMishnaLessonFromArray(item.lesson, sederId: item.sederId, masechetId: item.masechetId, chapter: item.chapter)
    }

    if !orphanedGemara.isEmpty || !orphanedMishna.isEmpty {
        updateDownloadedLessonsStorage()
        print("✅ Removed \(orphanedGemara.count + orphanedMishna.count) orphaned download entries")
    } else {
        print("✅ No orphaned downloads found")
    }
}
```

---

### 4. No Pull-to-Refresh Implementation

**Finding:** There is NO `UIRefreshControl` or pull-to-refresh mechanism implemented in the Downloads screen.

**Current alternatives:**
- ✅ Automatic refresh on `viewWillAppear()`
- ✅ Manual refresh via long-press on title (hidden feature)
- ✅ Real-time updates via delegate when downloads complete

---

## Integration Points for File Validation Sync

### Recommended Approach: Call After Validation

After file validation completes (when you've corrected download flags), trigger a UI refresh:

**Option 1: Direct UI Refresh (if DownloadsViewController is visible)**
```swift
// After validation in your validation function
DispatchQueue.main.async {
    if let downloadsVC = getCurrentDownloadsViewControllerIfVisible() {
        downloadsVC.setContent(openSections: false)
    }
}
```

**Option 2: Delegate Notification (cleaner approach)**

Add a new delegate method to `ContentRepositoryDownloadDelegate`:
```swift
protocol ContentRepositoryDownloadDelegate: class {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType)
    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType)
    func downloadsValidationCompleted() // NEW
}
```

Then in your validation completion:
```swift
// After validation completes
DispatchQueue.main.async {
    for delegate in self.downloadDelegates {
        delegate.downloadsValidationCompleted()
    }
}
```

And implement in DownloadsViewController:
```swift
extension DownloadsViewController: ContentRepositoryDownloadDelegate {
    // ... existing methods ...

    func downloadsValidationCompleted() {
        self.setContent(openSections: false)
    }
}
```

**Option 3: Post Notification (simplest, no protocol changes)**
```swift
// After validation
DispatchQueue.main.async {
    NotificationCenter.default.post(name: .downloadsValidationCompleted, object: nil)
}

// Add notification name extension
extension Notification.Name {
    static let downloadsValidationCompleted = Notification.Name("downloadsValidationCompleted")
}

// In DownloadsViewController.viewDidLoad()
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleDownloadsValidation),
    name: .downloadsValidationCompleted,
    object: nil
)

@objc private func handleDownloadsValidation() {
    setContent(openSections: false)
}
```

---

## Key Methods Reference

### DownloadsViewController Methods

```swift
// Main data refresh - call this after validation
fileprivate func setContent(openSections: Bool = false)
// - Fetches fresh data from ContentRepository
// - Updates local gemaraDownloads/mishnaDownloads arrays
// - Reloads both table views
// - Updates section expansion state
// - Shows/hides empty state messages

// UI state updates
fileprivate func setSelectedPage()
// - Updates button colors/fonts
// - Updates arrow position
// - Checks if tables are empty

fileprivate func checkIfTableViewEmpty(_ downloads: [Any], _ tableView: UITableView)
// - Shows/hides table view
// - Shows/hides "no downloads" message
// - Shows/hides delete button
```

### ContentRepository Methods

```swift
// Fetch downloaded lessons for UI display
func getDownloadedGemaraLessons() -> [JTSederDownloadedGemaraLessons]
func getDownloadedMishnaLessons() -> [JTSederDownloadedMishnaLessons]

// Manual cleanup of orphaned entries (called by long-press gesture)
func refreshDownloadsList()

// Add/remove lessons from registry
func addLessonToDownloaded(_ lesson: JTGemaraLesson, sederId: String, masechetId: String)
func addLessonToDownloaded(_ lesson: JTMishnaLesson, sederId: String, masechetId: String, chapter: String)
func removeLessonFromDownloaded(_ lesson: JTGemaraLesson, sederId: String, masechetId: String)
func removeLessonFromDownloaded(_ lesson: JTMishnaLesson, sederId: String, masechetId: String, chapter: String)

// Internal registry array manipulation
func removeGemaraLessonFromArray(_ lesson: JTGemaraLesson, sederId: String, masechetId: String)
func removeMishnaLessonFromArray(_ lesson: JTMishnaLesson, sederId: String, masechetId: String, chapter: String)

// Persist registry to disk
private func updateDownloadedLessonsStorage()
```

---

## UI Update Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      User Actions                            │
└───────────┬────────────────────────┬────────────────────────┘
            │                        │
            │                        │
    ┌───────▼────────┐      ┌────────▼────────┐
    │ View Appears   │      │ Long Press      │
    │ (automatic)    │      │ Title (manual)  │
    └───────┬────────┘      └────────┬────────┘
            │                        │
            │                        │
    ┌───────▼────────────────────────▼────────┐
    │     DownloadsViewController              │
    │     setContent(openSections)             │
    └───────┬──────────────────────────────────┘
            │
            ├──────────────────────┬────────────────────┐
            │                      │                    │
    ┌───────▼────────┐    ┌────────▼─────────┐  ┌─────▼──────────┐
    │ Get Gemara     │    │ Get Mishna       │  │ Update UI      │
    │ Downloads      │    │ Downloads        │  │ State          │
    └───────┬────────┘    └────────┬─────────┘  └─────┬──────────┘
            │                      │                   │
    ┌───────▼──────────────────────▼───────────────────▼────────┐
    │           ContentRepository.shared                         │
    │  getDownloadedGemaraLessons()                             │
    │  getDownloadedMishnaLessons()                             │
    └───────┬────────────────────────────────────────────────────┘
            │
            │ Reads from in-memory registry
            │ (backed by ~/Documents/downloadedLessons.json)
            │
    ┌───────▼────────────────────────────────────────────────────┐
    │  [downloadedGemaraLessons]                                 │
    │  [downloadedMishnaLessons]                                 │
    │  Dictionary structure:                                      │
    │    SederId → MasechetId → Set<JTLesson>                    │
    └───────┬────────────────────────────────────────────────────┘
            │
            │ Transforms to UI models
            │
    ┌───────▼────────────────────────────────────────────────────┐
    │  [JTSederDownloadedGemaraLessons]                          │
    │  [JTSederDownloadedMishnaLessons]                          │
    │  Array of seders with lesson records                        │
    └───────┬────────────────────────────────────────────────────┘
            │
            │ Returns to DownloadsViewController
            │
    ┌───────▼────────────────────────────────────────────────────┐
    │  Local state arrays:                                        │
    │    gemaraDownloads: [JTSederDownloadedGemaraLessons]       │
    │    mishnaDownloads: [JTSederDownloadedMishnaLessons]       │
    └───────┬────────────────────────────────────────────────────┘
            │
            │ Reload table views
            │
    ┌───────▼────────────────────────────────────────────────────┐
    │  UITableView (Gemara/Mishna)                               │
    │  - Sections = Seders                                        │
    │  - Rows = Lessons                                           │
    │  - Cells show audio/video indicators from                   │
    │    lesson.isAudioDownloaded / lesson.isVideoDownloaded     │
    └────────────────────────────────────────────────────────────┘
```

---

## Cell Data Binding Flow

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "downloadsCell") as! DownloadsCellController

    if tableView == gemaraTableView {
        let lessons = gemaraDownloads[indexPath.section].records.sorted { ... }
        let lesson = lessons[indexPath.row]

        cell.book.text = lesson.masechetName
        cell.number.text = "\(lesson.lesson.page)"

        // These check actual file existence in real-time
        cell.audioButton.isHidden = !lesson.lesson.isAudioDownloaded
        cell.videoButton.isHidden = !lesson.lesson.isVideoDownloaded

        // Progress bar for watched progress
        if self.lessonWatched.contains(where: { $0.lessonId == lesson.lesson.id }) {
            Utils.setProgressbar(...)
        }
    }

    // Similar logic for mishnaTableView...

    return cell
}
```

**Important:**
- `lesson.lesson.isAudioDownloaded` and `lesson.lesson.isVideoDownloaded` are computed properties
- They check the Documents directory file system on each access
- This means cells automatically reflect current file state when reloaded
- **After validation, simply reload the table views to show updated states**

---

## Testing UI Refresh After Validation

### Manual Test Procedure

1. **Navigate to Downloads screen**
2. **Note which lessons show audio/video icons**
3. **Run your validation function** (e.g., from app launch or debug menu)
4. **Trigger UI refresh** using one of these methods:
   - Navigate away and back to Downloads screen (automatic via `viewWillAppear`)
   - Long-press "Downloads" title for 2 seconds → tap "Refresh"
   - If implemented: Pull-to-refresh or auto-refresh after validation
5. **Verify:**
   - Orphaned lessons (no files) should disappear from list
   - Lessons with files should show correct audio/video indicators
   - Section counts should update
   - Empty message should appear if all lessons removed

### Debug Logging

Add this to see what's happening:
```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("📱 Downloads view appearing - fetching fresh data")
    setContent(openSections: true)
    print("   Gemara downloads: \(gemaraDownloads.count) seders")
    for seder in gemaraDownloads {
        print("     - \(seder.sederName): \(seder.records.count) lessons")
    }
    print("   Mishna downloads: \(mishnaDownloads.count) seders")
    for seder in mishnaDownloads {
        print("     - \(seder.sederName): \(seder.records.count) lessons")
    }
    // ...
}
```

---

## Summary & Recommendations

### Current State
✅ **Automatic refresh on view appearance** - Works reliably
✅ **Real-time updates via delegates** - When downloads complete
✅ **Manual refresh via hidden gesture** - Long-press title (2s)
❌ **No pull-to-refresh** - Not implemented
❌ **No automatic validation on launch** - Must be triggered manually

### Recommended Integration

**Best approach for post-validation UI sync:**

1. **Add notification after validation completes:**
```swift
// In your validation completion
DispatchQueue.main.async {
    NotificationCenter.default.post(name: .downloadsValidationCompleted, object: nil)
}
```

2. **Listen in DownloadsViewController:**
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // ... existing setup ...

    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleDownloadsValidation),
        name: .downloadsValidationCompleted,
        object: nil
    )
}

@objc private func handleDownloadsValidation() {
    print("📱 Received validation completion notification - refreshing UI")
    setContent(openSections: false)
}

deinit {
    NotificationCenter.default.removeObserver(self)
}
```

3. **Define notification name:**
```swift
extension Notification.Name {
    static let downloadsValidationCompleted = Notification.Name("downloadsValidationCompleted")
}
```

**Why this approach?**
- ✅ Decoupled - no tight coupling between validation and UI
- ✅ Simple - no protocol changes needed
- ✅ Safe - runs on main thread
- ✅ Reliable - notification system is battle-tested
- ✅ Easy to test - can post notification manually

### Alternative: Automatic Refresh on Validation

If you want the Downloads screen to always show correct state after validation:

**Option A: Refresh on every viewWillAppear**
- This already happens! Just ensure validation runs before user navigates to Downloads

**Option B: Add pull-to-refresh**
```swift
private lazy var refreshControl: UIRefreshControl = {
    let control = UIRefreshControl()
    control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    return control
}()

override func viewDidLoad() {
    super.viewDidLoad()
    gemaraTableView.refreshControl = refreshControl
    // Note: Can only add to one table view, or create separate controls
}

@objc private func handleRefresh() {
    DispatchQueue.global(qos: .userInitiated).async {
        ContentRepository.shared.refreshDownloadsList()

        DispatchQueue.main.async {
            self.setContent(openSections: false)
            self.refreshControl.endRefreshing()
        }
    }
}
```

---

## File Locations Reference

```
/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/

Jabrutouch/Controller/Main/
├── DownloadsViewController.swift                    // Main Downloads screen
├── Downloads/
│   ├── DownloadsHeaderCellController.swift         // Section headers
│   └── Cells/
│       └── DownloadsCellController.swift           // Lesson row cells

Jabrutouch/App/
├── Repositories/
│   └── ContentRepository.swift                     // Download registry & data
├── Models/
│   ├── Content/
│   │   ├── Domain Models/
│   │   │   ├── JTLesson.swift                     // Base lesson with download checks
│   │   │   ├── JTGemaraLesson.swift
│   │   │   └── JTMishnaLesson.swift
│   │   └── App Models/
│   │       ├── JTSederDownloadedGemaraLessons.swift
│   │       ├── JTSederDownloadedMishnaLessons.swift
│   │       ├── JTMasechetDownloadedGemaraLessons.swift
│   │       ├── JTGemaraLessonRecord.swift
│   │       └── JTMishnaLessonRecord.swift
│   └── Data Models/
│       ├── JTDownload.swift
│       └── JTLessonDownload.swift
└── Resources/
    └── Strings.swift                               // Localized strings
```

---

## Conclusion

The Downloads UI architecture is well-structured with clear separation of concerns:
- **ContentRepository** manages the download registry and file validation
- **DownloadsViewController** handles UI state and user interactions
- **Delegate pattern** enables real-time updates when downloads complete
- **Computed properties** on `JTLesson` provide real-time file existence checks

To integrate file validation sync, simply post a notification or call `setContent()` after validation completes. The UI will automatically refresh to show the corrected state based on actual file existence.

The hidden long-press refresh feature already implements the same `refreshDownloadsList()` logic you need, so you can reuse that pattern for automatic post-validation cleanup.
