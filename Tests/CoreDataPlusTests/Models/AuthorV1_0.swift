import Foundation
#if canImport(CoreData)
import CoreData

@objc(AuthorV1_0)
public class AuthorV1_0: NSManagedObject {}

public extension AuthorV1_0 {

    @nonobjc class func fetchRequest() -> NSFetchRequest<AuthorV1_0> {
        NSFetchRequest<AuthorV1_0>(entityName: "Author")
    }

    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var books: NSSet?
}

// MARK: Generated accessors for books

public extension AuthorV1_0 {

    @objc(addBooksObject:)
    @NSManaged func addToBooks(_ value: BookV1_0)

    @objc(removeBooksObject:)
    @NSManaged func removeFromBooks(_ value: BookV1_0)

    @objc(addBooks:)
    @NSManaged func addToBooks(_ values: NSSet)

    @objc(removeBooks:)
    @NSManaged func removeFromBooks(_ values: NSSet)
}
#endif
