import Foundation
import XCTest
@testable import Simplenote

// MARK: - Options Unit Tests
//
class OptionsTests: XCTestCase {

    private let suiteName = OptionsTests.classNameWithoutNamespaces.debugDescription
    private lazy var defaults = UserDefaults(suiteName: suiteName)!

    override func setUp() {
        super.setUp()
        defaults.reset()
    }

    func testEmptyLegacySortSettingsYieldModifiedNewest() {
        let options = Options(defaults: defaults)
        XCTAssert(options.notesListSortMode == .modifiedNewest)
    }

    func testLegacyAlphabeticalSortSetToTrueMapsToAlphabeticallyAscending() {
        defaults.set(true, forKey: .notesListSortModeLegacy)
        let options = Options(defaults: defaults)
        XCTAssert(options.notesListSortMode == .alphabeticallyAscending)
    }

    func testLegacyAlphabeticalSortSetToFalseMapsToModifiedNewest() {
        defaults.set(false, forKey: .notesListSortModeLegacy)
        let options = Options(defaults: defaults)
        XCTAssert(options.notesListSortMode == .modifiedNewest)
    }
}
