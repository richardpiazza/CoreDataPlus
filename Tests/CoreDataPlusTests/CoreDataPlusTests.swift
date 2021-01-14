import XCTest
@testable import CoreDataPlus
#if canImport(CoreData)
import CoreData
#endif

final class CoreDataPlusTests: XCTestCase {
    
    static var allTests: [(String, (CoreDataPlusTests) -> () throws -> ())] {
        var tests = [(String, (CoreDataPlusTests) -> () throws -> ())]()
        #if canImport(CoreData)
        tests.append(("testModelHashes", testModelHashes))
        tests.append(("testModel_1_0_Initialization", testModel_1_0_Initialization))
        tests.append(("testModel_1_1_Initialization", testModel_1_1_Initialization))
        tests.append(("testModelMigration_from_1_0_to_1_1", testModelMigration_from_1_0_to_1_1))
        #endif
        return tests
    }
    
    private let fileManager: FileManager = .default
    
    #if canImport(CoreData)
    enum ManagedModel: String, CaseIterable, ModelVersion, ModelCatalog {
        static var allVersions: [Self] { allCases }
        
        case v1_0 = "1.0"
        case v1_1 = "1.1"
        
        private static var models: [ManagedModel: NSManagedObjectModel] = [:]
        private static var mappings: [ManagedModel: NSMappingModel] = [:]
        
        var managedObjectModel: NSManagedObjectModel {
            if let model =  Self.models[self] {
                return model
            }
            
            let resource: String
            switch self {
            case .v1_0:
                resource = "CoreDataPlus_1.0"
            case .v1_1:
                resource = "CoreDataPlus_1.1"
            }
            
            guard let model = try? Bundle.module.managedObjectModel(forResource: resource) else {
                preconditionFailure("Unable to load model for resource '\(resource)'.")
            }
            
            Self.models[self] = model
            return model
        }
        
        var mappingModel: NSMappingModel? {
            if let mapping = Self.mappings[self] {
                return mapping
            }
            
            let resource: String
            switch self {
            case .v1_0: return nil
            case .v1_1:
                resource = "Model_1_0_to_1_1"
            }
            
            guard let mapping = try? Bundle.module.mappingModel(forResource: resource) else {
                preconditionFailure("Update to load mapping for resource '\(resource)'.")
            }
            
            Self.mappings[self] = mapping
            return mapping
        }
        
        var previousVersion: ModelVersion? {
            switch self {
            case .v1_0: return nil
            case .v1_1: return ManagedModel.v1_0
            }
        }
    }
    
    func testModelHashes() throws {
        var managedModel: ManagedModel
        var objectModel: NSManagedObjectModel
        var hashes: [String: Data]
        
        managedModel = .v1_0
        objectModel = managedModel.managedObjectModel
        hashes = objectModel.entityVersionHashesByName
        
        XCTAssertEqual(hashes["Author"]?.hexString, "3a504582f2a4ec6b9754e52fb5c3ebeac4e59c89d48a951a9fec3569514819c1")
        XCTAssertEqual(hashes["Book"]?.hexString, "09c6fa8d5e2e21b185726f7b5955efb6ab0fcef5e5b74f6ce355606459cd3835")
        
        managedModel = .v1_1
        objectModel = managedModel.managedObjectModel
        hashes = objectModel.entityVersionHashesByName
        
        XCTAssertEqual(hashes["Author"]?.hexString, "552ec30b3cc4da51a13a0f6705767a51cf2e6dfca788076279cc0bacdbc6d22b")
        XCTAssertEqual(hashes["Book"]?.hexString, "f21d3d7908442f000d972aa3f45e4896af9fce38fe16fd58c7839be88df87651")
    }
    
    func testModel_1_0_Initialization() throws {
        let storeURL = StoreURL(currentDirectory: "Model_1_0")
        let container: CatalogContainer<ManagedModel, NSPersistentContainer> = try .init(version: .v1_0, persistence: .store(storeURL), name: "ManagedModel")
        let context = container.persistentContainer.viewContext
        let author: AuthorV1_0 = context.make()
        author.id = UUID(uuidString: "ef71d564-cb1a-4a33-b55e-1d14c08cf329")!
        author.name = "Gary Taubes"
        let book: BookV1_0 = context.make()
        book.id = UUID(uuidString: "60cc517a-f62c-40d2-aa55-0718f3cd7390")!
        book.title = "The Case for Keto"
        book.isbn = "9780525520061"
        author.addToBooks(book)
        try context.save()
        try container.checkpointAndClose()
        try storeURL.destroy()
    }
    
