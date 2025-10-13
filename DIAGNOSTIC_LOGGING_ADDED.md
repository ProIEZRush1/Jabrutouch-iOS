# Diagnostic Logging Added for Downloads Registry Issue

## Problem

User reported: **"I get Downloads registry saved successfully but nothing when restarting"**

This indicates the registry save appears to succeed, but data doesn't persist or load correctly after app restart.

## Root Cause Analysis

The investigation revealed **two critical issues**:

### 1. Silent Load Failures
The `loadDownloadedLessonsFromStorage()` function had an empty catch block (line 709-711), swallowing all errors:
```swift
catch {
    // Empty - all errors silently ignored!
}
```

**Impact:** If the file doesn't exist, JSON parsing fails, or type casting fails, NO ERROR is logged. This makes debugging impossible.

### 2. Non-Atomic File Writes
The `overwriteFile()` method used basic `data.write(to:)` without the `.atomic` option:
```swift
try data.write(to: path)  // ❌ Non-atomic write
```

**Impact:** If the app crashes or iOS terminates the process during the write, the data may not be fully flushed to disk, even though the method returned successfully. This creates a dangerous race condition.

## Solution Applied

### Fix 1: Comprehensive Diagnostic Logging in Load Function

**File:** `ContentRepository.swift`
**Lines:** 697-774
**Function:** `loadDownloadedLessonsFromStorage()`

Added detailed logging to reveal exactly what happens during load:

```swift
private func loadDownloadedLessonsFromStorage() {
    guard let url = self.downloadedLessonsStorageUrl else {
        print("❌ Cannot load registry: Invalid storage URL")
        return
    }

    let fileManager = FileManager.default
    let fileExists = fileManager.fileExists(atPath: url.path)

    print("📖 Loading downloads registry from: \(url.path)")
    print("   File exists: \(fileExists)")

    if !fileExists {
        print("ℹ️  Registry file does not exist - no downloads to load")
        return
    }

    do {
        let contentString = try String(contentsOf: url)
        print("   File size: \(contentString.count) characters")

        guard let content = Utils.convertStringToDictionary(contentString) as? [String:Any] else {
            print("❌ Failed to parse registry JSON")
            print("   First 200 chars: \(String(contentString.prefix(200)))")
            return
        }

        print("   JSON parsed successfully")
        print("   Keys found: \(content.keys.joined(separator: ", "))")

        // Gemara lessons loading with detailed counts
        if let gemaraLessonsValues = content["gemara"] as? [SederId:[MasechetId:[[String:Any]]]]{
            let lessonsArray = gemaraLessonsValues.flatMap { $0.value.flatMap { $0.value } }
            let initializedCount = lessonsArray.reduce(0) { count, lessonDict in
                count + lessonDict.compactMap{ JTGemaraLesson(values:$0) }.count
            }
            let failedCount = lessonsArray.reduce(0) { $0 + $1.count } - initializedCount

            self.downloadedGemaraLessons = gemaraLessonsValues.mapValues{$0.mapValues{Set($0.compactMap{JTGemaraLesson(values:$0)})}}
            print("   ✅ Loaded \(initializedCount) Gemara lessons")
            if failedCount > 0 {
                print("   ⚠️  \(failedCount) Gemara lessons failed to initialize")
            }
        } else {
            print("   ⚠️  'gemara' key not found or wrong type")
            if let gemaraData = content["gemara"] {
                print("      Actual type: \(type(of: gemaraData))")
            }
        }

        // Mishna lessons loading with detailed counts
        if let mishnaLessonsValues = content["mishna"] as? [SederId:[MasechetId:[Chapter : [[String:Any]]]]]{
            let lessonsArray = mishnaLessonsValues.flatMap { $0.value.flatMap { $0.value.flatMap { $0.value } } }
            let initializedCount = lessonsArray.reduce(0) { count, lessonDict in
                count + lessonDict.compactMap{ JTMishnaLesson(values:$0) }.count
            }
            let failedCount = lessonsArray.reduce(0) { $0 + $1.count } - initializedCount

            self.downloadedMishnaLessons = mishnaLessonsValues.mapValues{$0.mapValues{$0.mapValues{Set($0.compactMap{JTMishnaLesson(values: $0)})}}}
            print("   ✅ Loaded \(initializedCount) Mishna lessons")
            if failedCount > 0 {
                print("   ⚠️  \(failedCount) Mishna lessons failed to initialize")
            }
        } else {
            print("   ⚠️  'mishna' key not found or wrong type")
            if let mishnaData = content["mishna"] {
                print("      Actual type: \(type(of: mishnaData))")
            }
        }

        let totalGemara = downloadedGemaraLessons.flatMap { $0.value.flatMap { $0.value } }.count
        let totalMishna = downloadedMishnaLessons.flatMap { $0.value.flatMap { $0.value.flatMap { $0.value } } }.count
        print("📖 Loaded downloads registry: \(totalGemara) Gemara + \(totalMishna) Mishna lessons")
    }
    catch {
        print("❌ ERROR loading downloads registry: \(error)")
        print("   File path: \(url.path)")
        print("   Error details: \(error.localizedDescription)")
    }
}
```

