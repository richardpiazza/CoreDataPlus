import Foundation
import Logging

public enum CoreDataPlusError: Error {
    case resourceNotFound(_ resource: String, bundlePath: String)
    case resourceContents(_ type: String, path: String)
    case migrationSource(_ store: String)
    case migrationPath(source: String, destination: String)
    case migrationMapping(source: String, destination: String)

    public var errorDescription: String? {
        switch self {
        case .resourceNotFound(let resource, let path):
            "No URL for Resource '\(resource)' in Bundle '\(path)'."
        case .resourceContents(let type, let path):
            "Unable to load contents of \(type) at path '\(path)'."
        case .migrationSource(let store):
            "No compatible Catalog Version found for store '\(store)'."
        case .migrationPath(let source, let destination):
            "No path found for migration from '\(source)' to '\(destination)'."
        case .migrationMapping(let source, let destination):
            "No mapping found for migration from '\(source)' to '\(destination)'."
        }
    }
}

extension CoreDataPlusError: CustomNSError {
    public static var errorDomain: String { "CoreDataPlusErrorDomain" }

    public var errorCode: Int {
        switch self {
        case .resourceNotFound: 1
        case .resourceContents: 2
        case .migrationSource: 3
        case .migrationPath: 4
        case .migrationMapping: 5
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .resourceNotFound(let resource, let bundlePath):
            [
                "resource": resource,
                "bundlePath": bundlePath,
            ]
        case .resourceContents(let resource, let path):
            [
                "resource": resource,
                "path": path,
            ]
        case .migrationSource(let store):
            [
                "store": store,
            ]
        case .migrationPath(let source, let destination):
            [
                "source": source,
                "destination": destination,
            ]
        case .migrationMapping(let source, let destination):
            [
                "source": source,
                "destination": destination,
            ]
        }
    }
}
