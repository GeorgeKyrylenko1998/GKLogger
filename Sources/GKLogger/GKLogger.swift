//
//  GKLoger.swift
//
//
//  Created by George Kyrylenko on 09.09.2024.
//

import Foundation
import OSLog
import CoreData

public struct GKLogger {
    public static var logsLimit = 15000
    public static var logsData: Data? {
        let request = GKLog.fetchRequest()
        request.fetchLimit = logsLimit
        let logs = (try? viewContext.fetch(request)) ?? []
        var logstr = buildLogsString(with: logs)
        return (logstr).data(using: .utf8)
    }
    
    public static func logsURL(with completion: @escaping (_: URL?) -> ()) {
        persistentContainer.performBackgroundTask { context in
            let request = GKLog.fetchRequest()
            request.fetchLimit = logsLimit
            request.sortDescriptors = [NSSortDescriptor(keyPath: \GKLog.date, ascending: false)]
            let logs = (try? context.fetch(request)) ?? []
            var logstr = buildLogsString(with: logs)
            completion(logstr.writeStringToFile(fileName: "Logs.txt"))
        }
    }
    
    static func buildLogsString(with logs: [GKLog]) -> String {
        var logstr = ""
        for log in logs {
            let logLevel = LogLevel(rawValue: Int(log.type)) ?? .debug
            logstr += "\n\(log.date ?? Date())\n\(getPrefix(for: logLevel))\n\(log.thread ?? "")\n\(log.message ?? "")"
        }
        return logstr
    }
    
    private static var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle.module
         let modelURL = bundle.url(forResource: "GKLogs", withExtension: ".momd")!
         let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container =
        NSPersistentContainer(name: "GKLogs", managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
    static var viewContext: NSManagedObjectContext = persistentContainer.viewContext
    private static let dispatchGroup = DispatchGroup()
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                       category: "GKLogs")
    
    public static var logLevel: LogLevel = .debug
    
    static public func log(_ text: String,
                    type: LogLevel,
                    _ file: String = #file,
                    _ function: String = #function,
                    line: Int = #line) {
        DispatchQueue.global(qos: .background).async {
            dispatchGroup.wait()
            dispatchGroup.enter()
            let prefix = getPrefix(for: type)
            let debugDescription = getDebugDescription(file: file, function: function, line: line)
            guard isNeedToLog(type: type) else {
                dispatchGroup.leave()
                return
            }
            let log = "\(prefix)\(debugDescription)\(text)\n"
            persistentContainer.performBackgroundTask { context in
                let log = GKLog(context: context)
                log.date = Date()
                log.type = Int32(type.rawValue)
                log.thread = debugDescription
                log.message = text
                try? context.save()
                dispatchGroup.leave()
            }
            switch type {
            case .none:
                logger.trace("\(log)")
            case .debug:
                logger.debug("\(log)")
            case .info:
                logger.info("\(log)")
            case .warning:
                logger.warning("\(log)")
            case .error:
                logger.critical("\(log)")
            }
        }
    }
    
    private static func getPrefix(for type: LogLevel) -> String{
        switch type {
        case .debug:
            return "⚪️ DEBUG: "
        case .info:
            return "🟢 INFO: "
        case .warning:
            return "🟡 WARNING: "
        case .error:
            return "🔴 ERROR: "
        default:
            return ""
        }
    }
    private static func getDebugDescription(file: String, function: String, line: Int) -> String{
        guard logLevel == .debug else {return String()}
        let fileName = getFileName(path: file)
        return "\n🔀\(threadName())\n🗂 '\(fileName)'func '\(function)':\(line)\n📎 "
    }
    
    private static func getFileName(path: String) -> String{
        guard let url = URL(string: path) else {return "None"}
        return url.lastPathComponent
    }
    
    private static func threadName() -> String {
        if Thread.isMainThread {
            return ""
        } else {
            var threadDescription: String = "Thread is \(Thread.current.description)"
            let name = __dispatch_queue_get_label(nil)
            if let dispathQueueLbl = String(cString: name, encoding: .utf8), !dispathQueueLbl.isEmpty{
                threadDescription += "\n🚦 Dispath queue is \(dispathQueueLbl)"
            }
            return threadDescription
        }
    }
    
    private static func isNeedToLog(type: LogLevel) -> Bool{
        return type.rawValue >= logLevel.rawValue
    }
}

public enum LogLevel: Int{
    case debug = 0
    case info
    case warning
    case error
    case none
}
