# Lesson Download Status Implementation Analysis

## Date: 2025-10-12

## Executive Summary

This document provides a comprehensive analysis of how `isAudioDownloaded` and `isVideoDownloaded` properties work in the iOS JabruTouch app, including their implementation, relationship with the registry, and potential sources of inconsistency.

---

## Core Implementation

### Location
**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTLesson.swift`

### Properties (Lines 89-99)

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

### File Naming Pattern (Lines 148-154)

```swift
var audioLocalFileName: String {
    return "\(self.id)_aud.mp3"
}

var videoLocalFileName: String {
    return "\(self.id)_vid.mp4"
}
```

**Example:** Lesson ID 2813 → `2813_aud.mp3`, `2813_vid.mp4`

---

## Critical Finding: Direct File System Checks

### Implementation Type: **COMPUTED PROPERTIES**

These are NOT stored properties from a registry. They are computed properties that:

1. **Query the file system on EVERY access**
2. **List ALL files in ~/Library/Documents/**
3. **Check if the specific filename exists in that list**
4. **Return true/false based on file existence**

### FilesManagementProvider Implementation

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/FilesManagementProvider.swift`

**Lines 63-74:**
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

### FileDirectory Enum (Lines 11-28)

```swift
enum FileDirectory {
    case cache
    case documents
    case recorders

    var url: URL? {
        switch self {
        case .cache:
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        case .documents:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        case .recorders:
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        }
    }
}
```

**Current Storage Location:** `~/Library/Documents/` (changed from `~/Library/Caches/`)

---

## Architecture: Two-Tier Download Tracking System

