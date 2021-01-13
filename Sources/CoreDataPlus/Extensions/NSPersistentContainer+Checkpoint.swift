import Foundation
#if canImport(CoreData)
import CoreData

public extension NSPersistentStoreCoordinator {
    /// Causes the write-ahead log to be integrated into the primary sqlite table.
    static func checkpoint(storeAtURL url: URL, model: NSManagedObjectModel, name: String) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
        let store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: name, at: url, options: options)
        try coordinator.remove(store)
    }
}

#endif
