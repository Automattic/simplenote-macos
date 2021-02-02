import XCTest
@testable import Simplenote


// MARK: - NSString Simplenote Tests
//
class StringSimplenoteTests: XCTestCase {

    /// Verifies that `truncateWords(upTo:) ` returns the N first characters of the receiver, whenever there are no words in the specified range.
    ///
    func testTruncateWordsReturnsTruncatedStringWheneverThereAreNoWords() {
        let sample = "1234567890"
        let expected = "12345"

        XCTAssertEqual(sample.truncateWords(upTo: 5), expected)
    }

    /// Verifies that `truncateWords(upTo:) ` truncates the receiver's full words, up to a maximum length.
    ///
    func testTruncateWordsReturnsWordsInSpecifiedRangeUpToMaximumLength() {
        let sample = "uno dos tres catorce!"
        let expected = "uno dos"

        XCTAssertEqual(sample.truncateWords(upTo: 10), expected)
    }
}

// MARK: - String droppingPrefix Tests
//
extension StringSimplenoteTests {

    /// Tests that droppingPrefix returns string without a specified prefix
    ///
    func testDroppingPrefixReturnsStringWithoutSpecifiedPrefix() {
        let sample = "uno dos tres catorce!"
        let prefix = "uno "
        let expected = "dos tres catorce!"

        XCTAssertEqual(sample.droppingPrefix(prefix), expected)
    }

    /// Tests that droppingPrefix returns empty string if string is a prefix
    ///
    func testDroppingPrefixReturnsEmptyStringIfOriginalStringIsPrefix() {
        let prefix = "uno "
        let expected = ""

        XCTAssertEqual(prefix.droppingPrefix(prefix), expected)
    }

    /// Tests that droppingPrefix returns original string if string doesn't have a prefix
    ///
    func testDroppingPrefixReturnsOriginalStringIfPrefixIsNotFound() {
        let sample = "uno dos tres catorce!"
        let prefix = "dos"
        let expected = sample

        XCTAssertEqual(sample.droppingPrefix(prefix), expected)
    }
}

// MARK: - String locationOfFirstCharacter Tests
//
extension StringSimplenoteTests {

    /// Verifies that providing incorrect starting location returns nil
    ///
    func testLocationOfFirstCharacterReturnsNilWhenStartingLocationIsAfterEndIndex() {
        let sample = " test "
        XCTAssertNil(sample.locationOfFirstCharacter(from: .alphanumerics, startingFrom: (sample + sample).endIndex))
    }

    /// Verifies correct location of first character in standard direction
    ///
    func testLocationOfFirstCharacterStandardDirection() {
        let sample = " test "
        let expected = sample.index(after: sample.startIndex)
        let actual = sample.locationOfFirstCharacter(from: .alphanumerics, startingFrom: sample.startIndex)
        XCTAssertEqual(actual, expected)
    }

    /// Verifies searching backwards from the start location of the string returns nil
    ///
    func testLocationOfFirstCharacterBackwardDirectionFromStartIndexReturnNil() {
        let sample = " test "
        let actual = sample.locationOfFirstCharacter(from: .alphanumerics, startingFrom: sample.startIndex, backwards: true)
        XCTAssertNil(actual)
    }

    /// Verifies correct location of first character in backwards direction
    ///
    func testLocationOfFirstCharacterBackwardDirection() {
        let sample = " test "
        let expected = sample.index(sample.endIndex, offsetBy: -2)
        let actual = sample.locationOfFirstCharacter(from: .alphanumerics, startingFrom: sample.endIndex, backwards: true)
        XCTAssertEqual(actual, expected)
    }

    /// Verifies searching from the end location of the string returns nil
    ///
    func testLocationOfFirstCharacterStandardDirectionFromEndIndexReturnNil() {
        let sample = " test "
        let actual = sample.locationOfFirstCharacter(from: .alphanumerics, startingFrom: sample.endIndex)
        XCTAssertNil(actual)
    }
}

// MARK: - ReplacingNewlinesWithSpaces Tests
//
extension StringSimplenoteTests {
    /// Verifies that `replacingNewlinesWithSpaces` returns an empty string, whenever the receiver is an empty string
    ///
    func testReplaceNewlinesWithSpacesDoesNotBreakWithEmptyStrings() {
        let sample = ""

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "")
    }

    /// Verifies that `replacingNewlinesWithSpaces` returns an empty string, whenever the receiver is a string containing a single Newline
    ///
    func testReplaceNewlinesWithSpacesProperlyHandlesSingleNewlineString() {
        let sample = "\n"

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "")
    }

    /// Verifies that `replacingNewlinesWithSpaces` returns an empty string, whenever the receiver is a string containing *Multiple* Newline(s)
    ///
    func testReplaceNewlinesWithSpacesProperlyHandlesMultipleNewlineString() {
        let sample = "\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r"

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "")
    }

    /// Verifies that `replacingNewlinesWithSpaces` replaces consecutive newlines with a single space
    ///
    func testReplaceNewlinesWithSpacesTurnMultipleConsecutiveNewlinesIntoSingleSpace() {
        let sample = "WORD1\n\n\n\r\nWORD2\nWORD3\n\r\n\r\n\rWORD4"

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "WORD1 WORD2 WORD3 WORD4")
    }

    /// Verifies that `replacingNewlinesWithSpaces` trims leading and trailing newlines
    ///
    func testReplaceNewlinesWithSpacesTrimsLeadingAndTrailingNewlines() {
        let sample = "\n\r\n\r\n\n\nWORD1\nWORD2\n\nWORD3\n\n\n\n"

        XCTAssertEqual(sample.replacingNewlinesWithSpaces(), "WORD1 WORD2 WORD3")
    }
}
