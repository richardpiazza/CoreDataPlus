import Foundation
#if canImport(CoreData)
import CoreData

public enum Persistence {
    /// `NSSQLiteStoreType`
    case store(_ storeURL: StoreURL)
    /// `NSInMemoryStoreType`
    case memory
}
#endif
