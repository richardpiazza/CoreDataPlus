import Foundation
#if canImport(CoreData)
import CoreData

public struct StoreURL: RawRepresentable {
    public let rawValue: URL
    public let storeType = NSSQLiteStoreType

    public init?(rawValue: URL) {
        guard rawValue.pathExtension.lowercased().hasSuffix(FileExtension.sqlite.rawValue) else {
            return nil
        }

        self.rawValue = rawValue
    }

    public init(currentDirectory resource: String, fileManager: FileManager = .default) {
        let directory = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let path = "\(resource).\(FileExtension.sqlite.rawValue)"
        rawValue = URL(fileURLWithPath: path, relativeTo: directory)
    }

    public init(applicationSupport resource: String, folder: String, fileManager: FileManager = .default) throws {
        let root: URL
        #if os(tvOS)
        root = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        #else
        root = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        #endif

        let directory = root.appendingPathComponent(folder, isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let path = "\(resource).\(FileExtension.sqlite.rawValue)"
        rawValue = URL(fileURLWithPath: directory.appendingPathComponent(path).path)
    }
}

extension StoreURL: CustomStringConvertible {
    public var description: String {
        "\(String(describing: storeType)) - \(rawValue)"
    }
}

public extension StoreURL {
    /// The sql store _shared memory_ url.
    var shmURL: URL {
        rawValue.deletingPathExtension().appendingPathExtension(FileExtension.sqliteSharedMemory.rawValue)
    }

    /// The sql store _write-ahead-log_ url.
    var walURL: URL {
        rawValue.deletingPathExtension().appendingPathExtension(FileExtension.sqliteWriteAheadLog.rawValue)
    }

    /// The current URL with the '_temp" suffix.
    var temporaryStoreURL: StoreURL {
        let name = rawValue.deletingPathExtension().lastPathComponent
        let url = rawValue
            .deletingLastPathComponent()
            .appendingPathComponent("\(name)\(ResourceSuffix.temporary.rawValue)")
            .appendingPathExtension(FileExtension.sqlite.rawValue)
        guard let storeURL = StoreURL(rawValue: url) else {
            preconditionFailure("Unable to generate temporary store url.")
        }
        return storeURL
    }

    /// Removes the underlying SQL store and related files.
    func destroy(using fileManager: FileManager = .default) throws {
        if fileManager.fileExists(atPath: rawValue.path) {
            try fileManager.removeItem(at: rawValue)
        }
        if fileManager.fileExists(atPath: shmURL.path) {
            try fileManager.removeItem(at: shmURL)
        }
        if fileManager.fileExists(atPath: walURL.path) {
            try fileManager.removeItem(at: walURL)
        }
    }
}
#endif