### Tier 1: ContentRepository Registry (Persistent)

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Repositories/ContentRepository.swift`

**In-Memory Storage (Lines 44-46):**
```swift
private var downloadedGemaraLessons: [SederId:[MasechetId:Set<JTGemaraLesson>]] = [:]
private var downloadedMasechetGemaraLessons: [MasechetId:Set<JTGemaraLesson>] = [:]
private var downloadedMishnaLessons: [SederId:[MasechetId:[Chapter:Set<JTMishnaLesson>]]] = [:]
```

**Persistent Storage (Lines 75-82):**
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

**Purpose:**
- Tracks which lessons are "supposed to be" downloaded
- Organizes downloads by Seder → Masechet → Lesson hierarchy
- Persists to `~/Documents/downloadedLessons.json`
- Used by Downloads UI to show the downloads list

### Tier 2: File System State (Runtime)

**What JTLesson Properties Check:**
- Actual file existence in `~/Documents/`
- No cached state
- No stored flags
- Pure file system query

**Purpose:**
- Real-time verification of file availability
- Used by UI to show/hide download buttons
- Used by player to determine local vs remote playback

---

## Data Flow: Download Lifecycle

### 1. Download Initiated

**File:** `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Network/DownloadTask.swift`

**Lines 51-101:**
```swift
private func downloadFileFromS3(file: (...)) {
    // Use Documents directory instead of Caches for persistent storage
    guard let documentsURL = FileDirectory.documents.url else {
        self.filesFailedDownloading += 1
        // ... error handling
        return
    }

    let destinationURL = documentsURL.appendingPathComponent(file.localFileName)

    AWSS3Provider.shared.handleFileDownloadToURL(
        fileName: file.fileName,
        bucketName: AWSS3Provider.appS3BucketName,
        destinationURL: destinationURL,
        progressBlock: { (_ fileName: String, _ progress: Progress) in
            self.filesDownloadProgress[fileName] = (progress.completedUnitCount, progress.totalUnitCount)
            if self.filesDownloadProgress.keys.count == self.filesToDownload.count {
                self.updateProgress()
            }
        }
    ) { (result: Result<URL, Error>) in
        switch result {
        case .success(let url):
            print("✅ Download success: \(url.path)")
            self.filesDownloadedSuccessfully += 1
        case .failure(let error):
            print("❌ Download failed: \(error.localizedDescription)")
            // Retry logic...
        }

        if self.filesDownloadedSuccessfully + self.filesFailedDownloading == self.filesToDownload.count {
            self.downloadComplete()
        }
    }
}
```

**Files downloaded directly to:** `~/Documents/{lessonId}_aud.mp3` or `{lessonId}_vid.mp4`

### 2. Download Completed

**ContentRepository.swift - Lines 1026-1056:**
```swift
extension ContentRepository: DownloadTaskDelegate {

    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType, success: Bool) {
        self.lessonEndedDownloading(downloadId, mediaType: mediaType)

        if let (lesson,sederId,masechetId,chapter) = self.getLessonFromLocalStorage(withId: downloadId) {
            switch mediaType {
            case .audio:
                lesson.audioDownloadProgress = 0.0
                lesson.isDownloadingAudio = false
            case .video:
                lesson.videoDownloadProgress = 0.0
                lesson.isDownloadingVideo = false
            }

            if success {
                // Add to registry
                if let gemaraLesson = lesson as? JTGemaraLesson {
                    self.addLessonToDownloaded(gemaraLesson, sederId: sederId, masechetId: masechetId)
                }
                if let mishnaLesson = lesson as? JTMishnaLesson, let _chapter = chapter {
                    self.addLessonToDownloaded(mishnaLesson, sederId: sederId, masechetId: masechetId, chapter: _chapter)
                }
            }
        }

        // Notify delegates (UI updates)
        DispatchQueue.main.async {
            for delegate in self.downloadDelegates {
                delegate.downloadCompleted(downloadId: downloadId, mediaType: mediaType)
            }
        }
    }
}
```

**Result:**
1. ✅ File saved to `~/Documents/{lessonId}_{type}.{ext}`
2. ✅ Lesson added to ContentRepository registry
3. ✅ Registry persisted to `~/Documents/downloadedLessons.json`
4. ✅ Delegates notified (UI refreshes)

### 3. Runtime Status Check

**When UI needs to show download status:**

```swift
// In LessonDownloadCellController.swift (Lines 53-76)
func setProgressViewButtons(_ lesson: JTLesson) {
    if lesson.isAudioDownloaded {  // ← Queries file system!
        self.downloadAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "audio-downloaded"), ...)
    } else {
        self.downloadAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "downloadAudio"), ...)
    }

    if lesson.isVideoDownloaded {  // ← Queries file system!
        self.downloadVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "video-downloaded"), ...)
    } else {
        self.downloadVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "downloadVideo"), ...)
    }
}
```

**Each access triggers:**
1. `FilesManagementProvider.shared.filesList(.documents)`
2. `FileManager.default.contentsOfDirectory(at: documentsURL, ...)`
3. List all files in Documents directory
4. Check if `{lessonId}_aud.mp3` or `{lessonId}_vid.mp4` exists

---

## Potential Sources of Inconsistency

### 1. Registry-File Mismatch (CRITICAL)

**Scenario:**
- Registry says lesson is downloaded (in `downloadedLessons.json`)
- But actual file is missing from `~/Documents/`

**Causes:**
- User deletes files manually via Files app
- iOS system cleanup (though Documents should be safe)
- Migration issues from Caches to Documents
- Incomplete download that updated registry but failed file write
- App crash during download

**Result:**
- Downloads UI shows lesson in list (registry says it exists)
- But `lesson.isAudioDownloaded` returns `false` (file doesn't exist)
- UI may show conflicting states or broken buttons

**This is the exact issue described in user report:**
> "I have downloaded a lot of classes even that the files were deleted"

### 2. Performance Overhead

**Issue:** Computed properties query file system on EVERY access

```swift
// Bad: Multiple file system queries in tight loop
for lesson in lessons {
    if lesson.isAudioDownloaded {  // Query 1
        // ...
    }
    if lesson.isVideoDownloaded {  // Query 2
        // ...
    }
}
```

**Impact:**
- Listing directory contents is expensive (O(n) where n = total files)
- Called during table view cell rendering
- Can cause UI lag if many cells rendered at once
- Each property access lists ALL files in Documents

**Current Mitigation:** None - relies on iOS file system caching

### 3. Race Conditions During Download

**Scenario:**
1. Download starts → DownloadTask begins writing file
2. UI checks `lesson.isAudioDownloaded` during download
3. File is partially written → `filesList()` might or might not see it
4. Download completes → registry updated
5. UI shows wrong state until next refresh

**Mitigations in place:**
- `lesson.isDownloadingAudio` flag (lines 29-30 in JTLesson.swift)
- Progress tracking via delegates
- UI uses these flags to show progress instead of download status

### 4. Migration Issues (Caches → Documents)

**Historical Context:**
- Old code saved to `~/Library/Caches/`
- New code saves to `~/Library/Documents/`
- Comments indicate recent migration (lines 90, 96, 102, 134, 139, 144)

**Migration Code:** ContentRepository.swift Lines 1166-1365

**Potential Issue:**
- If migration incomplete or failed
- Old files in Caches, new checks in Documents
- Registry might reference non-existent files

**Solution Implemented:**
- `migrateDownloadsFromCachesToDocuments()` runs on first launch
- `UserDefaultsProvider.shared.hasCompletedDownloadsCacheToDocumentsMigration` flag
- Moves files and cleans orphaned entries

### 5. File Naming Collisions

**Potential Issue:**
If two different lesson types (Gemara vs Mishna) have same ID:

```swift
// Both would generate same filename
gemaraLesson.id = 123 → "123_aud.mp3"
mishnaLesson.id = 123 → "123_aud.mp3"
```

**Risk:** Low (IDs likely globally unique across lesson types)

**Evidence:** No prefix by type in filename generation (lines 148-158)

---

## Registry vs File System: When They're Used

### ContentRepository Registry Used For:

1. **Downloads UI List** (Lines 321-355)
   ```swift
   func getDownloadedGemaraLessons() -> [JTSederDownloadedGemaraLessons]
   func getDownloadedMishnaLessons() -> [JTSederDownloadedMishnaLessons]
   ```
   - Determines WHICH lessons appear in Downloads screen
   - Organizes by Seder → Masechet → Lesson hierarchy
   - Source of truth for "user downloaded this lesson"

2. **Download Tracking** (Lines 421-458)
   ```swift
   func getLessonDownloadProgress(_ lessonId: Int, mediaType: JTLessonMediaType) -> Float?
   func lessonStartedDownloading(_ lessonId: Int, mediaType: JTLessonMediaType)
   func lessonEndedDownloading(_ lessonId: Int, mediaType: JTLessonMediaType)
   ```
   - Tracks in-progress downloads
   - Manages download state transitions

3. **Manual Deletion** (Lines 590-633)
   ```swift
   func removeLessonFromDownloaded(_ lesson: JTGemaraLesson, sederId: String, masechetId: String)
   ```
   - Removes from registry
   - Deletes actual files
   - Updates persistent storage

### File System State Used For:

1. **Download Button Display** (LessonDownloadCellController.swift Lines 51-83)
   - Show "downloaded" icon vs "download" icon
   - Enable/disable download buttons
   - Determine if file can be played locally

2. **Playback URL Selection** (JTLesson.swift Lines 160-177)
   ```swift
   var audioURL: URL? {
       if self.isAudioDownloaded {
           return self.audioLocalURL
       } else {
           return self.audioRemoteURL
       }
   }
   ```
   - Choose local file vs remote stream
   - Critical for offline playback

3. **File Cleanup Validation** (ContentRepository.swift Lines 494-565)
   ```swift
   func removeOldDownloadedFiles() {
       // Check if files exist before removing from registry
   }
   ```
   - Validates file existence before cleanup
   - Removes registry entries for missing files

---

## Synchronization Mechanism: refreshDownloadsList()

**File:** ContentRepository.swift Lines 1375-1475

**Purpose:** Fix registry-file mismatches by scanning actual file system

### Algorithm

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

    // Same logic for Mishna...

    // Remove orphaned entries from registry
    for item in orphanedGemara {
        removeGemaraLessonFromArray(item.lesson, sederId: item.sederId, masechetId: item.masechetId)
    }

    for item in orphanedMishna {
        removeMishnaLessonFromArray(item.lesson, sederId: item.sederId, masechetId: item.masechetId, chapter: item.chapter)
    }

    // Persist updated registry
    if !orphanedGemara.isEmpty || !orphanedMishna.isEmpty {
        updateDownloadedLessonsStorage()
        print("✅ Removed \(orphanedGemara.count + orphanedMishna.count) orphaned download entries")
    } else {
        print("✅ No orphaned downloads found")
    }
}
```

