import Foundation

public extension String {
    /// Extension for Core Data SQLite _database_ file
    @available(*, deprecated, renamed: "FileExtension.sqlite")
    static let sqlite: String = "sqlite"
    /// Extension for Core Data SQLite _shared memory_ file
    @available(*, deprecated, renamed: "FileExtension.sqliteSharedMemory")
    static let sqlite_shm: String = "sqlite-shm"
    /// Extension for Core Data SQLite _write-ahead-log_ file
    @available(*, deprecated, renamed: "FileExtension.sqliteWriteAheadLog")
    static let sqlite_wal: String = "sqlite-wal"
    
    /// A Core Data `NSManagedObjectModel`.
    @available(*, deprecated, renamed: "FileExtension.dataModel")
    static let xcdatamodeld: String = "xcdatamodeld"
    /// Extension for processed/compiled `NSManagedObjectModel`s.
    @available(*, deprecated, renamed: "FileExtension.compiledDataModel")
    static let momd: String = "momd"
    
    /// A Core Data `NSMappingModel`.
    @available(*, deprecated, renamed: "FileExtension.mappingModel")
    static let xcmappingmodel: String = "xcmappingmodel"
    /// Extension for processed/compiled `NSMappingModel`s.
    @available(*, deprecated, renamed: "FileExtension.compiledMappingModel")
    static let cdm: String = "cdm"
    
    /// Suffix appended to Temporary resources.
    @available(*, deprecated, renamed: "ResourceSuffix.temporary")
    static let temp: String = "_temp"
    /// Suffix appended to Copy resources.
    @available(*, deprecated, renamed: "ResourceSuffix.precompiled")
    static let precompiled: String = "_precompiled"
}
