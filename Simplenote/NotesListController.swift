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

    /// Refreshes the Internal State, so that Search Results matching the specified Keyword will be filtered out.
    /// - Important: It's up to the caller to invoke `performFetch`!!
    ///
    var searchKeyword: String? {
        get {
            guard case let .searching(keyword) = self.state else {
                return nil
            }

            return keyword
        }
        set {
            guard let keyword = newValue, !keyword.isEmpty else {
                state = .results
                return
            }

            state = .searching(keyword: keyword)
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
    @objc(noteAtIndex:)
    func note(at index: Int) -> Note? {
        let fetchedObjects = notesController.fetchedObjects
        return index >= .zero  && index < fetchedObjects.count ? fetchedObjects[index] : nil
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
    }
}


// MARK: - Private API
//
private extension NotesListController {

    func startListeningToNoteEvents() {
        notesController.onWillChangeContent = { [weak self] in
            self?.onWillChangeContent?()
        }

        notesController.onDidChangeContent = { [weak self] (_, objectsChangeset) in
            self?.onDidChangeContent?(objectsChangeset)
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
