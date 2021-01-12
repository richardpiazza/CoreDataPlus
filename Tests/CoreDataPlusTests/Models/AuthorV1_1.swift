import Foundation
#if canImport(CoreData)
import CoreData

@objc(AuthorV1_1)
public class AuthorV1_1: NSManagedObject {

}

extension AuthorV1_1 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorV1_1> {
        return NSFetchRequest<AuthorV1_1>(entityName: "Author")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var authoredBooks: NSSet?
    @NSManaged public var coAuthoredBooks: NSSet?

}

// MARK: Generated accessors for authoredBooks
extension AuthorV1_1 {

    @objc(addAuthoredBooksObject:)
    @NSManaged public func addToAuthoredBooks(_ value: BookV1_1)

    @objc(removeAuthoredBooksObject:)
    @NSManaged public func removeFromAuthoredBooks(_ value: BookV1_1)

    @objc(addAuthoredBooks:)
    @NSManaged public func addToAuthoredBooks(_ values: NSSet)

    @objc(removeAuthoredBooks:)
    @NSManaged public func removeFromAuthoredBooks(_ values: NSSet)

}

// MARK: Generated accessors for coAuthoredBooks
extension AuthorV1_1 {

    @objc(addCoAuthoredBooksObject:)
    @NSManaged public func addToCoAuthoredBooks(_ value: BookV1_1)

    @objc(removeCoAuthoredBooksObject:)
    @NSManaged public func removeFromCoAuthoredBooks(_ value: BookV1_1)

    @objc(addCoAuthoredBooks:)
    @NSManaged public func addToCoAuthoredBooks(_ values: NSSet)

    @objc(removeCoAuthoredBooks:)
    @NSManaged public func removeFromCoAuthoredBooks(_ values: NSSet)

}
#endif
