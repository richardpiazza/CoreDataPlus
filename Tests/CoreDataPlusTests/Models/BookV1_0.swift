import Foundation
#if canImport(CoreData)
import CoreData

@objc(BookV1_0)
public class BookV1_0: NSManagedObject {

}

extension BookV1_0 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookV1_0> {
        return NSFetchRequest<BookV1_0>(entityName: "Book")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isbn: String?
    @NSManaged public var published: Date?
    @NSManaged public var title: String?
    @NSManaged public var author: AuthorV1_0?

}
#endif
