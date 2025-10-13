# Download Registry Synchronization Analysis

## Executive Summary

Analysis of ContentRepository download tracking reveals a **critical architecture gap**: the system uses TWO separate mechanisms to track downloads, which can become desynchronized, causing files to exist but not appear in the Downloads UI.

## Two Parallel Download Detection Systems

### System 1: File-Based Detection (JTLesson.swift)
**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTLesson.swift`

```swift
// Lines 89-109
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
    for fileName in filesNames {
        if fileName == self.textLocalFileName {
            return true
        }
    }
    return false
}
```

**How it works**:
- Directly checks if files exist in Documents directory
- Used by UI cells to show download icons
- **No dependency on registry**

### System 2: Registry-Based Tracking (ContentRepository.swift)
**Location**: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Repositories/ContentRepository.swift`

```swift
// Lines 44-46
private var downloadedGemaraLessons: [SederId:[MasechetId:Set<JTGemaraLesson>]] = [:]
private var downloadedMasechetGemaraLessons: [MasechetId:Set<JTGemaraLesson>] = [:]
private var downloadedMishnaLessons: [SederId:[MasechetId:[Chapter:Set<JTMishnaLesson>]]] = [:]
```

**How it works**:
- Maintains in-memory dictionaries of downloaded lessons
- Persisted to `downloadedLessons.json` in Documents
- Used by Downloads UI to populate the list
- **Files can exist without registry entries**

---

## Download Flow Analysis

### Complete Download Path (NORMAL CASE)

**Step 1: User initiates download**
- User taps download button in lesson cell
- `LessonDownloadCellController.swift` line 93-98: Calls delegate method

**Step 2: Download execution**
- `ContentRepository.downloadLesson()` line 636-650: Creates DownloadTask
- `DownloadTask.execute()` line 35-49: Initiates file downloads
- `DownloadTask.downloadFileFromS3()` line 51-101: Downloads to Documents directory

**Step 3: Download completion**
- `DownloadTask.downloadComplete()` line 116-146: Notifies delegate
- `ContentRepository.downloadCompleted()` line 1026-1056: Processes completion
- **CRITICAL LINE 1039/1042**: Calls `addLessonToDownloaded()` to update registry

**Step 4: Registry update**
- `ContentRepository.addLessonToDownloaded()` line 459-472 (Gemara) / 474-492 (Mishna)
- Adds lesson to in-memory dictionary
- **CRITICAL LINE 471/491**: Calls `updateDownloadedLessonsStorage()`
- Registry file is saved to disk

### Where Synchronization Can Break

#### Gap 1: Download Success but Registry Update Fails

**Scenario**: File download succeeds but registry save fails

**Code path**:
```swift
// ContentRepository.swift line 1037-1043
if success {
    if let gemaraLesson = lesson as? JTGemaraLesson {
        self.addLessonToDownloaded(gemaraLesson, sederId: sederId, masechetId: masechetId)
    }
    if let mishnaLesson = lesson as? JTMishnaLesson, let _chapter = chapter {
        self.addLessonToDownloaded(mishnaLesson, sederId: sederId, masechetId: masechetId, chapter: _chapter)
    }
```

**Failure points**:
1. `updateDownloadedLessonsStorage()` line 777-823 could fail during JSON serialization
2. `saveContentToFile()` line 988-1001 could fail during file write
3. `FilesManagementProvider.shared.overwriteFile()` could fail due to disk space/permissions

**Evidence**: Log statements show registry saves can fail:
```swift
// Line 819-821
catch {
    print("❌ CRITICAL ERROR saving downloads registry: \(error)")
    print("   This means downloads will NOT persist after app restart!")
}
```

**Result**: File exists in Documents, but lesson not in registry → **ORPHANED FILE**

#### Gap 2: App Termination During Download

**Scenario**: App crashes or is killed after file download but before registry update

**Critical window**:
```swift
// DownloadTask.swift line 73-99
case .success(let url):
    print("✅ Download success: \(url.path)")
    self.filesDownloadedSuccessfully += 1
    // ... file is saved but registry not yet updated

if self.filesDownloadedSuccessfully + self.filesFailedDownloading == self.filesToDownload.count {
    self.downloadComplete() // ← Registry update happens here
}
```

**Result**: File persists in Documents, but registry never updated → **ORPHANED FILE**

