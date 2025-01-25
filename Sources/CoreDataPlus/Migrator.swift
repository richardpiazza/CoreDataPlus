import Foundation
import Logging
#if canImport(CoreData)
import CoreData

public struct Migrator<Catalog: ModelCatalog> {
    @available(*, deprecated, message: "Use `CoreDataPlusError`.")
    public enum Error: Swift.Error {
        case resource(name: String)
        case load(url: URL)
        case unidentifiedSource
        case noMigrationPath
        case mapping(source: Catalog.Version, destination: Catalog.Version)
    }
    
    struct Step {
        let source: Catalog.Version
        let destination: Catalog.Version
        let mapping: NSMappingModel
    }
    
    @discardableResult
    public func migrateStore(at storeURL: StoreURL, to destination: Catalog.Version, configurationName: String) throws -> Catalog.Version? {
        guard FileManager.default.fileExists(atPath: storeURL.rawValue.path) else {
            return nil
        }
        
        let destinationModel = destination.managedObjectModel
        
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: storeURL.storeType,
            at: storeURL.rawValue,
            options: nil
        )
        
        if destinationModel.isConfiguration(withName: configurationName, compatibleWithStoreMetadata: metadata) {
            // The store is already consistent with the destination version.
            return nil
        }
        
        guard let source = Catalog.versionCompatibleWith(metadata: metadata, configurationName: configurationName) else {
            Logger.coreDataPlus.error("No Source Version", metadata: [
                "storeUrl": .stringConvertible(storeURL),
                "configurationName": .string(configurationName),
                "destination": .string(destination.id),
            ])
            throw CoreDataPlusError.migrationSource(storeURL.rawValue.absoluteString)
        }
        
        guard Catalog.pathExists(from: source, to: destination) else {
            Logger.coreDataPlus.error("No Migration Path", metadata: [
                "storeUrl": .stringConvertible(storeURL),
                "configurationName": .string(configurationName),
                "source": .string(source.id),
                "destination": .string(destination.id),
            ])
            throw CoreDataPlusError.migrationPath(source: source.id, destination: destination.id)
        }
        
        let sourceModel = source.managedObjectModel
        try NSPersistentStoreCoordinator.checkpoint(storeAtURL: storeURL.rawValue, model: sourceModel, name: configurationName)
        
        let tempURL: URL = storeURL.temporaryStoreURL.rawValue
        let storeType = storeURL.storeType
        
        let steps = try migrationSteps(from: source, to: destination)
        for step in steps {
            let source = step.source.managedObjectModel
            let destination = step.destination.managedObjectModel
            let manager = NSMigrationManager(
                sourceModel: source,
                destinationModel: destination
            )
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: .init())
            try manager.migrateStore(
                from: storeURL.rawValue,
                sourceType: storeType,
                options: nil,
                with: step.mapping,
                toDestinationURL: tempURL,
                destinationType: storeType,
                destinationOptions: nil
            )
            try coordinator.destroyPersistentStore(
                at: storeURL.rawValue,
                ofType: storeType,
                options: nil
            )
            try coordinator.replacePersistentStore(
                at: storeURL.rawValue,
                destinationOptions: nil,
                withPersistentStoreFrom: tempURL,
                sourceOptions: nil,
                ofType: storeType
            )
            try FileManager.default.removeItem(at: tempURL)
        }
        
        return source
    }
}

private extension Migrator {
    func migrationSteps(from: Catalog.Version, to: Catalog.Version) throws -> [Step] {
        var steps: [Step] = []
        
        guard from.id != to.id else {
            return steps
        }
        
        var current: Catalog.Version = from
        while let next = Catalog.versionAfter(current) {
            guard let mapping = next.mappingModel else {
                Logger.coreDataPlus.error("Invalid Migration Mapping", metadata: [
                    "from": .string(from.id),
                    "to": .string(to.id)
                ])
                throw CoreDataPlusError.migrationMapping(source: current.id, destination: next.id)
            }
            
            steps.append(
                Step(
                    source: current,
                    destination: next,
                    mapping: mapping
                )
            )
            
            guard next.id != to.id else {
                return steps
            }
            
            current = next
        }
        
        return steps
    }
}
#endif
