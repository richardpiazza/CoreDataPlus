import Foundation
#if canImport(CoreData)
import CoreData

public protocol ModelVersion {
    var id: String { get }
    var managedObjectModel: NSManagedObjectModel { get }
    /// The directly preceding model version
    var previousVersion: ModelVersion? { get }
    /// Mappings needed to migrate from the 'previous' version of the model.
    var mappingModel: NSMappingModel? { get }
}

public extension ModelVersion {
    var previousVersion: ModelVersion? { nil }
    var mappingModel: NSMappingModel? { nil }
}

public extension ModelVersion where Self: RawRepresentable, Self.RawValue == String {
    var id: String { rawValue }
}
#endif
