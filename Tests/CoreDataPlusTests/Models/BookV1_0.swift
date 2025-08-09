import Foundation
#if canImport(CoreData)
import CoreData

@objc(BookV1_0)
public class BookV1_0: NSManagedObject {}

public extension BookV1_0 {

    @nonobjc class func fetchRequest() -> NSFetchRequest<BookV1_0> {
        NSFetchRequest<BookV1_0>(entityName: "Book")
    }

    @NSManaged var id: UUID?
    @NSManaged var isbn: String?
    @NSManaged var published: Date?
    @NSManaged var title: String?
    @NSManaged var author: AuthorV1_0?
}
#endif
