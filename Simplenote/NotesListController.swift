import Foundation
import CoreData
import SimplenoteFoundation
import SimplenoteSearch


// MARK: - NotesListController
//
class NotesListController: NSObject {

    /// Core Data Kung Fu
    ///
    private let viewContext: NSManagedObjectContext
    private lazy var notesController = ResultsController<Note>(viewContext: viewContext,
                                                               matching: state.predicateForNotes(filter: filter),
                                                               sortedBy: state.descriptorsForNotes(sortMode: sortMode))

    /// FSM: Active State
    ///
    private(set) var state: NotesListState = .results {
        didSet {
            guard oldValue != state else {
                return
            }

            refreshEverything()
        }
    }

    /// Filter: Applied when we're not in Search Mode
    ///
    var filter: NotesListFilter = .everything {
        didSet {
            guard oldValue != filter else {
                return
            }

            refreshPredicates()
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

    /// SortMode: Search Mode
    ///
    var searchSortMode: SortMode = .alphabeticallyAscending {
        didSet {
            guard case .searching = state, oldValue != searchSortMode else {
                return
            }

            refreshSortDescriptors()
        }
    }

    /// Relays back change events received from the FRC itself
    ///
    var onBatchChanges: ((_ rowsChangeset: ResultsObjectsChangeset) -> Void)?


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
extension NotesListController {

    /// Number of the notes we've got!
    ///
    @objc
    var numberOfNotes: Int {
        notesController.numberOfObjects
    }

    /// Returns all of the Retrieved Notes
    ///
    var retrievedNotes: [Note] {
        notesController.fetchedObjects
    }

    /// Returns the index of a given note (if any)
    ///
    func indexOfNote(withSimperiumKey key: String) -> Int? {
        for (index, note) in notesController.fetchedObjects.enumerated() where note.simperiumKey == key {
            return index
        }

        return nil
    }

    /// Returns the Object at a given IndexPath (If any!)
    ///
    func note(at index: Int) -> Note? {
        notesController.fetchedObjects[index]
    }

    /// Returns the Fetched Note with the specified SimperiumKey (if any)
    ///
    func note(forSimperiumKey key: String) -> Note? {
        notesController.fetchedObjects.first { note in
            note.simperiumKey == key
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


// MARK: - Search API
//
extension NotesListController {

    /// Enters into Search Mode. Alledgedly.
    ///
    func beginSearch() {
        // NO-OP: Just for consistency's sake
    }

    /// Refreshes the FetchedObjects so that they match a given Keyword
    ///
    /// -   Note: Whenever the Keyword is actually empty, we'll fallback to regular results. Capisci?
    ///
    @objc
    func refreshSearchResults(keyword: String) {
        if keyword.isEmpty {
            state = .results
            return
        }
        state = .searching(keyword: keyword)
    }

    /// Switches back to Results Mode
    ///
    func endSearch() {
        state = .results
    }
}


// MARK: - Private API: ResultsController Refreshing
//
private extension NotesListController {

    func refreshPredicates() {
        notesController.predicate = state.predicateForNotes(filter: filter)
    }

    func refreshSortDescriptors() {
        notesController.sortDescriptors = state.descriptorsForNotes(sortMode: sortModeForActiveState)
    }

    func refreshEverything() {
        refreshPredicates()
        refreshSortDescriptors()
        performFetch()
    }
}


// MARK: - Private API
//
private extension NotesListController {

    func startListeningToNoteEvents() {
        notesController.onDidChangeContent = { [weak self] (_, objectsChangeset) in
            self?.onBatchChanges?(objectsChangeset)
        }
    }

    var sortModeForActiveState: SortMode {
        switch state {
        case .searching:
            return searchSortMode
        case .results:
            return sortMode
        }
    }
}
