import Foundation

public extension String {
    /// Extension for Core Data SQLite _database_ file
    static let sqlite: String = "sqlite"
    /// Extension for Core Data SQLite _shared memory_ file
    static let sqlite_shm: String = "sqlite-shm"
    /// Extension for Core Data SQLite _write-ahead-log_ file
    static let sqlite_wal: String = "sqlite-wal"
    
    /// A Core Data `NSManagedObjectModel`.
    static let xcdatamodeld: String = "xcdatamodeld"
    /// Extension for processed/compiled `NSManagedObjectModel`s.
    static let momd: String = "momd"
    
    /// A Core Data `NSMappingModel`.
    static let xcmappingmodel: String = "xcmappingmodel"
    /// Extension for processed/compiled `NSMappingModel`s.
    static let cdm: String = "cdm"
    
    /// Suffix appended to Temporary resources.
    static let temp: String = "_temp"
    /// Suffix appended to Copy resources.
    static let precompiled: String = "_precompiled"
}
