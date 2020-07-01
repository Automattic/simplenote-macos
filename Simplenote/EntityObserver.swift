import Foundation


// MARK: - EntityObserverDelegate
//
protocol EntityObserverDelegate: class {
    func entityObserver(_ observer: EntityObserver, didObserveChanges identifiers: Set<NSManagedObjectID>)
}


// MARK: - EntityObserver
//         Listens for changes applied over a set of ObjectIDs, and invokes a closure whenever any of the entities gets updated.
//
class EntityObserver {

    /// NotificationCenter Observer Token.
    ///
    private var notificationsToken: Any!

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
    ///     - context: NSManagedObjectContext in which we should listen for changes
    ///     - identifiers: NSManagedObjectID(s) of the entities that should be observed
    ///
    init(context: NSManagedObjectContext, identifiers: [NSManagedObjectID]) {
        observedIdentifiers = identifiers
        notificationsToken = startListeningForNotifications(in: context)
    }

    /// Convenience Initializer
    ///
    /// - Parameters:
    ///     - context: NSManagedObjectContext in which we should listen for changes
    ///     - objects: NSManagedObject(s) that should be observed
    ///
    convenience init(context: NSManagedObjectContext, objects: [NSManagedObject]) {
        let identifiers = objects.map { $0.objectID }
        self.init(context: context, identifiers: identifiers)
    }

    /// Convenience Initializer
    ///
    /// - Parameters:
    ///     - context: NSManagedObjectContext in which we should listen for changes
    ///     - object: NSManagedObjec that should be observed for changes
    ///
    convenience init(context: NSManagedObjectContext, object: NSManagedObject) {
        self.init(context: context, identifiers: [object.objectID])
    }
}


// MARK: - Listening for Changes!
//
private extension EntityObserver {

    func startListeningForNotifications(in context: NSManagedObjectContext) -> Any {
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                                               object: context,
                                               queue: .main) { [weak self] note in
            self?.contextDidChange(note)
        }
    }

    func contextDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let delegate = delegate else {
            return
        }

        let updatedIdentifiers = extractObjectIdentifiers(from: userInfo, keys: changeTypes).intersection(observedIdentifiers)
        if updatedIdentifiers.isEmpty {
            return
        }

        delegate.entityObserver(self, didObserveChanges: updatedIdentifiers)
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
