import XCTest
@testable import Simplenote


// MARK: - LookupControllerTests
//
class LookupControllerTests: XCTestCase {

    /// Verifies that `predicateForNotes(titleText:)` matches entities that contain the Keyword in their title, regardless of the diacritics
    ///
    func testSearchForNotesWithTitleTextMatchesEntitiesWithKeywordInTheTitleIgnoringSpecialCharacters() {
        let entity = LookupNote(simperiumKey: "1234", title: "Some title with díácrïtīc chårâctërs")
        let controller = LookupController(lookupMap: [
            entity.simperiumKey: entity
        ])

        let result = controller.search(titleText: "diâcritic characters")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].simperiumKey, entity.simperiumKey)
    }

    /// Verifies that `predicateForNotes(titleText:)` matches entities that contain the Keyword in their title, regardless of the case
    ///
    func testSearchForNotesWithTitleTextMatchesEntitiesWithKeywordInTheTitleIgnoringCase() {
        let entity = LookupNote(simperiumKey: "1234", title: "SOME TiTLE HERE")
        let controller = LookupController(lookupMap: [
            entity.simperiumKey: entity
        ])

        let result = controller.search(titleText: "tItle")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].simperiumKey, entity.simperiumKey)
    }
}
