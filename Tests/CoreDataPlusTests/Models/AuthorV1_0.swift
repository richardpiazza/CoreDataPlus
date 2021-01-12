import Foundation
#if canImport(CoreData)
import CoreData

@objc(AuthorV1_0)
public class AuthorV1_0: NSManagedObject {

}

extension AuthorV1_0 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorV1_0> {
        return NSFetchRequest<AuthorV1_0>(entityName: "Author")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var books: NSSet?

}

// MARK: Generated accessors for books
extension AuthorV1_0 {

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: BookV1_0)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: BookV1_0)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSSet)

}
#endif
