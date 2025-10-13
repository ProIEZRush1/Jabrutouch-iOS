# Download Icons Display Analysis - iOS App

## Investigation Summary

This document analyzes how download icons are determined and displayed in lesson cells throughout the iOS app, and explains why a lesson might show a download icon but not appear in the Downloads screen.

---

## Key Finding: TWO DIFFERENT SYSTEMS

The app uses **two completely different approaches** to determine if content is downloaded:

1. **Lesson Cells (Gemara/Mishna Lists)**: Direct file system checks
2. **Downloads Screen**: Registry-based lookup

This creates the possibility of **inconsistencies** where icons and the Downloads list are out of sync.

---

## System 1: Lesson Cell Download Icons (File-Based)

### Location: JTLesson Model
**File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTLesson.swift`

### How Icons Are Determined

**Lines 89-99**: Audio and Video download status
```swift
var isAudioDownloaded: Bool {
    // Changed from .cache to .documents to match new download location
    guard let filesNames = FilesManagementProvider.shared.filesList(.documents) else { return false }
    return filesNames.contains(self.audioLocalFileName)
}

var isVideoDownloaded: Bool {
    // Changed from .cache to .documents to match new download location
    guard let filesNames = FilesManagementProvider.shared.filesList(.documents) else { return false }
    return filesNames.contains(self.videoLocalFileName)
}
```

### Process Flow

1. **Get all files in Documents directory**
   - `FilesManagementProvider.shared.filesList(.documents)`
   - Returns array of all filenames: `["2813_aud.mp3", "2813_vid.mp4", "2814_aud.mp3", ...]`

2. **Check if lesson's file exists in array**
   - `filesNames.contains(self.audioLocalFileName)`
   - `audioLocalFileName` = `"\(id)_aud.mp3"` (e.g., "2813_aud.mp3")
   - `videoLocalFileName` = `"\(id)_vid.mp4"` (e.g., "2813_vid.mp4")

3. **Result**: Returns `true` if file exists, `false` otherwise

### Where Icons Are Displayed

**File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Cells/LessonDownloadCellController.swift`

**Lines 51-83**: `setProgressViewButtons(_:)` method
```swift
func setProgressViewButtons(_ lesson: JTLesson) {
    if lesson.isAudioDownloaded {
        self.downloadAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "audio-downloaded"), ...)
        self.cellAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "audio-downloaded"), ...)
    } else {
        self.downloadAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "downloadAudio"), ...)
        self.cellAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "audio-nat"), ...)
    }

    if lesson.isVideoDownloaded {
        self.downloadVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "video-downloaded"), ...)
        self.cellVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "video-downloaded"), ...)
    } else {
        self.downloadVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "downloadVideo"), ...)
        self.cellVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "video-nat"), ...)
    }
}
```

**Called from**:
- `GemaraLessonsViewController.swift` line 135: `cell.setLesson(lesson)`
- `MishnaLessonsViewController.swift` line 139: `cell.setLesson(lesson)`

---

## System 2: Downloads Screen (Registry-Based)

### Location: ContentRepository
**File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Repositories/ContentRepository.swift`

### How Downloads List Is Built

**Lines 321-355**: Downloads retrieval methods
```swift
func getDownloadedGemaraLessons() -> [JTSederDownloadedGemaraLessons] {
    var downloadedLessons:[JTSederDownloadedGemaraLessons] = []
    for (sederId,masechtotDict) in self.downloadedGemaraLessons {
        // Build from in-memory registry (downloadedGemaraLessons)
        // Does NOT check if files actually exist
    }
    return downloadedLessons
}

func getDownloadedMishnaLessons() -> [JTSederDownloadedMishnaLessons] {
    var downloadedLessons:[JTSederDownloadedMishnaLessons] = []
    for (sederId,masechtotDict) in self.downloadedMishnaLessons {
        // Build from in-memory registry (downloadedMishnaLessons)
        // Does NOT check if files actually exist
    }
    return downloadedLessons
}
```

### Registry Storage

**Lines 75-82**: Registry file location
```swift
var downloadedLessonsStorageUrl: URL? {
    // Changed from .cache to .documents for persistent storage
    // Registry file must be in Documents alongside the actual media files
    guard let directoryUrl = FileDirectory.documents.url else { return nil }
    let filename = "downloadedLessons.json"
    let url = directoryUrl.appendingPathComponent(filename)
    return url
}
```

### Where Downloads Screen Uses Registry

**File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/DownloadsViewController.swift`

