import Foundation
#if canImport(CoreData)
import CoreData

public extension NSPersistentStoreCoordinator {
    /// Adds a persistent store using the provided description.
    ///
    /// - parameters:
    ///   - description: A description object used to create and load a persistent store.
    @discardableResult func addPersistentStore(with description: NSPersistentStoreDescription) async throws -> NSPersistentStoreDescription {
        try await withCheckedThrowingContinuation { continuation in
            addPersistentStore(with: description) { storeDescription, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: storeDescription)
                }
            }
        }
    }
    
    /// Causes the write-ahead log to be integrated into the primary sqlite table.
    static func checkpoint(storeAtURL url: URL, model: NSManagedObjectModel, name: String) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
        let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: name, at: url, options: options)
        try coordinator.remove(store)
    }
}
#endif
