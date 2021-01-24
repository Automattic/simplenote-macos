import Foundation
import CoreData
import SimplenoteFoundation
import SimplenoteSearch


// MARK: - NoteListController
//
class NoteListController: NSObject {

    /// Core Data Kung Fu
    ///
    private let viewContext: NSManagedObjectContext
    private lazy var notesController = ResultsController<Note>(viewContext: viewContext,
                                                               matching: filter.predicateForNotes(),
                                                               sortedBy: filter.descriptorsForNotes(sortMode: sortMode))

    /// Active Filter
    ///
    var filter: NoteListFilter = .everything {
        didSet {
            guard oldValue != filter else {
                return
            }

            refreshEverything()
        }
    }

    /// SortMode: Results Mode
    ///
    var sortMode: SortMode = .alphabeticallyAscending {
        didSet {
            guard oldValue != sortMode else {
                return
            }

            refreshSortDescriptors()
        }
    }

    /// Relays back willChangeContent Events
    ///
    var onWillChangeContent: (() -> Void)?

    /// Relays back didChangeContent Events
    ///
    var onDidChangeContent: ((_ rowsChangeset: ResultsObjectsChangeset) -> Void)?


    /// Designated Initializer
    ///
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        super.init()
        startListeningToNoteEvents()
    }
}


// MARK: - Public API
//
extension NoteListController {

    /// Number of the notes we've got!
    ///
    @objc
    var numberOfNotes: Int {
        notesController.numberOfObjects
    }

    /// Returns all of the Retrieved Notes
    ///
    var notes: [Note] {
        notesController.fetchedObjects
    }

    /// Returns the index of a given note (if any)
    ///
    func indexOfNote(withSimperiumKey key: String) -> Int? {
        return notesController.fetchedObjects.firstIndex { note in
            note.simperiumKey == key
        }
    }

    /// Returns the Indexes for the specified Note Keys (if any)
    ///
    func indexesOfNotes(withSimperiumKeys keys: [String]) -> IndexSet? {
        let indexes = keys.compactMap { indexOfNote(withSimperiumKey: $0) }
        return indexes.isEmpty ? nil : IndexSet(indexes)
    }

    /// Returns the Object at a given IndexPath (If any!)
    ///
    @objc(noteAtIndex:)
    func note(at index: Int) -> Note? {
        let fetchedObjects = notesController.fetchedObjects
        return index >= .zero  && index < fetchedObjects.count ? fetchedObjects[index] : nil
    }

    /// Returns the Fetched Note with the specified SimperiumKey (if any)
    ///
    func note(forSimperiumKey key: String) -> Note? {
        indexOfNote(withSimperiumKey: key).flatMap { index in
            note(at: index)
        }
    }

    /// Collection of notes at the specified IndexSet
    ///
    func notes(at indexes: IndexSet) -> [Note] {
        indexes.compactMap { index in
            note(at: index)
        }
    }

    /// Reloads all of the FetchedObjects, as needed
    ///
    func performFetch() {
        try? notesController.performFetch()
    }
}


// MARK: - Private API: ResultsController Refreshing
//
private extension NoteListController {

    func refreshPredicates() {
        notesController.predicate = filter.predicateForNotes()
    }

    func refreshSortDescriptors() {
        notesController.sortDescriptors = filter.descriptorsForNotes(sortMode: sortMode)
    }

    func refreshEverything() {
        refreshPredicates()
        refreshSortDescriptors()
    }
}


// MARK: - Private API
//
private extension NoteListController {

    func startListeningToNoteEvents() {
        notesController.onWillChangeContent = { [weak self] in
            self?.onWillChangeContent?()
        }

        notesController.onDidChangeContent = { [weak self] (_, objectsChangeset) in
            self?.onDidChangeContent?(objectsChangeset)
        }
    }
}