**Lines 285-303**: Loading downloads
```swift
fileprivate func setContent(openSections: Bool = false) {
    self.gemaraDownloads = ContentRepository.shared.getDownloadedGemaraLessons()
    self.mishnaDownloads = ContentRepository.shared.getDownloadedMishnaLessons()
    // Uses ONLY the registry - no file checks
}
```

**Lines 437-438 & 467-468**: Display logic
```swift
// Gemara
cell.audioButton.isHidden = !lesson.lesson.isAudioDownloaded
cell.videoButton.isHidden = !lesson.lesson.isVideoDownloaded

// Mishna
cell.audioButton.isHidden = !lesson.lesson.isAudioDownloaded
cell.videoButton.isHidden = !lesson.lesson.isVideoDownloaded
```

**Critical Note**: Even on the Downloads screen, the audio/video buttons use the **file-based** `isAudioDownloaded` / `isVideoDownloaded` properties, but the lesson's **presence in the list** comes from the **registry**.

---

## The Discrepancy: Why Icons Show But Downloads Screen Doesn't

### Scenario 1: Orphaned Registry Entries (MOST COMMON)

**What happens**:
1. User downloads lesson → Registry updated + file saved
2. File gets deleted (iOS system cleanup, manual deletion, migration failure)
3. Registry still has entry
4. **Result**:
   - ❌ Lesson shows in Downloads list (from registry)
   - ❌ Download icons are HIDDEN (no files found)

**Evidence**: This is what the refresh functionality fixes

### Scenario 2: File Without Registry Entry

**What happens**:
1. Old download completed before registry system was implemented
2. Migration moved file to Documents but didn't update registry
3. File exists but registry is empty
4. **Result**:
   - ✅ Download icons SHOW (files exist)
   - ❌ Lesson does NOT appear in Downloads list (no registry entry)

**This is the reported issue!**

### Scenario 3: Registry and Files Out of Sync

**What happens**:
1. Download completes successfully
2. Registry update fails or is delayed
3. File exists, registry entry missing or incomplete
4. **Result**:
   - ✅ Download icons SHOW (files exist)
   - ⚠️  Lesson may or may not appear in Downloads list (depending on timing)

---

## Race Conditions and Timing Issues

### Download Completion Flow

**File**: `ContentRepository.swift` lines 1026-1056

```swift
func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType, success: Bool) {
    self.lessonEndedDownloading(downloadId, mediaType: mediaType)
    if let (lesson,sederId,masechetId,chapter) = self.getLessonFromLocalStorage(withId: downloadId) {
        // Update lesson state

        if success {
            if let gemaraLesson = lesson as? JTGemaraLesson {
                self.addLessonToDownloaded(gemaraLesson, sederId: sederId, masechetId: masechetId)
            }
            if let mishnaLesson = lesson as? JTMishnaLesson, let _chapter = chapter {
                self.addLessonToDownloaded(mishnaLesson, sederId: sederId, masechetId: masechetId, chapter: _chapter)
            }
        }
    }

    // Notify delegates
    DispatchQueue.main.async {
        for delegate in self.downloadDelegates {
            delegate.downloadCompleted(downloadId: downloadId, mediaType: mediaType)
        }
    }
}
```

**Lines 459-492**: Adding to registry
```swift
func addLessonToDownloaded(_ lesson: JTGemaraLesson, sederId: String, masechetId: String) {
    // Update in-memory registry
    if let _ = self.downloadedGemaraLessons[sederId] {
        if let _ = self.downloadedGemaraLessons[sederId]?[masechetId] {
            self.downloadedGemaraLessons[sederId]?[masechetId]?.insert(lesson)
        } else {
            self.downloadedGemaraLessons[sederId]?[masechetId] = [lesson]
        }
    } else {
        self.downloadedGemaraLessons[sederId] = [masechetId:[lesson]]
    }
    self.updateDownloadedLessonsStorage() // Save to disk
}
```

### Potential Race Condition

1. **File is written** to Documents directory (by DownloadTask)
2. **Lesson cells reload** → Check files → ✅ Show download icon
3. **Registry update happens** (addLessonToDownloaded called)
4. **Downloads screen loads** → ✅ Shows lesson in list

**BUT**: If step 2 happens BEFORE step 3 completes, you get the inconsistency!

---

## File System Operations

### FilesManagementProvider.filesList()

