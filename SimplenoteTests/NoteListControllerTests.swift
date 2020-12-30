import XCTest
import SimplenoteFoundation
@testable import Simplenote


// MARK: - NoteListControllerTests
//
class NoteListControllerTests: XCTestCase {

    /// Let's launch an actual CoreData testing stack 🤟
    ///
    private let storage = MockupStorage()
    private var noteListController: NoteListController!


    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        noteListController = NoteListController(viewContext: storage.viewContext)
        noteListController.performFetch()
    }
}


// MARK: - Tests: Filters
//
extension NoteListControllerTests {

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
}


// MARK: - Tests: Sorting
//
extension NoteListControllerTests {

    /// Verifies that the SortMode property properly applies the specified order mode to the retrieved entities
    ///
    func testListControllerProperlyAppliesSortModeToRetrievedNotes() {
        let (notes, _) = insertSampleNotes(count: 100)

        storage.save()
        XCTAssertEqual(noteListController.numberOfNotes, notes.count)

        noteListController.sortMode = .alphabeticallyDescending
        noteListController.performFetch()

        let reversedNotes = Array(notes.reversed())

        for (index, note) in noteListController.notes.enumerated() {
            XCTAssertEqual(note.content, reversedNotes[index].content)
        }
    }
}


// MARK: - Tests: Search
//
extension NoteListControllerTests {

    /// Verifies that the Search API causes the List Controller to show matching entities
    ///
    func testSearchModeYieldsMatchingEntities() {
        storage.insertSampleNote(contents: "12345")
        storage.insertSampleNote(contents: "678")

        storage.save()
        XCTAssertEqual(noteListController.numberOfNotes, 2)

        noteListController.filter = .searching(keyword: "34")
        noteListController.performFetch()

        XCTAssertEqual(noteListController.numberOfNotes, 1)
    }

    /// Verifies that the SearchMode disregards active Filters
    ///
    func testSearchModeYieldsGlobalResultsDisregardingDeletedEntities() {
        let note = storage.insertSampleNote(contents: "Something Here")
        note.deleted = true
        storage.save()

        noteListController.filter = .searching(keyword: "Here") 
        noteListController.performFetch()
        XCTAssertEqual(noteListController.numberOfNotes, .zero)
    }
}


// MARK: - Tests: `note(at:)`
//
extension NoteListControllerTests {

    /// Verifies that `note(at: Index)` returns the proper Note when in results mode
    ///
    func testObjectAtIndexReturnsTheProperEntityWhenInResultsMode() {
        let (_, expected) = insertSampleNotes(count: 100)

        storage.save()

        for (index, payload) in expected.enumerated() {
            let note = noteListController.note(at: index)!
            XCTAssertEqual(note.content, payload)
        }
    }

    /// Verifies that `note(at: Index)` returns the proper Note when in Search Mode (without Keywords)
    ///
    func testObjectAtIndexReturnsTheProperEntityWhenInSearchModeWithoutKeywords() {
        let (_, expected) = insertSampleNotes(count: 100)

        storage.save()

        // This is a specific keyword contained by eeeevery siiiiinnnnngle entity!
        noteListController.filter = .searching(keyword: "0")
        noteListController.performFetch()

        for (index, payload) in expected.enumerated() {
            let note = noteListController.note(at: index)!
            XCTAssertEqual(note.content, payload)
        }
    }

    /// Verifies that `note(at: Index)` returns the proper Note when in Search Mode (with Keywords)
    ///
    func testObjectAtIndexReturnsTheProperEntityWhenInSearchModeWithSomeKeyword() {
        insertSampleNotes(count: 100)
        storage.save()

        noteListController.filter = .searching(keyword: "055")
        noteListController.performFetch()
        XCTAssertEqual(noteListController.numberOfNotes, 1)

        let note = noteListController.note(at: .zero)!
        XCTAssertEqual(note.content, "055")
    }
}


// MARK: - Tests: `indexOfNote(withSimperiumKey:)`
//
extension NoteListControllerTests {

    /// Verifies that `indexOfNote(withSimperiumKey:)` returns the proper Note when in Results Mode
    ///
    func testIndexOfNoteReturnsTheProperIndexWhenInResultsMode() {
        let (notes, _) = insertSampleNotes(count: 100)
        storage.save()

        for (row, note) in notes.enumerated() {
            let key = note.simperiumKey!
            XCTAssertEqual(noteListController.indexOfNote(withSimperiumKey: key), row)
        }
    }

    /// Verifies that `indexOfNote(withSimperiumKey:)` returns the proper Note/Tag when in Search Mode
    ///
    func testIndexOfNoteReturnsTheProperIndexWhenInSearchMode() {
        let (notes, _) = insertSampleNotes(count: 100)
        storage.save()

        // This is a specific keyword contained by eeeevery siiiiinnnnngle entity!
        noteListController.filter = .searching(keyword: "0")
        noteListController.performFetch()

        for (index, note) in notes.enumerated() {
            XCTAssertEqual(noteListController.indexOfNote(withSimperiumKey: note.simperiumKey), index)
        }
    }
}


// MARK: - Tests: onDidChangeContent
//
extension NoteListControllerTests {

    /// Verifies that `onDidChangeContent` is invoked for: `Insertion OP` /  `Results Mode`
    ///
    func testOnDidChangeContentDoesRunForNoteInsertionsWhenInResultsMode() {
        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(inserted: [
            IndexPath(index: .zero)
        ]))

