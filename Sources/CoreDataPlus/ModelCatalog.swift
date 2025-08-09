import Foundation
#if canImport(CoreData)
import CoreData

public protocol ModelCatalog {
    associatedtype Version: ModelVersion
    /// An ordered collection of all Versions, ranked from oldest to newest.
    static var allVersions: [Version] { get }
}

public extension ModelCatalog {
    static func versionCompatibleWith(metadata: [String: Any], configurationName: String) -> Version? {
        for model in allVersions {
            if model.managedObjectModel.isConfiguration(withName: configurationName, compatibleWithStoreMetadata: metadata) {
                return model
            }
        }
        return nil
    }

    static func versionForStore(_ storeURL: StoreURL, configurationName: String) throws -> Version? {
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL.rawValue,
            options: nil
        )

        return versionCompatibleWith(
            metadata: metadata,
            configurationName: configurationName
        )
    }

    static func versionAfter(_ version: Version) -> Version? {
        allVersions.first(where: { $0.previousVersion?.id == version.id })
    }

    static func indexOf(version: Version) -> Int? {
        allVersions.firstIndex(where: { $0.id == version.id })
    }

    static func pathExists(from: Version, to: Version) -> Bool {
        guard from.id != to.id else {
            return false
        }

        guard let previous = to.previousVersion else {
            return false
        }

        guard let previousVersion = previous as? Self.Version else {
            return false
        }

        guard from.id == previous.id else {
            return pathExists(from: from, to: previousVersion)
        }

        return true
    }
}
#endif
