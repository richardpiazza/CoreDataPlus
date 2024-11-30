import Foundation
import Logging
#if canImport(CoreData)
import CoreData

public extension Bundle {
    @available(*, deprecated, renamed: "CoreDataPlusError")
    typealias ResourceError = CoreDataPlusError
    
    /// Retrieve a `NSManagedObjectModel` from the bundle.
    ///
    /// When correctly recognized and processed as a resource, `.xcdatamodeld` will be automatically compiled and
    /// presented as a `.momd` folder. In some instances (such as utilizing through the macOS command line) the resource
    /// is not processed. To account for this situation, a secondary URL {resource}.momd_precompiled will be checked.
    ///
    /// You can manually pre-compile `NSManagedObjectModel`s using the `momc` command found in the Xcode.app bundle.
    /// `/Applications/Xcode.app/Contents/Developer/usr/bin/momc`.
    ///
    /// - parameters
    ///   - resource: The name of the resource file (without extension)
    ///   - subdirectory: Path subdirectory where the resource may be found.
    func managedObjectModel(forResource resource: String, subdirectory: String? = nil) throws -> NSManagedObjectModel {
        let url: URL
        
        let dataModel = FileExtension.compiledDataModel.rawValue
        let dataModelPrecompiled = "\(FileExtension.compiledDataModel.rawValue)\(ResourceSuffix.precompiled.rawValue)"
        
        if let _url = self.url(forResource: resource, withExtension: dataModel) {
            url = _url
        } else if let _url = self.url(forResource: resource, withExtension: dataModelPrecompiled) {
            url = _url
        } else if let _url = self.url(forResource: resource, withExtension: dataModel, subdirectory: subdirectory) {
            url = _url
        } else if let _url = self.url(forResource: resource, withExtension: dataModelPrecompiled, subdirectory: subdirectory) {
            url = _url
        } else {
            throw Logger.coreDataPlus.error("Resource Not Found", error: CoreDataPlusError.resourceNotFound(resource, bundlePath: bundlePath))
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            throw Logger.coreDataPlus.error("Resource Corrupted", error: CoreDataPlusError.resourceContents("NSManagedObjectModel", path: url.path))
        }
        
        return model
    }
    
    /// Retrieve a `NSMappingModel` from the bundle.
    ///
    /// When correctly recognized and processed as a resource, `.xcmappingmodel` will be automatically compiled and
    /// presented as a `.cdm` file. In some instances (such as utilizing through the macOS command line) the resource
    /// is not processed. To account for this situation, a secondary URL {resource}.cdm_precompiled will be checked.
    ///
    /// You can manually pre-compile `NSMappingModel`s using the `mapc` command found in the Xcode.app bundle.
    /// `/Applications/Xcode.app/Contents/Developer/usr/bin/mapc`.
    ///
    /// - parameters
    ///   - resource: The name of the resource file (without extension)
    ///   - subdirectory: Path subdirectory where the resource may be found.
    func mappingModel(forResource resource: String, subdirectory: String? = nil) throws -> NSMappingModel {
        let url: URL
        
        let mappingModel = FileExtension.compiledMappingModel.rawValue
        let mappingModelPrecompiled = "\(FileExtension.compiledMappingModel.rawValue)\(ResourceSuffix.precompiled.rawValue)"
        
        if let _url = self.url(forResource: resource, withExtension: mappingModel) {
            url = _url
        } else if let _url = self.url(forResource: resource, withExtension: mappingModelPrecompiled) {
            url = _url
        } else if let _url = self.url(forResource: resource, withExtension: mappingModel, subdirectory: subdirectory) {
            url = _url
        } else if let _url = self.url(forResource: resource, withExtension: mappingModelPrecompiled, subdirectory: subdirectory) {
            url = _url
        } else {
            throw Logger.coreDataPlus.error("Resource Not Found", error: CoreDataPlusError.resourceNotFound(resource, bundlePath: bundlePath))
        }
        
        guard let mapping = NSMappingModel(contentsOf: url) else {
            throw Logger.coreDataPlus.error("Resource Corrupted", error: CoreDataPlusError.resourceContents("NSMappingModel", path: url.path))
        }
        
        return mapping
    }
}
#endif