        storage.insertSampleNote()
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onDidChangeContent` is invoked for: `Deletion OP` /  `Results Mode`
    ///
    func testOnDidChangeContentDoesRunForNoteDeletionsWhenInResultsMode() {
        let note = storage.insertSampleNote()
        storage.save()

        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(deleted: [
            IndexPath(index: .zero)
        ]))

        storage.delete(note)
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onDidChangeContent` is invoked for: `Update OP` /  `Results Mode`
    ///
    func testOnDidChangeContentDoesRunForNoteUpdatesWhenInResultsMode() {
        let note = storage.insertSampleNote()
        storage.save()

        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(updated: [
            IndexPath(index: .zero)
        ]))

        note.content = "Updated"
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onDidChangeContent` is invoked for: `Update OP` /  `Results Mode`
    ///
    func testOnDidChangeContentDoesRunForNoteUpdateWhenInResultsModeAndRelaysMoveOperations() {
        let firstNote = storage.insertSampleNote(contents: "A")
        storage.insertSampleNote(contents: "B")
        storage.save()

        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(moved: [
            (from: IndexPath(index: .zero), to: IndexPath(index: 1))
        ]))

        firstNote.content = "C"
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onDidChangeContent` is invoked for: `Insert OP` /  `Search Mode`
    ///
    func testOnDidChangeContentDoesRunForNoteInsertionsWhenInSearchModeAndTheSectionIndexIsProperlyCorrected() {
        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(inserted: [
            IndexPath(index: .zero)
        ]))

        noteListController.filter = .searching(keyword: "Test")
        noteListController.performFetch()

        storage.insertSampleNote(contents: "Test")
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onDidChangeContent` is invoked for: `Update OP` /  `Search Mode`
    ///
    func testOnDidChangeContentDoesRunForNoteUpdatesWhenInSearchModeAndTheSectionIndexIsProperlyCorrected() {
        let note = storage.insertSampleNote(contents: "Test")
        storage.save()

        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(updated: [
            IndexPath(index: .zero)
        ]))

        noteListController.filter = .searching(keyword: "Test")
        note.content = "Test Updated"
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onDidChangeContent` is invoked for: `Delete OP` /  `Search Mode`
    ///
    func testOnDidChangeContentDoesRunForNoteDeletionWhenInSearchModeAndTheSectionIndexIsProperlyCorrected() {
        let note = storage.insertSampleNote(contents: "Test")
        storage.save()

        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(deleted: [
            IndexPath(index: .zero)
        ]))

        noteListController.filter = .searching(keyword: "Test")
        storage.delete(note)
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onDidChangeContent` does not relay duplicated Changesets
    ///
    func testOnDidChangeContentDoesNotRelayDuplicatedEvents() {
        storage.insertSampleNote(contents: "A")
        storage.save()

        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(inserted: [
            IndexPath(index: 1)
        ]))

        storage.insertSampleNote(contents: "B")
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `onDidChangeContent` relays move events
    ///
    func testOnDidChangeContentRelaysMoveEvents() {
        storage.insertSampleNote(contents: "A")
        storage.insertSampleNote(contents: "B")
        let note = storage.insertSampleNote(contents: "C")

        storage.save()

        expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset(moved: [
            (from: IndexPath(index: 2), to: IndexPath(index: .zero))
        ]))

        note.pinned = true
        storage.save()

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }
}


// MARK: - Private APIs
//
private extension NoteListControllerTests {

    /// Inserts `N` Notes  with ascending payloads (Contents)
    ///
    @discardableResult
    func insertSampleNotes(count: Int) -> ([Note], [String]) {
        var notes = [Note]()
        var expected = [String]()

        for index in 0..<100 {
            let payload = String(format: "%03d", index)
            let note = storage.insertSampleNote(contents: payload)
            note.simperiumKey = index.description

            notes.append(note)
            expected.append(payload)
        }

        return (notes, expected)
    }

    /// Expects the specified Object and Section changes to be relayed via `onDidChangeContent`
    ///
    func expectOnDidChangeContent(objectsChangeset: ResultsObjectsChangeset) {
        let expectation = self.expectation(description: "Waiting...")

        noteListController.onDidChangeContent = { receivedObjectChanges in
            for (index, change) in objectsChangeset.deleted.enumerated() {
                XCTAssertEqual(change, objectsChangeset.deleted[index])
            }

            for (index, change) in objectsChangeset.inserted.enumerated() {
                XCTAssertEqual(change, objectsChangeset.inserted[index])
            }

            for (index, change) in objectsChangeset.moved.enumerated() {
                XCTAssertEqual(change.from, objectsChangeset.moved[index].from)
                XCTAssertEqual(change.to, objectsChangeset.moved[index].to)
            }

            for (index, change) in objectsChangeset.updated.enumerated() {
                XCTAssertEqual(change, objectsChangeset.updated[index])
            }

            XCTAssertEqual(objectsChangeset.deleted.count, receivedObjectChanges.deleted.count)
            XCTAssertEqual(objectsChangeset.inserted.count, receivedObjectChanges.inserted.count)
            XCTAssertEqual(objectsChangeset.moved.count, receivedObjectChanges.moved.count)
            XCTAssertEqual(objectsChangeset.updated.count, receivedObjectChanges.updated.count)
            expectation.fulfill()
        }
    }
}