### When It's Called

1. **Manual Trigger:** Long-press Downloads title for 2 seconds (DownloadsViewController.swift Lines 196-246)
2. **Automatic Trigger:** Every time Downloads screen appears (Lines 136-177)
3. **Migration:** During Caches→Documents migration cleanup (Lines 1166-1258)

### What It Does

✅ **Removes "ghost" entries** - Lessons in registry but files missing
✅ **Preserves partial downloads** - Keeps lesson if ANY file exists (audio OR video)
✅ **Updates persistent storage** - Saves corrected registry to JSON
✅ **Logs all actions** - Console output for debugging

### What It Does NOT Do

❌ **Does not re-download** - Only removes registry entries
❌ **Does not fix file system** - Only fixes registry
❌ **Does not add missing entries** - Only removes orphaned ones
❌ **Does not validate file integrity** - Only checks existence

---

## File Path Computation

### From Lesson ID to File Path

**Example: Lesson ID 2813**

```swift
// 1. Generate filename
lesson.audioLocalFileName // → "2813_aud.mp3"

// 2. Get Documents directory
FileDirectory.documents.url // → "file:///Users/.../Library/Application%20Support/.../Documents/"

// 3. Append filename
audioLocalURL = documentsURL.appendingPathComponent("2813_aud.mp3")
// → "file:///Users/.../Documents/2813_aud.mp3"

// 4. Check existence
let filesNames = FilesManagementProvider.shared.filesList(.documents) // → ["2813_aud.mp3", "2813_vid.mp4", ...]
let isDownloaded = filesNames.contains("2813_aud.mp3") // → true
```

