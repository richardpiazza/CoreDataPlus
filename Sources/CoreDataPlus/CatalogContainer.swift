import Foundation
#if canImport(CoreData)
import CoreData

public class CatalogContainer<Catalog: ModelCatalog> {
    
    public let persistentContainer: NSPersistentContainer
    /// Model version used by the `Container`
    public let version: Catalog.Version
    /// Underlying storage mechanism used by the `Container`
    public let persistence: Persistence
    /// The name used by the `Container`
    public let name: String
    /// When a migration occurs, the source version will be listed here.
    public let migrationSource: Catalog.Version?
    
    /// Initializes the `NSPersistentContainer` with a specified `Model` version.
    ///
    /// If an existing store exists at the default URL, a _heavyweight_ migration will be performed. If
    /// `silentMigrationFailure` is true, than any existing store will be removed if failure is due to:
    /// * `CoreDataPlusError.migrationSource`
    /// * `CoreDataPlusError.migrationPath`
    ///
    /// - parameters:
    ///   - version: The `ModelVersion` with which to initialize (or migrate) the container.
    ///   - persistence: Controls the underlying storage mechanism.
    ///   - name: The name used by the persistent container.
    ///   - silentMigration: When enabled, some migration errors will fall back to a clean state.
    public init(
        version: Catalog.Version,
        persistence: Persistence,
        name: String,
        silentMigration: Bool = true
    ) throws {
        self.version = version
        self.persistence = persistence
        self.name = name
        
        if case let .store(storeURL) = persistence {
            let migrator = Migrator<Catalog>()
            do {
                migrationSource = try migrator.migrateStore(at: storeURL, to: version, configurationName: name)
            } catch let error as CoreDataPlusError {
                switch error {
                case .migrationSource, .migrationPath:
                    if silentMigration {
                        if FileManager.default.fileExists(atPath: storeURL.rawValue.path) {
                            try FileManager.default.removeItem(at: storeURL.rawValue)
                        }
                        migrationSource = nil
                    } else {
                        throw error
                    }
                default:
                    throw error
                }
            }
        } else {
            migrationSource = nil
        }
        
        persistentContainer = NSPersistentContainer(name: name, managedObjectModel: version.managedObjectModel)
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = false
        description.shouldMigrateStoreAutomatically = false
        switch persistence {
        case .store(let storeURL):
            description.type = storeURL.storeType
            description.url = storeURL.rawValue
        case .memory:
            description.type = NSInMemoryStoreType
        }
        
        persistentContainer.persistentStoreDescriptions = [description]
        
        var loadError: Error? = nil
        // `loadPersistentStores` seems like it should be an asyncronous call, but…
        // see `NSPersistentStoreDescription.shouldAddStoreAsynchronously`.
        persistentContainer.loadPersistentStores { (_, error) in
            loadError = error
        }
        
        if let error = loadError {
            throw error
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        persistentContainer.viewContext.undoManager = nil
    }
}

public extension CatalogContainer {
    /// The path to the first persistent store.
    var path: String? {
        persistentContainer.persistentStoreCoordinator.persistentStores.first?.url?.path
    }
    
    /// Causes the write-ahead log to be integrated into the primary sqlite table.
    ///
    /// **WARNING**: The persistent container stores will be re-added, and all existing object references will become invalid.
    func checkpointAndContinue() async throws {
        try await checkpoint(reopen: true)
        persistentContainer.viewContext.refreshAllObjects()
    }
    
    /// Causes the write-ahead log to be integrated into the primary sqlite table.
    func checkpointAndClose() async throws {
        try await checkpoint(reopen: false)
    }
}

private extension CatalogContainer {
    func checkpoint(reopen: Bool) async throws {
        guard case .store(let storeURL) = persistence else {
            return
        }
        
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        
        let coordinator = persistentContainer.persistentStoreCoordinator
        let descriptions = persistentContainer.persistentStoreDescriptions
        let stores = coordinator.persistentStores
        for store in stores {
            try coordinator.remove(store)
        }
        
        try NSPersistentStoreCoordinator.checkpoint(storeAtURL: storeURL.rawValue, model: version.managedObjectModel, name: name)
        
        guard reopen else {
            return
        }
        
        for description in descriptions {
            try await coordinator.addPersistentStore(with: description)
        }
    }
}
#endif
