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
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as! T
    }
}
#endif