### URL Properties (JTLesson.swift Lines 112-146)

```swift
private var audioRemoteURL: URL? {
    guard let link = self.audioLink else { return nil }
    var fullLink = "\(AWSS3Provider.appS3BaseUrl)\(link)"
    fullLink = fullLink.replacingOccurrences(of: " ", with: "%20")
    return URL(string: fullLink)
}

private var audioLocalURL: URL? {
    // Changed from .cache to .documents to match new download location
    return FileDirectory.documents.url?.appendingPathComponent(self.audioLocalFileName)
}

var audioURL: URL? {
    if self.isAudioDownloaded {  // ← File system check happens here
        return self.audioLocalURL  // Local file
    } else {
        return self.audioRemoteURL  // Remote stream
    }
}
```

**Critical:** `audioURL` uses `isAudioDownloaded` which queries file system!

---

## Inheritance: JTGemaraLesson and JTMishnaLesson

### JTGemaraLesson (JTGemaraLesson.swift)

```swift
class JTGemaraLesson: JTLesson {
    var page: Int
    // Inherits all download properties from JTLesson
}
```

### JTMishnaLesson (JTMishnaLesson.swift)

```swift
class JTMishnaLesson: JTLesson {
    var mishna: Int
    // Inherits all download properties from JTLesson
}
```

**Finding:** Both subclasses inherit the same download status implementation from `JTLesson`

**Implications:**
- No type-specific logic for download status
- Both use same file naming pattern (just lesson ID)
- Both check same Documents directory
- Same potential for inconsistency

---

## Summary: Key Findings

### Architecture

1. **Two-Tier System:**
   - **Registry (ContentRepository)** → Tracks "should be downloaded" (persistent JSON)
   - **File System (JTLesson properties)** → Tracks "actually downloaded" (computed)

2. **No Caching:**
   - Download status is NOT cached
   - Every property access queries file system
   - No stored flags in model objects

3. **Direct File System Queries:**
   - `FilesManagementProvider.shared.filesList()` lists entire Documents directory
   - Computed properties search this list for specific filename
   - Performance scales with total files in Documents

### Potential Issues

1. **Registry-File Mismatch** (User-Reported Issue)
   - Registry has entry, file missing
   - Causes "ghost" downloads in UI
   - **Solution:** `refreshDownloadsList()` removes orphaned entries

2. **Performance Overhead**
   - File system query on every property access
   - Can lag with many downloads
   - **Mitigation:** iOS file system caching, small file counts

3. **Race Conditions**
   - Download in progress, UI checks status
   - File partially written or not yet visible
   - **Mitigation:** `isDownloadingAudio/Video` flags

4. **Migration Complexity**
   - Changed from Caches to Documents
   - Requires one-time migration
   - **Solution:** `migrateDownloadsFromCachesToDocuments()`

