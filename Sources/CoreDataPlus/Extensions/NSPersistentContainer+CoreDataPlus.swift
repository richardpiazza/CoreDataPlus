import Foundation
#if canImport(CoreData)
import CoreData

public extension NSPersistentContainer {
    convenience init(
        name: String,
        version: ModelVersion,
        persistence: Persistence
    ) throws {
        self.init(
            name: name,
            managedObjectModel: version.managedObjectModel
        )
        
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
        
        persistentStoreDescriptions = [description]
        
        var loadError: Error? = nil
        // `loadPersistentStores` seems like it should be an asynchronous call, but…
        // see `NSPersistentStoreDescription.shouldAddStoreAsynchronously`.
        loadPersistentStores { (_, error) in
            loadError = error
        }
        
        if let error = loadError {
            throw error
        }
        
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        viewContext.undoManager = nil
    }
    
    /// Causes the write-ahead log to be integrated into the primary sqlite table.
    ///
    /// **WARNING**: The persistent container stores will be re-added, and all existing object references will become invalid.
    func checkpointAndContinue() throws {
        try checkpoint(reopen: true)
        let context = viewContext
        context.performAndWait {
            context.refreshAllObjects()
        }
    }
    
    /// Causes the write-ahead log to be integrated into the primary sqlite table.
    func checkpointAndClose() throws {
        try checkpoint(reopen: false)
    }
    
    @discardableResult func loadPersistentStores() async throws -> [NSPersistentStoreDescription] {
        let count = persistentStoreDescriptions.count
        guard count > 0 else {
            throw CocoaError(.persistentStoreOperation)
        }
        
        var descriptions: [NSPersistentStoreDescription] = []
        var resumed = false
        
        return try await withCheckedThrowingContinuation { continuation in
            loadPersistentStores { description, error in
                if resumed {
                    return
                }
                
                if descriptions.count >= count {
                    return
                }
                
                if let error {
                    continuation.resume(throwing: error)
                    resumed = true
                } else {
                    descriptions.append(description)
                    if descriptions.count == count {
                        continuation.resume(returning: descriptions)
                        resumed = true
                    }
                }
            }
        }
    }
}

extension NSPersistentContainer {
    func checkpoint(reopen: Bool) throws {
        for description in persistentStoreDescriptions {
            guard description.type == NSSQLiteStoreType else {
                continue
            }
            
            guard let url = description.url else {
                continue
            }
            
            let context = viewContext
            if context.hasChanges {
                try context.performAndWait {
                    try context.save()
                }
            }
            
            let stores = persistentStoreCoordinator.persistentStores
            for store in stores {
                try persistentStoreCoordinator.remove(store)
            }
            
            try NSPersistentStoreCoordinator.checkpoint(
                storeAtURL: url,
                model: managedObjectModel,
                name: name
            )
            
            guard reopen else {
                continue
            }
            
            // Similar to loadPersistentStores ?
            var addError: Error? = nil
            persistentStoreCoordinator.addPersistentStore(with: description) { _, error in
                addError = error
            }
            
            if let addError {
                throw addError
            }
        }
    }
}
#endif