**File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/FilesManagementProvider.swift`

**Lines 63-74**:
```swift
func filesList(_ directory: FileDirectory) -> [String]? {
    guard let directoryUrl = directory.url else { return nil }

    do {
        let files = try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
        let filesNames = files.map{$0.lastPathComponent}
        return filesNames
    }
    catch {
        return nil
    }
}
```

**How it works**:
- Uses `FileManager.contentsOfDirectory()` to get ALL files in directory
- Returns just the filenames (last path component)
- Returns `nil` if directory can't be accessed
- **Does NOT cache** - reads filesystem each time
- **Performance**: O(n) where n = total files in Documents directory

---

## Downloads Screen Validation

### Background Validation

**File**: `DownloadsViewController.swift` lines 143-177

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setContent(openSections: true)
    setSelectedPage()
    ContentRepository.shared.addDelegate(self)
    self.lessonWatched = UserDefaultsProvider.shared.lessonWatched

    // Automatically validate downloads in the background to keep UI synced
    // This removes orphaned entries (lessons where files were deleted)
    validateDownloadsInBackground()
}

private func validateDownloadsInBackground() {
    DispatchQueue.global(qos: .utility).async {
        let repository = ContentRepository.shared

        // Validate and remove orphaned entries
        repository.refreshDownloadsList()

        // If orphaned entries were removed, refresh UI
        if totalAfter < totalBefore {
            DispatchQueue.main.async {
                self.setContent(openSections: false)
            }
        }
    }
}
```

### Manual Refresh (Hidden Feature)

**Lines 82-134**: Long-press on title to trigger refresh
```swift
@objc func titleLongPressed(_ gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began else { return }

    let alert = UIAlertController(
        title: Strings.refreshDownloadsTitle,
        message: Strings.refreshDownloadsMessage,
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: Strings.refresh, style: .default) { _ in
        DispatchQueue.global(qos: .userInitiated).async {
            ContentRepository.shared.refreshDownloadsList()

            DispatchQueue.main.async {
                self.setContent(openSections: false)
                Utils.showAlertMessage(
                    Strings.refreshDownloadsComplete,
                    title: Strings.done,
                    viewControler: self
                )
            }
        }
    })
}
```

### ContentRepository.refreshDownloadsList()

**File**: `ContentRepository.swift` lines 1375-1475

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

    // Check Gemara downloads
    for (sederId, masechtotDict) in downloadedGemaraLessons {
        for (masechetId, lessons) in masechtotDict {
            for lesson in lessons {
                var hasAnyFile = false

                // Check if ANY of the lesson's files exist
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

                if !hasAnyFile {
                    orphanedGemara.append((lesson, sederId, masechetId))
                }
            }
        }
    }

    // Remove orphaned entries
    for item in orphanedGemara {
        removeGemaraLessonFromArray(item.lesson, sederId: item.sederId, masechetId: item.masechetId)
    }

    if !orphanedGemara.isEmpty || !orphanedMishna.isEmpty {
        updateDownloadedLessonsStorage()
    }
}
```

**This fixes orphaned entries but does NOT add missing entries!**

---

## Summary: The Fundamental Issue

### The Problem

**Two Independent Systems**:
1. **Download Icons**: File existence check (real-time, always current)
2. **Downloads List**: Registry lookup (can be stale, requires updates)

### Why Discrepancies Occur

| Scenario | Files Exist? | Registry Entry? | Icon Shows? | In Downloads List? |
|----------|-------------|-----------------|-------------|-------------------|
| **Normal Download** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Orphaned Registry** | ❌ No | ✅ Yes | ❌ No | ✅ Yes (BUG) |
| **Missing Registry** | ✅ Yes | ❌ No | ✅ Yes (BUG) | ❌ No |
| **Complete Deletion** | ❌ No | ❌ No | ❌ No | ❌ No |

**The Reported Issue**: Row 3 - Files exist but registry entry is missing

### When This Happens

1. **Migration issues**: Files moved but registry not updated
2. **Failed registry writes**: Download completes but registry save fails
3. **Timing issues**: UI reads files before registry update completes
4. **Legacy downloads**: Old downloads before registry system existed

---

## Solutions Implemented

### 1. Background Validation (Partial Fix)

**Location**: `DownloadsViewController.viewWillAppear()`

**What it does**: Removes orphaned entries (registry without files)

**What it DOESN'T do**: Add missing entries (files without registry)

### 2. Manual Refresh (Partial Fix)

**Location**: Long-press on Downloads screen title

**What it does**: Same as background validation

**What it DOESN'T do**: Add missing entries

### 3. Migration System (Attempted Fix)

**Location**: `ContentRepository.migrateDownloadsFromCachesToDocuments()`

**What it does**:
- Moves files from Caches to Documents
- Removes orphaned entries after migration
- Marks migration as complete

**What it DOESN'T do**: Add registry entries for files without them

---

## What's Missing: The Fix Needed

To fully solve the discrepancy, the system needs a **bi-directional sync** that:

1. **Removes orphaned registry entries** (files don't exist) ✅ DONE
2. **Adds missing registry entries** (files exist but not in registry) ❌ NOT DONE

### Proposed Solution

Add a method to scan Documents directory and add missing entries:

```swift
func syncRegistryWithFiles() {
    guard let documentsURL = FileDirectory.documents.url else { return }
    guard let allFiles = FilesManagementProvider.shared.filesList(.documents) else { return }

    // Filter for lesson files (pattern: {id}_aud.mp3 or {id}_vid.mp4)
    let lessonFiles = allFiles.filter {
        $0.hasSuffix("_aud.mp3") || $0.hasSuffix("_vid.mp4")
    }

    for filename in lessonFiles {
        // Extract lesson ID from filename
        let lessonId = extractLessonId(from: filename)

        // Check if lesson is in registry
        let inRegistry = isLessonInRegistry(lessonId)

        if !inRegistry {
            // Fetch lesson metadata from API or local cache
            // Add to registry
            // This is the missing piece!
        }
    }
}
```

**Challenge**: When you find a file without a registry entry, you need to know:
- Is it Gemara or Mishna?
- What is the sederId?
- What is the masechetId?
- What is the chapter? (for Mishna)

This metadata is NOT in the filename - it's only in the registry!

---

## File Path Reference

All key locations with line numbers:

### JTLesson Model
- **File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTLesson.swift`
- **isAudioDownloaded**: Lines 89-93
- **isVideoDownloaded**: Lines 95-99
- **isTextFileDownloaded**: Lines 101-110
- **localFileUrls**: Lines 187-199