### Design Decisions

**Why Computed Properties Instead of Cached State?**

✅ **Pros:**
- Always reflects actual file system state
- No stale data issues
- Simple implementation
- Self-healing if files deleted externally

❌ **Cons:**
- Performance overhead
- No notification when state changes
- Multiple queries for same lesson

**Why Separate Registry and File Checks?**

✅ **Pros:**
- Registry provides UI structure (Seder → Masechet → Lesson)
- File checks provide actual availability
- Can detect and fix mismatches
- Clear separation of concerns

❌ **Cons:**
- Can get out of sync
- Complexity of maintaining two sources of truth
- Requires manual sync via `refreshDownloadsList()`

---

## Recommendations

### For Fixing Current Issues

1. **Run validation automatically:**
   - Call `refreshDownloadsList()` on app launch
   - Call on Downloads screen appearance (already implemented)
   - Remove orphaned entries proactively

2. **Add file integrity checks:**
   - Validate file size matches expected
   - Check file can be opened/read
   - Validate media file headers

3. **Improve error handling:**
   - Show alert when orphaned entries found
   - Offer to re-download missing files
   - Log discrepancies for debugging

### For Performance

1. **Cache file list:**
   ```swift
   private var cachedFilesList: [String]?
   private var cacheTimestamp: Date?

   var isAudioDownloaded: Bool {
       if let cached = cachedFilesList,
          let timestamp = cacheTimestamp,
          Date().timeIntervalSince(timestamp) < 5.0 {
           return cached.contains(self.audioLocalFileName)
       }

       guard let filesNames = FilesManagementProvider.shared.filesList(.documents) else { return false }
       cachedFilesList = filesNames
       cacheTimestamp = Date()
       return filesNames.contains(self.audioLocalFileName)
   }
   ```

2. **Use FileManager.fileExists for individual checks:**
   ```swift
   var isAudioDownloaded: Bool {
       guard let url = audioLocalURL else { return false }
       return FileManager.default.fileExists(atPath: url.path)
   }
   ```
   - More efficient for single file checks
   - Doesn't list entire directory

### For Long-Term Architecture

1. **Add state change notifications:**
   ```swift
   // When file downloaded or deleted
   NotificationCenter.default.post(name: .lessonDownloadStateChanged, object: lessonId)
   ```

2. **Implement download state cache:**
   - Store last-known state in memory
   - Invalidate on file operations
   - Background validation queue

3. **Add registry integrity checks:**
   - Periodic validation job
   - Log discrepancies to analytics
   - Auto-fix common issues

---

## Files Reference

**Model Files:**
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTLesson.swift` (Lines 89-99, 148-158)
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTGemaraLesson.swift`
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTMishnaLesson.swift`

**Repository:**
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Repositories/ContentRepository.swift` (Lines 44-46, 75-82, 321-355, 459-492, 590-633, 1375-1475)

**File Management:**
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Services/FilesManagementProvider.swift` (Lines 11-28, 63-74, 111-120)

**Download Task:**
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Network/DownloadTask.swift` (Lines 51-101, 116-146)

**UI Controllers:**
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/DownloadsViewController.swift`
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Cells/LessonDownloadCellController.swift` (Lines 51-83)

**Documentation:**
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/DOWNLOADS_UI_SYNC_SOLUTION.md`
- `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/DOWNLOADS_UI_ARCHITECTURE.md`

---

## Conclusion

The `isAudioDownloaded` and `isVideoDownloaded` properties are **computed properties that directly query the file system** on every access. They do NOT rely on stored state or cached values. This design ensures they always reflect the actual file system state, but creates potential for registry-file mismatches and performance overhead.

The ContentRepository maintains a separate registry for organizing downloads in the UI, which can get out of sync with actual files. The `refreshDownloadsList()` method exists specifically to fix these mismatches by removing orphaned registry entries.

The recent migration from Caches to Documents storage adds complexity but ensures downloaded files persist across app launches and system cleanups. The automatic validation on Downloads screen appearance (implemented recently) proactively fixes registry-file inconsistencies.

**Key Takeaway:** Understanding that these are computed file system queries (not stored flags) is critical when debugging download issues or implementing features that depend on download status.
