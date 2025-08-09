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
    ///   - version: The `Catalog.Version` with which to initialize (or migrate) the container.
    ///   - persistence: Specify the underlying storage mechanism.
    ///   - name: The name used by the persistent container.
    ///   - silentMigration: When enabled, some migration errors will fall back to a clean state.
    ///   - postSchemaMigration: Optional handler to modify data once a schema version has been applied.
    public init(
        version: Catalog.Version,
        persistence: Persistence,
        name: String,
        silentMigration: Bool = true,
        postSchemaMigration: Migrator<Catalog>.PostSchemaMigrationHandler? = nil
    ) throws {
        self.version = version
        self.persistence = persistence
        self.name = name

        if case let .store(storeURL) = persistence {
            let migrator = Migrator<Catalog>(postSchemaMigrationHandler: postSchemaMigration)
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

        persistentContainer = try NSPersistentContainer(
            name: name,
            version: version,
            persistence: persistence
        )
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
    func checkpointAndContinue() throws {
        try persistentContainer.checkpointAndContinue()
    }

    /// Causes the write-ahead log to be integrated into the primary sqlite table.
    func checkpointAndClose() throws {
        try persistentContainer.checkpointAndClose()
    }
}
#endif