### LessonDownloadCellController (Lesson Lists)
- **File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Cells/LessonDownloadCellController.swift`
- **setProgressViewButtons**: Lines 51-83

### GemaraLessonsViewController
- **File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Gemara/GemaraLessonsViewController.swift`
- **Cell configuration**: Lines 122-152
- **Download audio**: Lines 211-223
- **Download video**: Lines 225-237

### MishnaLessonsViewController
- **File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Mishna/MishnaLessonsViewController.swift`
- **Cell configuration**: Lines 126-156
- **Download audio**: Lines 218-230
- **Download video**: Lines 232-244

### DownloadsViewController
- **File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/DownloadsViewController.swift`
- **setContent**: Lines 285-304
- **Gemara cell display**: Lines 415-447
- **Mishna cell display**: Lines 448-478
- **Background validation**: Lines 143-177
- **Manual refresh**: Lines 82-134

### DownloadsCellController (Downloads Screen)
- **File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Downloads/Cells/DownloadsCellController.swift`
- **Cell configuration**: All (simple structure)

### ContentRepository
- **File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Repositories/ContentRepository.swift`
- **getDownloadedGemaraLessons**: Lines 321-336
- **getDownloadedMishnaLessons**: Lines 338-355
- **addLessonToDownloaded (Gemara)**: Lines 459-472
- **addLessonToDownloaded (Mishna)**: Lines 474-492
- **downloadCompleted**: Lines 1026-1056
- **refreshDownloadsList**: Lines 1375-1475
- **Registry storage URL**: Lines 75-82
- **Load registry**: Lines 698-775
- **Save registry**: Lines 777-823

### FilesManagementProvider
- **File**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/FilesManagementProvider.swift`
- **filesList**: Lines 63-74
- **isFileExist**: Lines 111-120

---

## Conclusion

The discrepancy between download icons and the Downloads screen exists because:

1. **Icons** are determined by **direct file checks** (always accurate, real-time)
2. **Downloads list** is determined by **registry lookup** (can be stale)
3. The system **removes orphaned registry entries** but **does NOT add missing entries**
4. Files can exist without registry entries (migration issues, failed saves, legacy downloads)

The current `refreshDownloadsList()` only fixes one direction of the problem. A complete fix would require:
- Scanning files and adding missing registry entries
- Metadata lookup or storage to properly categorize orphaned files
- OR: Make the Downloads screen also use file-based checks (but this loses the organizational structure)
