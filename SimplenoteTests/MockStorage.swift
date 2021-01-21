import Foundation
import CoreData
@testable import Simplenote


/// MockupStorage: InMemory CoreData Stack.
///
class MockStorage {

    /// DataModel Name
    ///
    private let name = "Simplenote"

    /// Returns the Storage associated with the View Thread.
    ///
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// Persistent Container: Holds the full CoreData Stack
    ///
    private(set) lazy var persistentContainer: NSPersistentContainer = buildPersistentContainer()

    /// Nukes the specified Object
    ///
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
    }

    /// This method effectively destroys all of the stored data, and generates a blank Persistent Store from scratch.
    ///
    func reset() {
        persistentContainer = buildPersistentContainer()
        NSLog("💣 [MockupStorage] Stack Destroyed!")
    }

    /// "Persists" the changes
    ///
    func save() {
        try? viewContext.save()
    }
}


// MARK: - Descriptors
//
extension MockStorage {

    /// Returns the Application's ManagedObjectModel
    ///
    var managedModel: NSManagedObjectModel {
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("[MockupStorage] Could not load model")
        }

        return mom
    }

    /// Returns the PersistentStore Descriptor
    ///
    var storeDescription: NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        return description
    }
}


// MARK: - Stack URL's
//
extension MockStorage {

    /// Returns the ManagedObjectModel's URL: Pick this up from the Storage bundle. OKAY?
    ///
    var modelURL: URL {
        let bundle = Bundle(for: Note.self)
        guard let url = bundle.url(forResource: name, withExtension: "momd") else {
            fatalError("[MockupStorage] Missing Model Resource")
        }

        return url
    }
}


// MARK: - Private API(s)
//
private extension MockStorage {

    func buildPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name, managedObjectModel: managedModel)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("[MockupStorage] Fatal Error: \(error) [\(error.userInfo)]")
            }
        }

        return container
    }
}
