import Foundation
#if canImport(CoreData)
import CoreData

@objc(BookV1_1)
public class BookV1_1: NSManagedObject {}

public extension BookV1_1 {

    @nonobjc class func fetchRequest() -> NSFetchRequest<BookV1_1> {
        NSFetchRequest<BookV1_1>(entityName: "Book")
    }

    @NSManaged var id: UUID?
    @NSManaged var isbn: String?
    @NSManaged var published: Date?
    @NSManaged var title: String?
    @NSManaged var author: AuthorV1_1?
    @NSManaged var coAuthors: NSSet?
}

// MARK: Generated accessors for coAuthors

public extension BookV1_1 {

    @objc(addCoAuthorsObject:)
    @NSManaged func addToCoAuthors(_ value: AuthorV1_1)

    @objc(removeCoAuthorsObject:)
    @NSManaged func removeFromCoAuthors(_ value: AuthorV1_1)

    @objc(addCoAuthors:)
    @NSManaged func addToCoAuthors(_ values: NSSet)

    @objc(removeCoAuthors:)
    @NSManaged func removeFromCoAuthors(_ values: NSSet)
}
#endif