#### Gap 3: Retry Logic Creates Files Without Registry

**Code**: `DownloadTask.swift` line 81-90
```swift
if retryCount < self.maxRetries {
    self.fileRetryCount[file.fileName] = retryCount + 1
    print("🔄 Retrying download (\(retryCount + 1)/\(self.maxRetries)): \(file.fileName)")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        self.downloadFileFromS3(file: file)
    }
    return
}
```

**Issue**: If a file partially downloads, fails, then succeeds on retry, but the lesson object state is not properly maintained, registry update might be skipped.

#### Gap 4: Legacy/Migrated Files

**Migration code**: `ContentRepository.swift` line 1166-1258

The migration from Cache to Documents might have left files in Documents without adding them to the registry if:
1. Files existed in Documents before migration ran
2. Migration completed but app crashed before registry was saved
3. Migration's orphan cleanup had bugs

#### Gap 5: Manual File Restoration

**Scenario**: User restores backup or manually copies files to Documents directory

Files appear in Documents but registry doesn't know about them → **ORPHANED FILES**

---

## How UI Detects Downloads

### Lesson List Cells (Show download icons)
**Code**: `LessonDownloadCellController.swift` line 51-76

```swift
func setProgressViewButtons(_ lesson: JTLesson) {
    if lesson.isAudioDownloaded {  // ← Uses file-based detection
        self.downloadAudioPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "audio-downloaded"))
        // ...
    }
    if lesson.isVideoDownloaded {  // ← Uses file-based detection
        self.downloadVideoPBWB.setButtonImage(NormalImage: #imageLiteral(resourceName: "video-downloaded"))
        // ...
    }
}
```

**Result**: Download icons show correctly because they check files directly

### Downloads Screen (Shows downloaded lessons list)
**Code**: `DownloadsViewController.swift` line 285-287

```swift
fileprivate func setContent(openSections: Bool = false) {
    self.gemaraDownloads = ContentRepository.shared.getDownloadedGemaraLessons()
    self.mishnaDownloads = ContentRepository.shared.getDownloadedMishnaLessons()
}
```

**Code**: `ContentRepository.swift` line 321-336 / 338-354
```swift
func getDownloadedGemaraLessons() -> [JTSederDownloadedGemaraLessons] {
    var downloadedLessons:[JTSederDownloadedGemaraLessons] = []
    for (sederId,masechtotDict) in self.downloadedGemaraLessons {  // ← Uses registry
        // ...builds list from in-memory registry
    }
    return downloadedLessons
}
```

**Result**: Downloads list only shows lessons in registry, missing orphaned files

---

## The Critical Divergence

### What Users See:

1. **In Lesson List**: ✅ Downloaded icon showing (file exists)
2. **In Downloads Screen**: ❌ Lesson missing (not in registry)

### Why This Happens:

```
┌─────────────────────────────────────────┐
│         Download Initiated              │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│    File Downloaded to Documents         │ ← SUCCESS
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│   Registry Update Called                │
└────────────────┬────────────────────────┘
                 │
                 ├─ SUCCESS → Registry synced ✅
                 │
                 ├─ FAILURE → Registry not synced ❌ (ORPHAN)
                 │
                 └─ APP CRASH → Registry not synced ❌ (ORPHAN)
```

---

## Current Mitigation: refreshDownloadsList()

**Location**: `ContentRepository.swift` line 1375-1475

**What it does**:
```swift
func refreshDownloadsList() {
    // 1. Check each lesson in registry
    // 2. Verify files exist in Documents
    // 3. If NO files exist → Remove from registry
    // 4. Save updated registry
}
```

**Critical limitation**: It ONLY removes orphaned registry entries, does NOT add missing entries

**Code evidence**: Lines 1415-1418, 1451-1454
```swift
if !hasAnyFile {
    orphanedGemara.append((lesson, sederId, masechetId))
    print("🧹 Found orphaned Gemara lesson: \(lesson.id)")
}
```

Then removes from registry (lines 1461-1467), but **never scans Documents for files not in registry**.

---

## The Missing Feature: Registry Sync

### What's NOT Implemented:

**"Discover and Register Downloaded Files"**

