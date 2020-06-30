import Foundation


// MARK: - EntityObserverDelegate
//
protocol EntityObserverDelegate: class {
    func entityObserver(_ observer: EntityObserver, didObserveChanges for: Set<NSManagedObjectID>)
}


// MARK: - EntityObserver
//         Listens for changes applied over a set of ObjectIDs, and invokes a closure whenever any of the entities gets updated.
//
class EntityObserver {

    /// Identifiers of the objects being observed
    ///
    let observedIdentifiers: [NSManagedObjectID]

    /// Observed Change Types
    ///
    var changeTypes = [NSUpdatedObjectsKey, NSRefreshedObjectsKey]

    /// Closure to be invoked whenever any of the observed entities gets updated
    ///
    weak var delegate: EntityObserverDelegate?


    /// Designed Initialier
    ///
    /// - Parameters:
    ///     - identifiers: NSManagedObjectID(s) of the entities that should be observed
    ///     - context: NSManagedObjectContext in which we should listen for changes
    ///
    init(context: NSManagedObjectContext, identifiers: [NSManagedObjectID]) {
        observedIdentifiers = identifiers
        startListeningForNotifications(in: context)
    }
}


// MARK: - Listening for Changes!
//
private extension EntityObserver {

    func startListeningForNotifications(in context: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextWasUpdated),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: context)
    }

    @objc
    func contextWasUpdated(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let delegate = delegate else {
            return
        }

        let updatedIdentifiers = extractObjectIdentifiers(from: userInfo, keys: changeTypes).intersection(observedIdentifiers)
        guard !updatedIdentifiers.isEmpty else {
            return
        }

        DispatchQueue.main.async {
            delegate.entityObserver(self, didObserveChanges: updatedIdentifiers)
        }
    }

    /// Given a Notification's Payload, this API will extract the collection of NSManagedObjectID(s) stored under the specified keys.
    ///
    func extractObjectIdentifiers(from userInfo: [AnyHashable: Any], keys: [String]) -> Set<NSManagedObjectID> {
        var output = Set<NSManagedObjectID>()
        for key in keys {
            guard let objects = userInfo[key] as? Set<NSManagedObject> else {
                continue
            }

            let identifiers = objects.map { $0.objectID }
            output.formUnion(identifiers)
        }

        return output
    }
}
