import Foundation
#if canImport(CoreData)
import CoreData

@objc(BookV1_1)
public class BookV1_1: NSManagedObject {

}

extension BookV1_1 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookV1_1> {
        return NSFetchRequest<BookV1_1>(entityName: "Book")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isbn: String?
    @NSManaged public var published: Date?
    @NSManaged public var title: String?
    @NSManaged public var author: AuthorV1_1?
    @NSManaged public var coAuthors: NSSet?

}

// MARK: Generated accessors for coAuthors
extension BookV1_1 {

    @objc(addCoAuthorsObject:)
    @NSManaged public func addToCoAuthors(_ value: AuthorV1_1)

    @objc(removeCoAuthorsObject:)
    @NSManaged public func removeFromCoAuthors(_ value: AuthorV1_1)

    @objc(addCoAuthors:)
    @NSManaged public func addToCoAuthors(_ values: NSSet)

    @objc(removeCoAuthors:)
    @NSManaged public func removeFromCoAuthors(_ values: NSSet)

}
#endif
