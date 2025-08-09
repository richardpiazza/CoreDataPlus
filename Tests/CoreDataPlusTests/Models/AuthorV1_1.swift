import Foundation
#if canImport(CoreData)
import CoreData

@objc(AuthorV1_1)
public class AuthorV1_1: NSManagedObject {}

public extension AuthorV1_1 {

    @nonobjc class func fetchRequest() -> NSFetchRequest<AuthorV1_1> {
        NSFetchRequest<AuthorV1_1>(entityName: "Author")
    }

    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var authoredBooks: NSSet?
    @NSManaged var coAuthoredBooks: NSSet?
}

// MARK: Generated accessors for authoredBooks

public extension AuthorV1_1 {

    @objc(addAuthoredBooksObject:)
    @NSManaged func addToAuthoredBooks(_ value: BookV1_1)

    @objc(removeAuthoredBooksObject:)
    @NSManaged func removeFromAuthoredBooks(_ value: BookV1_1)

    @objc(addAuthoredBooks:)
    @NSManaged func addToAuthoredBooks(_ values: NSSet)

    @objc(removeAuthoredBooks:)
    @NSManaged func removeFromAuthoredBooks(_ values: NSSet)
}

// MARK: Generated accessors for coAuthoredBooks

public extension AuthorV1_1 {

    @objc(addCoAuthoredBooksObject:)
    @NSManaged func addToCoAuthoredBooks(_ value: BookV1_1)

    @objc(removeCoAuthoredBooksObject:)
    @NSManaged func removeFromCoAuthoredBooks(_ value: BookV1_1)

    @objc(addCoAuthoredBooks:)
    @NSManaged func addToCoAuthoredBooks(_ values: NSSet)

    @objc(removeCoAuthoredBooks:)
    @NSManaged func removeFromCoAuthoredBooks(_ values: NSSet)
}
#endif
