# NotificationCenter Usage Patterns in JabruTouch iOS

This document describes how the iOS app communicates data updates to UI components, with a focus on patterns we can follow for implementing downloads refresh notifications.

## Overview

The app uses **two primary patterns** for UI synchronization:

1. **NotificationCenter** - For app-wide events (less common)
2. **Delegate Pattern** - For repository data updates (primary pattern)

## Pattern 1: NotificationCenter (App-Wide Events)

### Implementation Location
- Notification names are defined centrally in: `/Jabrutouch/App/Notifications/NotificationsNames.swift`

### Current NotificationCenter Notifications

```swift
// File: NotificationsNames.swift
extension NSNotification.Name {
    static var shasLoaded = Notification.Name(rawValue: "shasLoadedNotification")
    static var failedLoadingShas = Notification.Name(rawValue: "failedLoadingShasNotification")
}
```

### Example: Shas Loading Notification

**Publisher (ContentRepository.swift):**
```swift
private func loadShas() {
    API.getMasechtot { (result: APIResult<GetMasechtotResponse>) in
        DispatchQueue.main.async {
            switch result {
            case .success(let response):
                self.shas = response.shas
                self.updateShasStorage(shas: response.shas)
                NotificationCenter.default.post(name: .shasLoaded, object: nil, userInfo: nil)
            case .failure(let error):
                self.shas = self.loadShasStorage()
                let userInfo: [String:Any] = ["errorMessage": error.message]
                NotificationCenter.default.post(name: .failedLoadingShas, object: nil, userInfo: userInfo)
                break
            }
        }
    }
}
```

**Subscriber (SplashScreenViewController.swift):**
```swift
private func registerForNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.shasLoaded(_:)), name: .shasLoaded, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.failedLoadingShas(_:)), name: .failedLoadingShas, object: nil)
}

@objc func shasLoaded(_ notification: Notification) {
    // Handle successful load
}

@objc func failedLoadingShas(_ notification: Notification) {
    // Handle failure with userInfo
}

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
}
```

### Other NotificationCenter Usage

The app also uses NSNotification.Name with raw values for specific events:
- `"InternetConnect"` / `"InternetNotConnect"` - Network connectivity changes (AppDelegate → MainViewController)
- `"subscribePressed"` - Subscription button pressed (SubscribeViewController → TzedakaViewController)

## Pattern 2: ContentRepositoryDownloadDelegate (Primary Pattern for Downloads)

### Protocol Definition

```swift
protocol ContentRepositoryDownloadDelegate: class {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType)
    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType)
}
```

### How It Works

**ContentRepository as Publisher:**
```swift
class ContentRepository {
    private var downloadDelegates: [ContentRepositoryDownloadDelegate] = []

    func addDelegate(_ delegate: ContentRepositoryDownloadDelegate) {
        self.downloadDelegates.append(delegate)
    }

    func removeDelegate(_ delegate: ContentRepositoryDownloadDelegate) {
        for i in 0..<self.downloadDelegates.count {
            if self.downloadDelegates[i] === delegate {
                self.downloadDelegates.remove(at: i)
                return
            }
        }
    }

    // Called when download completes
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType, success: Bool) {
        // ... update internal state ...

        DispatchQueue.main.async {
            for delegate in self.downloadDelegates {
                delegate.downloadCompleted(downloadId: downloadId, mediaType: mediaType)
            }
        }
    }
}
```

**ViewControllers as Subscribers:**

#### Example 1: DownloadsViewController
```swift
class DownloadsViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setContent(openSections: true)
        ContentRepository.shared.addDelegate(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ContentRepository.shared.removeDelegate(self)
    }
}

extension DownloadsViewController: ContentRepositoryDownloadDelegate {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType) {
        self.setContent()  // Refresh the downloads list
    }

    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType) {
        // Update progress UI
    }
}
```

#### Example 2: MishnaLessonsViewController
```swift
class MishnaLessonsViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setContent()
        ContentRepository.shared.addDelegate(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ContentRepository.shared.removeDelegate(self)
    }
}

extension MishnaLessonsViewController: ContentRepositoryDownloadDelegate {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType) {
        self.syncDownloadData()
        self.tableView.reloadData()
    }

    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType) {
        self.syncDownloadData()
        // Find and update the specific cell
    }
}
```

