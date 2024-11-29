enum FileExtension: String {
    /// Extension for processed/compiled `NSManagedObjectModel`s.
    case compiledDataModel = "momd"
    /// Extension for processed/compiled `NSMappingModel`s.
    case compiledMappingModel = "cdm"
    /// A Core Data `NSManagedObjectModel`.
    case dataModel = "xcdatamodeld"
    /// A Core Data `NSMappingModel`.
    case mappingModel = "xcmappingmodel"
    /// Extension for Core Data SQLite _database_ file
    case sqlite = "sqlite"
    /// Extension for Core Data SQLite _shared memory_ file
    case sqliteSharedMemory = "sqlite-shm"
    /// Extension for Core Data SQLite _write-ahead-log_ file
    case sqliteWriteAheadLog = "sqlite-wal"
}
