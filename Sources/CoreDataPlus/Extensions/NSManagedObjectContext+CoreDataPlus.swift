import Foundation
#if canImport(CoreData)
import CoreData

public extension NSManagedObjectContext {
    /// Inserts a new entity for the specified type.
    ///
    /// When initializing multiple models with duplicate entities, the standard `NSManagedObject.init(context:)` will
    /// have difficulties disambiguating the references. Using `NSEntityDescription.insertNewObject(forEntityName:into:)`
    /// does not have the same problem.
    func make<T>(entityName: String = T.entityName) -> T where T: NSManagedObject {
        performAndWait {
            NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as! T
        }
    }
    
    /// Synchronously performs a fetch request on the context.
    ///
    /// - parameters:
    ///   - request: The typed `NSFetchRequest` to perform
    /// - returns: A collection of fetched entities (or empty)
    func fetchSynchronously<T>(_ request: NSFetchRequest<T>) throws -> [T] {
        try performAndWait {
            try fetch(request)
        }
    }
    
    /// Synchronously performs a fetch request on the context and maps the results using the provided function.
    ///
    /// - parameters:
    ///   - request: The typed `NSFetchRequest` to perform
    ///   - mapping: Function that maps the request type to the output type.
    /// - returns: A collection of entities mapped to a requested type.
    func fetchSynchronously<T, U>(_ request: NSFetchRequest<T>, mapping: (T) -> U) throws -> [U] {
        try performAndWait {
            let fetchResults = try fetch(request)
            return fetchResults.map(mapping)
        }
    }
    
    /// Synchronously maps a context object.
    ///
    /// - parameters:
    ///   - value: a `NSManagedObject` instance.
    ///   - transform: Function that maps the `value` to the output type.
    /// - returns: The mapped result.
    func mapSynchronously<T, U>(_ value: T, _ transform: (T) -> U) -> U {
        performAndWait {
            transform(value)
        }
    }
    
    /// Synchronously performs an operation on the context and optionally saves.
    ///
    /// - parameters:
    ///   - operation: Function block that should be performed on the context.
    ///   - saving: Indicates if a save operation should be attempted after the operation.
    func performSynchronously(_ operation: (_ context: NSManagedObjectContext) throws -> Void, saving: Bool = true) throws {
        try performAndWait {
            try operation(self)
            if saving {
                try save()
            }
        }
    }
}
#endif