### Current Delegate Subscribers

The following view controllers implement `ContentRepositoryDownloadDelegate`:
1. **DownloadsViewController** - Shows list of downloaded lessons
2. **GemaraLessonsViewController** - Shows list of Gemara lessons with download buttons
3. **MishnaLessonsViewController** - Shows list of Mishna lessons with download buttons
4. **LessonPlayerViewController** - Lesson player that can trigger downloads

## Lifecycle Management Best Practices

### NotificationCenter Pattern
```swift
// Subscribe in viewWillAppear or viewDidLoad
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(handler), name: .notificationName, object: nil)
}

// Always unsubscribe in viewWillDisappear or deinit
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
}

// Handler must be @objc
@objc func handler(_ notification: Notification) {
    // Handle notification
}
```

### Delegate Pattern
```swift
// Subscribe in viewWillAppear
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    ContentRepository.shared.addDelegate(self)
}

// Always unsubscribe in viewWillDisappear
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    ContentRepository.shared.removeDelegate(self)
}
```

## Recommendations for Downloads Refresh Notification

Based on the existing patterns, here are two approaches:

### Option 1: Use Existing Delegate Pattern (Recommended)

**Pros:**
- Consistent with existing codebase
- Already implemented and working
- Type-safe
- No additional infrastructure needed

**Implementation:**
Since `DownloadsViewController` already implements `ContentRepositoryDownloadDelegate`, it will automatically receive `downloadCompleted()` callbacks when downloads finish. The `setContent()` method already refreshes the downloads list.

**If you need manual refresh notification:**
Add a new method to the existing delegate protocol:
```swift
protocol ContentRepositoryDownloadDelegate: class {
    func downloadCompleted(downloadId: Int, mediaType: JTLessonMediaType)
    func downloadProgress(downloadId: Int, progress: Float, mediaType: JTLessonMediaType)
    func downloadsListDidRefresh()  // NEW
}
```

### Option 2: Add NotificationCenter Notification (If Needed for Global Events)

**Use this if:**
- You need to notify multiple unrelated components
- The event is app-wide (like the shas loading example)
- You need loose coupling between components

**Implementation:**

1. **Define notification name in NotificationsNames.swift:**
```swift
extension NSNotification.Name {
    static var shasLoaded = Notification.Name(rawValue: "shasLoadedNotification")
    static var failedLoadingShas = Notification.Name(rawValue: "failedLoadingShasNotification")
    static var downloadsListRefreshed = Notification.Name(rawValue: "downloadsListRefreshedNotification")  // NEW
}
```

2. **Post notification in ContentRepository:**
```swift
func refreshDownloadsList() {
    // ... existing refresh logic ...

    // Post notification after refresh completes
    NotificationCenter.default.post(name: .downloadsListRefreshed, object: nil, userInfo: nil)
}
```

3. **Subscribe in view controllers:**
```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadsRefresh), name: .downloadsListRefreshed, object: nil)
}

@objc func handleDownloadsRefresh(_ notification: Notification) {
    setContent()
    tableView.reloadData()
}
```

## Special Features: Hidden Refresh Gesture

The `DownloadsViewController` has a hidden refresh feature:
- **Long press (2 seconds) on the title label**
- Triggers `ContentRepository.shared.refreshDownloadsList()`
- Removes orphaned download entries (lessons with no files)
- Shows progress alert and completion message

This feature uses:
```swift
fileprivate func setupRefreshGesture() {
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(titleLongPressed(_:)))
    longPress.minimumPressDuration = 2.0
    titleLabel.isUserInteractionEnabled = true
    titleLabel.addGestureRecognizer(longPress)
}
```

## Summary

| Pattern | Use Case | Current Usage |
|---------|----------|---------------|
| **ContentRepositoryDownloadDelegate** | Download events, progress updates | Primary pattern for all download-related UI updates |
| **NotificationCenter** | App-wide events, initialization | Used for shas loading, network status |
| **Direct method calls** | Immediate UI updates | Used within same view controller or for delegate callbacks |

**For downloads refresh specifically:** The existing `ContentRepositoryDownloadDelegate` pattern is already in place and working. The `DownloadsViewController` already calls `setContent()` in `downloadCompleted()`, which refreshes the entire downloads list. If you need additional refresh triggers, extend the existing delegate protocol rather than adding new NotificationCenter notifications.