A function that would:
```swift
func syncRegistryWithFiles() {
    // 1. Scan Documents directory for all lesson files
    // 2. Parse filenames to identify lesson IDs
    // 3. Look up lesson metadata from gemaraLessons/mishnaLessons
    // 4. For each file found NOT in registry:
    //    - Add lesson to downloadedGemaraLessons/downloadedMishnaLessons
    // 5. Save updated registry
}
```

**Why this doesn't exist**:
- Original design assumed download flow always completes atomically
- Migration code was added later but only moves files, doesn't scan for existing ones
- `refreshDownloadsList()` was added to clean orphans, not discover them

---

## Evidence from Codebase

### 1. Registry Load at Startup
`ContentRepository.swift` line 698-775: Loads registry but never validates against files

### 2. No File Discovery on Startup
`ContentRepository.init()` line 101-110: Only loads stored data, never scans Documents

### 3. Migration Focuses on Moving, Not Discovering
`ContentRepository.migrateDownloadsFromCachesToDocuments()` line 1166-1258:
- Iterates through registry entries and moves their files
- Cleans up orphaned registry entries
- But never scans Documents for unregistered files

### 4. Refresh Only Cleans, Never Discovers
`ContentRepository.refreshDownloadsList()` line 1375-1475:
```swift
// Lines 1391-1418: Check files for each registry entry
for (sederId, masechtotDict) in downloadedGemaraLessons {
    for (masechetId, lessons) in masechtotDict {
        for lesson in lessons {
            var hasAnyFile = false
            // Check if files exist...
            if !hasAnyFile {
                orphanedGemara.append((lesson, sederId, masechetId))
            }
        }
    }
}
// Lines 1461-1467: Remove orphaned entries
for item in orphanedGemara {
    removeGemaraLessonFromArray(item.lesson, sederId: item.sederId, masechetId: item.masechetId)
}
```

**Direction is ONLY**: Registry → Files (cleanup)
**Missing direction**: Files → Registry (discovery)

---

## Why Files Exist But Not in Registry: Summary

### Root Causes (In Order of Likelihood):

1. **Registry Save Failure After Successful Download** (Most Common)
   - File saves successfully via AWSS3Provider streaming
   - Registry update fails due to JSON serialization or disk write error
   - File persists, registry entry lost

2. **App Termination Between Download and Registry Update**
   - iOS kills app for memory pressure
   - User force quits app during download
   - File saved but registry update never runs

3. **Migration Edge Cases**
   - Files already in Documents before migration
   - Migration ran but didn't add pre-existing files to registry
   - Migration completed file moves but crashed before registry save

4. **Legacy Data from Old App Versions**
   - Old cache-based system had different registry location
   - Files migrated but registry not fully synchronized

5. **Manual File Restoration** (Rare)
   - User restored from backup
   - Files copied manually to Documents

### Technical Architecture Issue:

The system violates the **Single Source of Truth** principle:

- **File system** = Source of truth for "file exists"
- **Registry** = Source of truth for "lesson is downloaded"
- These can diverge, creating inconsistent state

### Why refreshDownloadsList() Doesn't Fix This:

It's designed as a **cleanup tool**, not a **sync tool**:
- Removes lessons from registry when files are missing ✅
- Does NOT add lessons to registry when files exist but entry missing ❌

---

## Recommended Solutions

### Solution 1: Add File Discovery to Registry Sync (Recommended)

Add reverse sync capability to `refreshDownloadsList()`:

```swift
func refreshDownloadsList() {
    // PHASE 1: Existing cleanup (remove orphaned registry entries)
    // ... existing code ...

    // PHASE 2: NEW - Discovery (add missing registry entries)
    discoverAndRegisterDownloadedFiles()
}

private func discoverAndRegisterDownloadedFiles() {
    // 1. Get all files in Documents directory
    // 2. Parse filenames to get lesson IDs and media types
    // 3. Look up full lesson data from gemaraLessons/mishnaLessons
    // 4. For each file NOT in registry:
    //    - Add lesson to downloadedGemaraLessons/downloadedMishnaLessons
    // 5. Save updated registry
}
```

### Solution 2: Make Registry Update Atomic with Download

Wrap file download + registry update in a transaction:

