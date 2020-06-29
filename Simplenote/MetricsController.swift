import Foundation


// MARK: - MetricsController
//
class MetricsController {

    /// Collection of Notes being observed
    ///
    private(set) var notes: [Note] = []

    /// Returns the result of combining all of the observed note's contents
    ///
    private var contents: String {
        notes.compactMap({ $0.content }).reduce("", +)
    }

    /// Closure to be invoked whenever the observed objects are updated
    ///
    var onChange: (() -> Void)?

    // MARK: - Lifecycle

    deinit {
        stopListeningForNotifications()
    }

    init() {
        startListeningForNotifications()
    }


    // MARK: - Public API

    /// Starts observing changes over a given collection of Notes, and invokes `onChange` when any of such entities is updated.
    /// - Note: The very first time this API is invoked, it'll call `onChange` back
    ///
    func startReportingMetrics(for notes: [Note]) {
        self.notes = notes
        onChange?()
    }
}


// MARK: - Public Properties
//
extension MetricsController {

    /// Indicates if Date Fields must be rendered: Skip them when there are multiple notes selected
    ///
    private var displayDateFields: Bool {
        notes.count == 1
    }

    /// Returns the Note's Creation Date (whenever we're in single selection mode)
    ///
    var creationDate: Date? {
        displayDateFields ? notes.first?.creationDate : nil
    }

    /// Returns the Note's Modification Date (whenever we're in single selection mode)
    ///
    var modifiedDate: Date? {
        displayDateFields ? notes.first?.modificationDate : nil
    }

    /// Returns the total number of characters
    ///
    var numberOfChars: Int {
        contents.count
    }

    /// Returns the total number of words
    ///
    var numberOfWords: Int {
        notes.isEmpty ? .zero : NSSpellChecker.shared.countWords(in: contents, language: nil)
    }
}


// MARK: - Notification Helpers
//
private extension MetricsController {

    func startListeningForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mainContextWasUpdated),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: SimplenoteAppDelegate.shared().managedObjectContext)
    }

    func stopListeningForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Listening for Changes!
//
private extension MetricsController {

    /// Whenever a `NSManagedObjectContextObjectsDidChange` arrives, and any of the `notes` entities we're observing gets updated,
    /// we'll dispatch an `onChange()` invocation, notifying our observers that there are new metrics available.
    ///
    @objc
    func mainContextWasUpdated(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        let observedKeys = [NSUpdatedObjectsKey, NSRefreshedObjectsKey]
        let updatedObjectIDs = extractObjectIdentifiers(from: userInfo, keys: observedKeys)
        let observedObjectIDs = notes.map { $0.objectID }

        guard !updatedObjectIDs.intersection(observedObjectIDs).isEmpty else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.onChange?()
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