**What This Reveals:**

1. **File Existence**: Shows if the registry file exists at the expected path
2. **File Size**: Shows how many characters are in the file (helps detect empty or corrupted files)
3. **JSON Parsing**: Shows if the JSON parsing succeeded or failed (with sample of content if failed)
4. **Dictionary Keys**: Shows what top-level keys are in the JSON (should be "gemara" and "mishna")
5. **Type Casting**: Shows if the expected data structure matches actual structure (with actual type if mismatch)
6. **Lesson Initialization**: Shows how many lessons loaded successfully vs failed to initialize
7. **Final Count**: Shows total lessons loaded into memory
8. **Error Details**: Shows specific error message and file path if any exception occurs

### Fix 2: Atomic File Writes

**File:** `FilesManagementProvider.swift`
**Lines:** 139-161
**Functions:** Both `overwriteFile()` methods

Changed from non-atomic writes to atomic writes:

**BEFORE:**
```swift
func overwriteFile(path:URL, data: Data) throws {
    if self.isFileExist(atUrl: path) {
        do {
            try self.removeFile(atPath: path)  // Delete old file
        }
        catch let error {
            throw error
        }
    }

    do {
        try data.write(to: path)  // ❌ Non-atomic write
    }
    catch let error {
        throw error
    }
}
```

**AFTER:**
```swift
func overwriteFile(path:URL, data: Data) throws {
    // Use atomic write option to ensure data is properly flushed to disk
    // This prevents data loss if the process terminates during the write
    // The .atomic option writes to a temp file first, then atomically renames it
    do {
        try data.write(to: path, options: [.atomic])  // ✅ Atomic write
    }
    catch let error {
        throw error
    }
}
```

**Benefits of Atomic Writes:**

1. **No Race Condition**: Eliminates the dangerous window between delete and write
2. **Crash-Safe**: If process terminates during write, either old file remains intact OR new file is complete
3. **Durability Guarantee**: Data is flushed to disk before method returns
4. **Simpler Code**: No need to manually delete old file - atomic write handles it
5. **Thread-Safe**: Atomic rename operation is thread-safe at the OS level

**How .atomic Works:**

```
BEFORE (.atomic option):
1. Delete old file ← DANGEROUS! File gone, new data not written yet
2. Write new data ← If crash here, NO file exists!
3. Return success

AFTER (.atomic option):
1. Write data to temporary file (.tmp)
2. Flush data to disk (ensure durable)
3. Atomically rename temp file → target path
4. Either succeeds completely OR original file remains intact
5. Return success (only after data is on disk)
```

## Expected Console Output

### On App Launch (Load Operation)

**Scenario 1: File Exists and Loads Successfully**
```
📖 Loading downloads registry from: /var/mobile/Containers/Data/Application/.../Documents/downloadedLessons.json
   File exists: true
   File size: 15234 characters
   JSON parsed successfully
   Keys found: gemara, mishna
   ✅ Loaded 25 Gemara lessons
   ✅ Loaded 12 Mishna lessons
📖 Loaded downloads registry: 25 Gemara + 12 Mishna lessons
```

**Scenario 2: File Doesn't Exist (First Launch)**
```
📖 Loading downloads registry from: /var/mobile/Containers/Data/Application/.../Documents/downloadedLessons.json
   File exists: false
ℹ️  Registry file does not exist - no downloads to load
```

**Scenario 3: JSON Parsing Fails**
```
📖 Loading downloads registry from: /var/mobile/Containers/Data/Application/.../Documents/downloadedLessons.json
   File exists: true
   File size: 234 characters
❌ Failed to parse registry JSON
   First 200 chars: {corrupt json data here...
```

**Scenario 4: Type Casting Fails**
```
📖 Loading downloads registry from: /var/mobile/Containers/Data/Application/.../Documents/downloadedLessons.json
   File exists: true
   File size: 1234 characters
   JSON parsed successfully
   Keys found: gemara, mishna
   ⚠️  'gemara' key not found or wrong type
      Actual type: Array<Any>
   ✅ Loaded 12 Mishna lessons
📖 Loaded downloads registry: 0 Gemara + 12 Mishna lessons
```