```swift
func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType, success: Bool) {
    guard success else { return }

    // Get lesson data
    guard let (lesson, sederId, masechetId, chapter) = getLessonFromLocalStorage(withId: downloadId) else {
        return
    }

    // Try to add to registry IMMEDIATELY, with retry on failure
    do {
        if let gemaraLesson = lesson as? JTGemaraLesson {
            try addLessonToDownloadedWithRetry(gemaraLesson, sederId: sederId, masechetId: masechetId)
        } else if let mishnaLesson = lesson as? JTMishnaLesson, let _chapter = chapter {
            try addLessonToDownloadedWithRetry(mishnaLesson, sederId: sederId, masechetId: masechetId, chapter: _chapter)
        }
    } catch {
        // Registry update failed - mark file for discovery on next sync
        logOrphanedDownload(downloadId, error: error)
    }
}
```

### Solution 3: Periodic Background Sync

Add automatic sync in `DownloadsViewController.viewWillAppear()`:

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Existing code...

    // NEW: Automatic registry sync with file discovery
    validateAndSyncDownloads()
}

private func validateAndSyncDownloads() {
    DispatchQueue.global(qos: .utility).async {
        // Run full bidirectional sync
        ContentRepository.shared.refreshDownloadsList() // cleanup
        ContentRepository.shared.discoverAndRegisterDownloadedFiles() // discovery

        DispatchQueue.main.async {
            self.setContent(openSections: false)
        }
    }
}
```

### Solution 4: Make File System the Single Source of Truth

**Radical approach**: Eliminate registry entirely, query files directly:

- Remove `downloadedGemaraLessons` / `downloadedMishnaLessons` dictionaries
- `getDownloadedGemaraLessons()` scans Documents and builds list on-the-fly
- Pros: Never out of sync, simpler architecture
- Cons: Performance impact, harder to maintain metadata

---

## File Paths Reference

### Critical Files:

1. **ContentRepository.swift**
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Repositories/ContentRepository.swift`
   - Registry update: Lines 459-492
   - Registry save: Lines 777-823
   - Registry load: Lines 698-775
   - Refresh (cleanup): Lines 1375-1475
   - Migration: Lines 1166-1258

2. **JTLesson.swift**
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Content/Domain Models/JTLesson.swift`
   - File detection: Lines 89-109
   - Local URLs: Lines 133-146

3. **DownloadTask.swift**
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/App/Models/Network/DownloadTask.swift`
   - Download execution: Lines 35-101
   - Completion callback: Lines 116-146

4. **DownloadsViewController.swift**
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/DownloadsViewController.swift`
   - Content loading: Lines 285-304
   - Background validation: Lines 148-177

5. **LessonDownloadCellController.swift**
   - Path: `/Users/ech/Documents/Programacion/jabrutouch/jabrutouch_ios/Jabrutouch/Controller/Main/Cells/LessonDownloadCellController.swift`
   - Download icon display: Lines 51-83

---

## Testing Strategy

### To Reproduce Orphaned File Issue:

1. **Force registry save failure**:
   ```swift
   // In ContentRepository.saveContentToFile(), add:
   throw JTError.unableToConvertDictionaryToString
   ```

2. **Kill app during download**:
   - Start download of large video file
   - Force quit app when progress is at 90%
   - Restart app, file may exist but not in registry

3. **Inspect registry directly**:
   ```bash
   cd ~/Library/Developer/CoreSimulator/Devices/[DEVICE]/data/Containers/Data/Application/[APP]/Documents/
   cat downloadedLessons.json | jq .
   ls -la *.mp4 *.mp3 *.pdf
   ```

### To Test File Discovery Solution:

1. Manually create a lesson file in Documents:
   ```swift
   let lesson = JTGemaraLesson(...)
   let filePath = FileDirectory.documents.url?.appendingPathComponent(lesson.audioLocalFileName)
   // Copy or create file at filePath
   ```

2. Run `refreshDownloadsList()` with discovery enabled

3. Verify lesson appears in Downloads UI

---

## Conclusion

The iOS app has a **dual-tracking system** where files and registry can become desynchronized. The current `refreshDownloadsList()` function only performs one-way cleanup (registry → files) but lacks reverse discovery (files → registry).

**Files can exist without registry entries** due to:
- Registry save failures after successful downloads
- App termination during the download completion window
- Migration edge cases
- Legacy data inconsistencies

**The fix requires bidirectional sync**: both cleaning orphaned registry entries AND discovering unregistered files.
