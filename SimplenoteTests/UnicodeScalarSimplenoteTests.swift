import XCTest
@testable import Simplenote


// MARK: - UnicodeScalarSimplenoteTests Unit Tests
//
class UnicodeScalarSimplenoteTests: XCTestCase {

    /// Verifies that `isWhitespace` returns true for Spaces and Tabs
    ///
    func testIsWhitespaceReturnsTrueForSpacesAndTabs() {
        XCTAssertTrue(UnicodeScalar(" ").isWhitespace)
        XCTAssertTrue(UnicodeScalar("\t").isWhitespace)
    }

    /// Verifies that `isWhitespace` returns false for alphanumeric characters
    ///
    func testIsWhitespaceReturnsFalseForAlphanumericCharacters() {
        for character in UnicodeScalar("a").value...UnicodeScalar("z").value {
            XCTAssert(UnicodeScalar(character)?.isWhitespace == false)
        }

        for character in UnicodeScalar("A").value...UnicodeScalar("Z").value {
            XCTAssert(UnicodeScalar(character)?.isWhitespace == false)
        }

        for character in UnicodeScalar("0").value...UnicodeScalar("9").value {
            XCTAssert(UnicodeScalar(character)?.isWhitespace == false)
        }
    }
}
