import Foundation
#if canImport(CoreData)
import CoreData

public extension NSPersistentContainer {
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
#endif
