# GKLogger

**GKLogger** is a Swift-based logging utility designed to manage application logs efficiently using CoreData. It allows logging of messages with different severity levels (Debug, Info, Warning, and Error) and supports exporting logs as plain text files. GKLogger ensures logs are persistent and retrievable even after the application restarts.

## Features

- **Logging Levels**: Supports multiple log levels: `.debug`, `.info`, `.warning`, `.error`.
- **CoreData Integration**: Stores logs in CoreData with a managed object model (`GKLogs`).
- **Log Exporting**: Fetches and exports logs to a `.txt` file.
- **Concurrency Support**: Logging operations are performed on background threads for performance.
- **Customizable Log Limit**: Allows setting the limit on the number of logs fetched.
- **OSLog Integration**: Integrates with Apple's `OSLog` for system logging.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Logging Messages](#logging-messages)
  - [Retrieving Logs as Data](#retrieving-logs-as-data)
  - [Exporting Logs to File](#exporting-logs-to-file)
  - [Configuring Log Levels](#configuring-log-levels)
- [CoreData Setup](#coredata-setup)

## Installation

### Requirements

- iOS 14.0+ / macOS 11+ / tvOS 12.0+
- Xcode 11.0+
- Swift 5.0+

## Usage

### Logging Messages

Log messages using various log levels:

```swift
GKLogger.log("This is a debug message", type: .debug)
GKLogger.log("An error occurred while saving", type: .error)
```

### Retrieving Logs as Data

You can retrieve stored logs as a `Data` object in UTF-8 format:

```swift
if let logsData = GKLogger.logsData {
    // Use the logsData here, e.g., save to a file or upload
}
```

You can also set the maximum number of logs to be retrieved by adjusting `logsLimit`:

```swift
GKLogger.logsLimit = 10000
```

### Exporting Logs to File

You can export logs as a `.txt` file:

```swift
GKLogger.logsURL { fileURL in
    guard let fileURL = fileURL else { return }
    // Use the file URL to share or save the file
}
```

### Configuring Log Levels

By default, the log level is set to `.debug`. You can adjust the log level, so only messages at or above the specified level will be logged.

```swift
GKLogger.logLevel = .warning
```

In this example, only messages of level `.warning` and higher (e.g., `.error`) will be logged.

## CoreData Setup

The logger relies on a CoreData model named `GKLogs`. To guarantee the database exists, ensure the CoreData `.momd` model is properly bundled with your project. The `persistentContainer` ensures that the CoreData stack is loaded, and logs are stored reliably.

- CoreData model: `GKLogs.xcdatamodeld`
- Attributes:
  - `date`: Date (Optional)
  - `type`: Int32 (Required)
  - `thread`: String (Optional)
  - `message`: String (Optional)

```swift
private static var persistentContainer: NSPersistentContainer = {
    let bundle = Bundle.module
    let modelURL = bundle.url(forResource: "GKLogs", withExtension: ".momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    let container = NSPersistentContainer(name: "GKLogs", managedObjectModel: model)
    container.loadPersistentStores { (storeDescription, error) in
        if let error = error {
            fatalError("Failed to load Core Data stack: \(error)")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    return container
}()
```

---

**Created by George Kyrylenko on 09.09.2024**
