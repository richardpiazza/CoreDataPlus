import Foundation
#if canImport(CoreData)
import CoreData

public extension NSEntityDescription {
    convenience init(name: String) {
        self.init()
        self.name = name
        managedObjectClassName = name
    }
}
#endif
