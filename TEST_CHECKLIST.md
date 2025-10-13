# Downloads Persistence - Test Checklist

## Quick Test Steps

### Step 1: Download a Lesson
- [ ] Open the app
- [ ] Navigate to any Gemara or Mishna lesson
- [ ] Download the lesson (audio or video)
- [ ] Wait for download to complete
- [ ] Check console logs for:
  ```
  💾 Saving downloads registry: X Gemara + Y Mishna lessons
  ✅ Downloads registry saved successfully
  ```

### Step 2: Verify File Locations
- [ ] Check console logs show files saved to `/Documents/` directory
- [ ] **Should NOT see** any errors about `/Library/Caches/`

### Step 3: Restart App
- [ ] Force quit the app (swipe up from app switcher)
- [ ] Relaunch the app
- [ ] Check console logs for:
  ```
  📖 Loading downloads registry from: .../Documents/downloadedLessons.json
     File exists: true
     File size: XXX characters
     JSON parsed successfully
     Keys found: gemara, mishna
     ✅ Loaded X Gemara lessons
     ✅ Loaded Y Mishna lessons
  📖 Loaded downloads registry: X Gemara + Y Mishna lessons
  ```

### Step 4: Verify Downloads Persist
- [ ] Navigate to Downloads screen
- [ ] Downloaded lesson appears in the list
- [ ] Tap the downloaded lesson
- [ ] Lesson plays successfully from local storage

### Step 5: Check for Errors
- [ ] **Should NOT see** any of these errors:
  - ❌ "Error while enumerating files .../Library/Caches/XXX"
  - ❌ "File exists: false" (after successful download)
  - 💾 "Saving downloads registry: 0 Gemara + 0 Mishna lessons" (after load)

## Success Criteria

✅ All checkboxes above are marked
✅ Downloaded lessons persist after app restart
✅ No errors in console about missing files
✅ Downloads screen shows all downloaded lessons
✅ Downloaded lessons are playable

## If Test Fails

1. **Capture Console Output**:
   - Copy the full console output from download through restart
   - Share it for analysis

2. **Check File Locations Manually**:
   - Look for files in simulator/device Documents directory
   - Note which files exist and their sizes

3. **Try Clean Install**:
   - Delete app completely
   - Rebuild and reinstall
   - Test again

4. **Enable Extra Logging**:
   - The diagnostic logging is already enabled
   - Share any error messages or unexpected behavior

## Expected Console Flow

### During Download:
```
[Download starts]
💾 Saving downloads registry: 1 Gemara + 0 Mishna lessons to .../Documents/downloadedLessons.json
   Gemara structure: 1 seders
     Seder X: Y masechtot, Z lessons
   📦 After mapping Gemara: 1 seders
     Seder X: Y masechtot, Z lesson dictionaries
   📄 JSON content size: 445 characters
   📄 JSON preview (first 500 chars): {"gemara":{...
✅ Downloads registry saved successfully
```

### After Restart:
```
[App launches]
📖 Loading downloads registry from: .../Documents/downloadedLessons.json
   File exists: true
   File size: 445 characters
   JSON parsed successfully
   Keys found: gemara, mishna
   ✅ Loaded 1 Gemara lessons
   ✅ Loaded 0 Mishna lessons
📖 Loaded downloads registry: 1 Gemara + 0 Mishna lessons
[No errors about files not found]
[No re-save with 0 lessons]
```

---

**Date:** 2025-10-12
**Status:** Ready for Testing
