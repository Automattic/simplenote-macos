import XCTest
import SimplenoteFoundation
@testable import Simplenote


// MARK: - NotesListControllerTests
//
class NotesListControllerTests: XCTestCase {

    /// Let's launch an actual CoreData testing stack 🤟
    ///
    private let storage = MockupStorage()
    private var noteListController: NotesListController!


    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        noteListController = NotesListController(viewContext: storage.viewContext)
        noteListController.performFetch()
    }

    override func tearDown() {
        super.tearDown()
        storage.reset()
    }


    // MARK: - Tests: Filters

    /// Verifies that the Filter property properly filters Deleted notes
    ///
    func testListControllerProperlyFiltersDeletedNotesWhenInResultsMode() {
        let note = storage.insertSampleNote()

        storage.save()
        XCTAssertEqual(noteListController.numberOfNotes, 1)

        note.deleted = true
        storage.save()
        XCTAssertEqual(noteListController.numberOfNotes,.zero)

        noteListController.filter = .deleted
        XCTAssertEqual(noteListController.numberOfNotes, .zero)

        noteListController.performFetch()
        XCTAssertEqual(noteListController.numberOfNotes, 1)
    }

    /// Verifies that the Filter property properly filters Untagged notes
    ///
    func testListControllerProperlyFiltersUntaggedNotesWhenInResultsMode() {
        let note = storage.insertSampleNote()
        note.setTagsFromList(["tag"])
        storage.save()

        noteListController.filter = .everything
        noteListController.performFetch()
        XCTAssertEqual(noteListController.numberOfNotes, 1)

        noteListController.filter = .untagged
        noteListController.performFetch()
        XCTAssertEqual(noteListController.numberOfNotes, .zero)
    }

    /// Verifies that the Filter property properly filters Tagged notes
    ///
    func testListControllerProperlyFiltersTaggedNotesWhenInResultsMode() {
        noteListController.filter = .tag(name: "tag")
        noteListController.performFetch()
        XCTAssertEqual(noteListController.numberOfNotes, .zero)

        let note = storage.insertSampleNote()
        note.setTagsFromList(["tag"])
        storage.save()

        XCTAssertEqual(noteListController.numberOfNotes, 1)
    }



    // MARK: - Tests: Sorting

    /// Verifies that the SortMode property properly applies the specified order mode to the retrieved entities
    ///
    func testListControllerProperlyAppliesSortModeToRetrievedNotes() {
        let (notes, _, _) = insertSampleEntities(count: 100)

        storage.save()
        XCTAssertEqual(noteListController.numberOfNotes, notes.count)

        noteListController.sortMode = .alphabeticallyDescending
        noteListController.searchSortMode = .alphabeticallyDescending
        noteListController.performFetch()

        let reversedNotes = Array(notes.reversed())

        for (index, note) in noteListController.retrievedNotes.enumerated() {
            XCTAssertEqual(note.content, reversedNotes[index].content)
        }
    }

    // MARK: - Tests: Search

    /// Verifies that the Search API causes the List Controller to show matching entities
    ///
    func testSearchModeYieldsMatchingEntities() {
        storage.insertSampleNote(contents: "12345")
        storage.insertSampleNote(contents: "678")

        storage.save()
        XCTAssertEqual(noteListController.numberOfNotes, 2)

        noteListController.refreshSearchResults(keyword: "34")
        XCTAssertEqual(noteListController.numberOfNotes, 1)
    }

    /// Verifies that the `endSearch` switches the NotesList back to Results Mode
    ///
    func testEndSearchSwitchesBackToResultsMode() {
        let (notes, _, _) = insertSampleEntities(count: 100)
        storage.save()

        XCTAssertEqual(noteListController.numberOfNotes, notes.count)

        noteListController.refreshSearchResults(keyword: "99")
        XCTAssertEqual(noteListController.numberOfNotes, 1)

        noteListController.endSearch()
        XCTAssertEqual(noteListController.numberOfNotes, notes.count)
    }

    /// Verifies that the SearchMode disregards active Filters
    ///
    func testSearchModeYieldsGlobalResultsDisregardingActiveFilter() {
        let note = storage.insertSampleNote(contents: "Something Here")
        storage.save()

        noteListController.filter = .deleted
        noteListController.performFetch()

        XCTAssertEqual(noteListController.numberOfNotes, .zero)

        noteListController.beginSearch()
        noteListController.refreshSearchResults(keyword: "Here")

        XCTAssertEqual(noteListController.retrievedNotes.first, note)
    }


}


// MARK: - Private APIs
//
private extension NotesListControllerTests {

    /// Inserts `N` entities  with ascending payloads (Name / Contents)
    ///
    @discardableResult
    func insertSampleEntities(count: Int) -> ([Note], [Tag], [String]) {
        var notes = [Note]()
        var tags = [Tag]()
        var expected = [String]()

        for index in 0..<100 {
            let payload = String(format: "%03d", index)

            tags.append( storage.insertSampleTag(name: payload) )
            notes.append( storage.insertSampleNote(contents: payload) )
            expected.append( payload )
        }

        return (notes, tags, expected)
    }

}