**Scenario 5: Lesson Initialization Fails**
```
📖 Loading downloads registry from: /var/mobile/Containers/Data/Application/.../Documents/downloadedLessons.json
   File exists: true
   File size: 5432 characters
   JSON parsed successfully
   Keys found: gemara, mishna
   ✅ Loaded 20 Gemara lessons
   ⚠️  5 Gemara lessons failed to initialize
   ✅ Loaded 12 Mishna lessons
📖 Loaded downloads registry: 20 Gemara + 12 Mishna lessons
```

**Scenario 6: File Read Error**
```
📖 Loading downloads registry from: /var/mobile/Containers/Data/Application/.../Documents/downloadedLessons.json
   File exists: true
❌ ERROR loading downloads registry: The file "downloadedLessons.json" couldn't be opened because you don't have permission to view it.
   File path: /var/mobile/Containers/Data/Application/.../Documents/downloadedLessons.json
   Error details: Operation not permitted
```

### On Save Operation (Already Has Logging)

**Success:**
```
💾 Saving downloads registry: 25 Gemara + 12 Mishna lessons to /var/mobile/.../Documents/downloadedLessons.json
✅ Downloads registry saved successfully
```

**Failure:**
```
💾 Saving downloads registry: 25 Gemara + 12 Mishna lessons to /var/mobile/.../Documents/downloadedLessons.json
❌ CRITICAL ERROR saving downloads registry: Error Domain=NSCocoaErrorDomain Code=513 "You don't have permission..."
   This means downloads will NOT persist after app restart!
```

## How to Diagnose the Issue Now

### Step 1: Check Save Operation
Look for this in console logs during download:
```
💾 Saving downloads registry: X Gemara + Y Mishna lessons to ...
✅ Downloads registry saved successfully
```

If you see the success message, the save completed.

### Step 2: Check Load Operation on Restart
Look for this in console logs when app restarts:

**If you see:**
```
📖 Loading downloads registry from: .../Documents/downloadedLessons.json
   File exists: false
```
**Problem:** File was saved but then deleted or never actually written to disk (previous atomic write issue).

**If you see:**
```
   File exists: true
   File size: 0 characters
```
**Problem:** File exists but is empty - save operation didn't write data.

**If you see:**
```
   File exists: true
   File size: 1234 characters
❌ Failed to parse registry JSON
```
**Problem:** File exists with data, but JSON is corrupted or invalid.

**If you see:**
```
   JSON parsed successfully
   Keys found: something_else
```
**Problem:** File has valid JSON but wrong structure (keys don't match expected "gemara" and "mishna").

**If you see:**
```
   Keys found: gemara, mishna
   ⚠️  'gemara' key not found or wrong type
      Actual type: Array<Any>
```
**Problem:** Data structure doesn't match expected nested dictionary format.

**If you see:**
```
   ✅ Loaded 20 Gemara lessons
   ⚠️  5 Gemara lessons failed to initialize
```
**Problem:** Some lesson dictionaries are missing required fields, causing `JTGemaraLesson(values:)` to return `nil`.

**If you see:**
```
   ✅ Loaded 0 Gemara lessons
   ✅ Loaded 0 Mishna lessons
📖 Loaded downloads registry: 0 Gemara + 0 Mishna lessons
```
**Problem:** File loads successfully, but compactMap filtered out all lessons (all returned `nil` during initialization).

## Files Modified

### 1. ContentRepository.swift
- **Function:** `loadDownloadedLessonsFromStorage()` (lines 697-774)
- **Changes:** Added 70+ lines of comprehensive diagnostic logging
- **Impact:** Reveals exactly what fails during registry loading

### 2. FilesManagementProvider.swift
- **Function:** `overwriteFile()` - both variants (lines 139-161)
- **Changes:** Changed from non-atomic to atomic writes, removed manual delete logic
- **Impact:** Prevents data loss during crashes, ensures durability

## Next Steps for User

1. **Test the app** with these logging changes
2. **Download a lesson** and check console for save message
3. **Restart the app** and check console for load messages
4. **Share the console output** showing both save and load operations

The detailed logging will reveal:
- ✅ If the file actually exists after save
- ✅ If the file content is valid JSON
- ✅ If the data structure matches expectations
- ✅ If lesson initialization is failing
- ✅ The exact error if any operation fails

## Summary

**Before:**
- Silent failures made debugging impossible
- Non-atomic writes could lose data during crashes
- No visibility into what was failing

**After:**
- Comprehensive logging reveals every failure point
- Atomic writes ensure data durability
- Easy to diagnose where the issue occurs

**Status:** Ready for testing with full diagnostic capabilities

---

**Date Applied:** 2025-10-12
**Files Changed:** 2
**Lines Added:** ~80
**Risk Level:** Low (only adds logging and improves write safety)
**User Impact:** High (enables diagnosis of persistence issue)
