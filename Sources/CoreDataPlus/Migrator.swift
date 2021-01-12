import Foundation
#if canImport(CoreData)
import CoreData

public struct Migrator<Catalog: ModelCatalog> {
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
        
        let metadata = try NSPersistentStoreCoordinator
            .metadataForPersistentStore(ofType: storeURL.storeType, at: storeURL.rawValue, options: nil)
        if destinationModel.isConfiguration(withName: configurationName, compatibleWithStoreMetadata: metadata) {
            // The store is already consistent with the destination version.
            return nil
        }
        
        guard let source = Catalog.versionCompatibleWith(metadata: metadata, configurationName: configurationName) else {
            throw Error.unidentifiedSource
        }
        
        guard Catalog.pathExists(from: source, to: destination) else {
            throw Error.noMigrationPath
        }
        
        let sourceModel = source.managedObjectModel
        try checkpoint(storeAtURL: storeURL, model: sourceModel, configurationName: configurationName)
        
        let tempURL: URL = storeURL.temporaryStoreURL.rawValue
        let storeType = storeURL.storeType
        
        let steps = try migrationSteps(from: source, to: destination)
        for step in steps {
            let source = step.source.managedObjectModel
            let destination = step.destination.managedObjectModel
            let manager = NSMigrationManager(sourceModel: source, destinationModel: destination)
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: .init())
            try manager.migrateStore(from: storeURL.rawValue, sourceType: storeType, options: nil, with: step.mapping, toDestinationURL: tempURL, destinationType: storeType, destinationOptions: nil)
            try coordinator.destroyPersistentStore(at: storeURL.rawValue, ofType: storeType, options: nil)
            try coordinator.replacePersistentStore(at: storeURL.rawValue, destinationOptions: nil, withPersistentStoreFrom: tempURL, sourceOptions: nil, ofType: storeType)
            try FileManager.default.removeItem(at: tempURL)
        }
        
        return source
    }
}

private extension Migrator {
    func checkpoint(storeAtURL url: StoreURL, model: NSManagedObjectModel, configurationName: String) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
        let store = try coordinator.addPersistentStore(ofType: url.storeType, configurationName: configurationName, at: url.rawValue, options: options)
        try coordinator.remove(store)
    }
    
    func migrationSteps(from: Catalog.Version, to: Catalog.Version) throws -> [Step] {
        var steps: [Step] = []
        
        guard from.id != to.id else {
            return steps
        }
        
        var current: Catalog.Version = from
        while let next = Catalog.versionAfter(current) {
            guard let mapping = next.mappingModel else {
                throw Error.mapping(source: current, destination: next)
            }
            
            steps.append(Step(source: current, destination: next, mapping: mapping))
            
            guard next.id != to.id else {
                return steps
            }
            
            current = next
        }
        
        return steps
    }
}
#endif
