import Foundation
#if canImport(CoreData)
import CoreData

public class CatalogContainer<Catalog: ModelCatalog, Container: NSPersistentContainer> {
    public enum Persistence {
        /// `NSSQLiteStoreType`
        case store(_ storeURL: StoreURL)
        /// `NSInMemoryStoreType`
        case memory
    }
    
    public let persistentContainer: Container
    public let version: Catalog.Version
    /// When a migration occurs, the source version will be listed here.
    public let migrationSource: Catalog.Version?
    
    /// Initializes the `NSPersistentContainer` with a specified `Model` version.
    ///
    /// If an existing store exists at the default URL, a _heavyweight_ migration will be performed. If
    /// `silentMigrationFailure` is true, than any existing store will be removed if failure is due to:
    /// * `Migration.Error.noMigrationPath`
    /// * `Migration.Error.unidentifiedSource`
    ///
    /// - parameter version: The `ModelVersion` with which to initialize (or migrate) the container.
    /// - parameter persistence: Controls the underlying storage mechanism.
    /// - parameter name: The name used by the persistent container.
    /// - parameter silentMigration: When enabled, some migration errors will fall back to a clean state.
    public init(version: Catalog.Version, persistence: Persistence, name: String, silentMigration: Bool = true) throws {
        self.version = version
        
        if case let .store(storeURL) = persistence {
            let migrator = Migrator<Catalog>()
            do {
                migrationSource = try migrator.migrateStore(at: storeURL, to: version, configurationName: name)
            } catch let error as Migrator<Catalog>.Error {
                switch error {
                case .noMigrationPath, .unidentifiedSource:
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
        
        persistentContainer = Container(name: name, managedObjectModel: version.managedObjectModel)
        
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
        
        var loadError: Error? = nil
        
        persistentContainer.persistentStoreDescriptions = [description]
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
    var path: String? {
        persistentContainer.persistentStoreCoordinator.persistentStores.first?.url?.path
    }
    
    /// Removed all stores from the `persistentStoreCoordinator`
    ///
    /// **WARNING**: The container & related context will be un-usable until a store has been reloaded.
    func unload() throws {
        for store in persistentContainer.persistentStoreCoordinator.persistentStores {
            try persistentContainer.persistentStoreCoordinator.remove(store)
        }
    }
}
#endif
