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
            return "No URL for Resource '\(resource)' in Bundle '\(path)'."
        case .resourceContents(let type, let path):
            return "Unable to load contents of \(type) at path '\(path)'."
        case .migrationSource(let store):
            return "No compatible Catalog Version found for store '\(store)'."
        case .migrationPath(let source, let destination):
            return "No path found for migration from '\(source)' to '\(destination)'."
        case .migrationMapping(let source, let destination):
            return "No mapping found for migration from '\(source)' to '\(destination)'."
        }
    }
    
    @available(*, deprecated, renamed: "resourceNotFound(_:bundlePath:)")
    public static func notFound(_ resource: String, _ bundle: Bundle) -> CoreDataPlusError {
        resourceNotFound(resource, bundlePath: bundle.bundlePath)
    }
    
    @available(*, deprecated, renamed: "resourceContents(_:path:)")
    public static func contents(_ type: Any.Type, _ path: String) -> CoreDataPlusError {
        resourceContents(String(describing: type), path: path)
    }
}

extension CoreDataPlusError: CustomNSError {
    public static var errorDomain: String { "CoreDataPlusErrorDomain" }
    
    public var errorCode: Int {
        switch self {
        case .resourceNotFound: return 1
        case .resourceContents: return 2
        case .migrationSource: return 3
        case .migrationPath: return 4
        case .migrationMapping: return 5
        }
    }
    
    public var errorUserInfo: [String : Any] {
        switch self {
        case .resourceNotFound(let resource, let bundlePath):
            return [
                "resource": resource,
                "bundlePath": bundlePath
            ]
        case .resourceContents(let resource, let path):
            return [
                "resource": resource,
                "path": path
            ]
        case .migrationSource(let store):
            return [
                "store": store
            ]
        case .migrationPath(let source, let destination):
            return [
                "source": source,
                "destination": destination
            ]
        case .migrationMapping(let source, let destination):
            return [
                "source": source,
                "destination": destination
            ]
        }
    }
}