    func testModel_1_1_Initialization() throws {
        let storeURL = StoreURL(currentDirectory: "Model_1_1")
        let container: CatalogContainer<ManagedModel, NSPersistentContainer> = try .init(version: .v1_1, persistence: .store(storeURL), name: "ManagedModel")
        let context = container.persistentContainer.viewContext
        let author: AuthorV1_1 = context.make()
        author.id = UUID(uuidString: "ef71d564-cb1a-4a33-b55e-1d14c08cf329")!
        author.name = "Gary Taubes"
        let book: BookV1_1 = context.make()
        book.id = UUID(uuidString: "60cc517a-f62c-40d2-aa55-0718f3cd7390")!
        book.title = "The Case for Keto"
        book.isbn = "9780525520061"
        author.addToAuthoredBooks(book)
        try context.save()
        try container.checkpointAndClose()
        try storeURL.destroy()
    }
    
    func testModelMigration_from_1_0_to_1_1() throws {
        let authorId: UUID = try XCTUnwrap(UUID(uuidString: "b6994cc6-73f5-4eda-a879-6b43f8a219ed"))
        let bookId: UUID = try XCTUnwrap(UUID(uuidString: "c53c84c8-ea05-4517-b0b5-5eaf09d1514e"))
        
        let storeURL = StoreURL(currentDirectory: "ManagedModel")
        var container: CatalogContainer<ManagedModel, NSPersistentContainer>
        var context: NSManagedObjectContext
        
        container = try .init(version: .v1_0, persistence: .store(storeURL), name: "ManagedModel")
        context = container.persistentContainer.viewContext
        
        let garyTaubes: AuthorV1_0 = context.make()
        garyTaubes.id = authorId
        garyTaubes.name = "Gary Taubes"
        
        let caseForKeto: BookV1_0 = context.make()
        caseForKeto.id = bookId
        caseForKeto.title = "The Case for Keto"
        caseForKeto.isbn = "9780525520061"
        
        garyTaubes.addToBooks(caseForKeto)
        
        try context.save()
        try container.checkpointAndClose()
        
        container = try .init(version: .v1_1, persistence: .store(storeURL), name: "ManagedModel", silentMigration: false)
        context = container.persistentContainer.viewContext
        
        XCTAssertEqual(container.migrationSource, .v1_0)
        
        let fetch: NSFetchRequest<AuthorV1_1> = AuthorV1_1.fetchRequest()
        fetch.predicate = NSPredicate(format: "%K = %@", #keyPath(AuthorV1_1.id), authorId.uuidString)
        
        let author = try XCTUnwrap(context.fetch(fetch).first)
        XCTAssertEqual(author.name, "Gary Taubes")
        
        let book = try XCTUnwrap((author.authoredBooks as? Set<BookV1_1>)?.first(where: { $0.id == bookId }))
        XCTAssertEqual(book.title, "The Case for Keto")
        XCTAssertEqual(book.isbn, "9780525520061")
        
        try container.checkpointAndClose()
        try storeURL.destroy()
    }
    
    func testUsageAfterCheckpoint() throws {
        let storeURL = StoreURL(currentDirectory: "CheckpointTest")
        let container: CatalogContainer<ManagedModel, NSPersistentContainer> = try .init(version: .v1_1, persistence: .store(storeURL), name: "ManagedModel")
        let context = container.persistentContainer.viewContext
        
        var author: AuthorV1_1 = context.make()
        author.id = UUID(uuidString: "ef71d564-cb1a-4a33-b55e-1d14c08cf329")!
        author.name = "Gary Taubes"
        
        let book: BookV1_1 = context.make()
        book.id = UUID(uuidString: "60cc517a-f62c-40d2-aa55-0718f3cd7390")!
        book.title = "The Case for Keto"
        book.isbn = "9780525520061"
        
        author.addToAuthoredBooks(book)
        
        try context.save()
        
        try container.checkpointAndContinue()
        
        let id = author.objectID
        author = try XCTUnwrap(context.object(with: id) as? AuthorV1_1)
        
        let anotherBook: BookV1_1 = context.make()
        anotherBook.id = UUID(uuidString: "B3B5C965-94A7-4243-B478-D5718D7B67C1")
        anotherBook.title = "The Case Against Sugar"
        anotherBook.isbn = "9780307946645"
        
        author.addToAuthoredBooks(anotherBook)
        
        try context.save()
        
        try container.checkpointAndClose()
        try storeURL.destroy()
    }
    #endif
}
