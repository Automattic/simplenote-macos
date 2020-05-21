import XCTest
@testable import Simplenote


// MARK: - NSRegularExpression Simplenote Unit Tests
//
class NSRegularExpressionSimplenoteTests: XCTestCase {

    /// Verifies that `regexForLeadingSpaces` yields zero matches whenever the target string contains no spaces
    ///
    func testRegexForLeadingSpacesReturnsEmptyStringsWheneverThereAreNoSpaces() {
        let sample = "Lorem Ipsum Without Prefixum"
        let regex = NSRegularExpression.regexForLeadingSpaces

        let matches = regex.matches(in: sample, options: [], range: sample.fullRange)
        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `regexForLeadingSpaces` yields the expected range
    ///
    func testRegexForLeadingSpacesReturnsExpectedSpacingRanges() {
        let samples: [(text: String, range: NSRange)] = [
            ("   Lorem Ipsum With Spaces", NSRange(location: 0, length: 3)),
            ("\t\tLorem Ipsum With Tabs", NSRange(location: 0, length: 2)),
            ("\t  \tLorem Ipsum Mixum", NSRange(location: 0, length: 4))
        ]

        for (text, range) in samples {
            let matches = NSRegularExpression.regexForLeadingSpaces.matches(in: text, options: [], range: text.fullRange)

            XCTAssertEqual(matches.count, 1)
            XCTAssertEqual(matches[0].range, range)
        }
    }

    /// Verifies that `NSRegularExpression.regexForListMarkers` will not match checklists that are in the middle of a string
    ///
    func testRegexForListMarkersWillNotMatchChecklistsLocatedAtTheMiddleOfTheString() {
        let string = "This is a badly formed todo - [ ] Buy avocados - []"
        let regex = NSRegularExpression.regexForListMarkers
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `NSRegularExpression.regexForListMarkersEmbeddedAnywhere` matches multiple checklists in the same line
    ///
    func testRegexForListMarkersEmbeddedAnywhereWillMatchChecklistsLocatedAtTheMiddleOfTheString() {
        let string = "The second regex should consider this as a valid checklist - [ ] Buy avocados - []"
        let regex = NSRegularExpression.regexForListMarkersEmbeddedAnywhere
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 2)
    }

    /// Verifies that `NSRegularExpression.regexForListMarkers` matches multiple spacing prefixes
    ///
    func testRegexForListMarkersProperlyMatchesMultipleWhitespacePrefixes() {
        let string = "           - [ ] Buy avocados - [ ]"
        let regex = NSRegularExpression.regexForListMarkers
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 1)
    }

    /// Verifies that `NSRegularExpression.regexForListMarkersEmbeddedAnywhere` matches multiple spacing prefixes
    ///
    func testRegexForListMarkersEmbeddedEverywhereProperlyMatchesMultipleWhitespacePrefixes() {
        let string = "           - [ ] Buy avocados - [ ]"
        let regex = NSRegularExpression.regexForListMarkersEmbeddedAnywhere
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 2)
    }

    /// Verifies that `NSRegularExpression.regexForListMarkers` only matches corretly formed strings
    ///
    func testRegexForListMarkersMatchProperlyFormattedChecklists() {
        let string = "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct."
        let regex = NSRegularExpression.regexForListMarkers
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 3)
    }

    /// Verifies that `NSRegularExpression.regexForListMarkers` will not match malformed strings
    ///
    func testRegexForListMarkersWillNotMatchMalformedChecklists() {
        let string = "- [x ] Malformed!"
        let regex = NSRegularExpression.regexForListMarkers
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `NSRegularExpression.regexForChecklistsEverywhere` will not match malformed strings
    ///
    func testRegexForListMarkersEmbeddedEverywhereWillNotMatchMalformedChecklists() {
        let string = "- [x ] Malformed!"
        let regex = NSRegularExpression.regexForListMarkersEmbeddedAnywhere
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `NSRegularExpression.regexForListMarkers` will match checklists with no spaces between brackets
    ///
    func testRegexForListMarkersWillMatchChecklistsWithNoInternalSpaces() {
        let string = "- [] Item"
        let regex = NSRegularExpression.regexForListMarkers
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 1)
    }


    /// Verifies that `NSRegularExpression.regexForListMarkersEmbeddedAnywhere` will match checklists with no spaces between brackets
    ///
    func testRegexForListMarkersEmbeddedEverywhereWillMatchChecklistsWithNoInternalSpaces() {
        let string = "- [] Item"
        let regex = NSRegularExpression.regexForListMarkersEmbeddedAnywhere
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 1)
    }

    /// Verifies that `NSRegularExpression.regexForListMarkers` always produces the expected number of ranges
    ///
    func testRegexForListMarkersAlwaysProduceTwoRanges() {
        let samples = [
            (text: "           - [ ] Buy avocados - [ ]", expected: 1),
            (text: "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct.", expected: 3),
            (text: "- [] Item", expected: 1)
        ]

        let regex = NSRegularExpression.regexForListMarkers
        for (sample, expected) in samples {
            let matches = regex.matches(in: sample, options: [], range: sample.fullRange)
            XCTAssertEqual(matches.count, expected)

            for match in matches where match.numberOfRanges != NSRegularExpression.regexForListMarkersExpectedNumberOfRanges {
                XCTFail()
            }
        }
    }

    /// Verifies that `NSRegularExpression.regexForListMarkersEmbeddedAnywhere` always produces the expected number of ranges
    ///
    func testRegexForListMarkersEmbeddedEverywhereAlwaysProduceTwoRanges() {
        let samples = [
            (text: "           - [ ] Buy avocados - [ ]", expected: 2),
            (text: "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct.", expected: 3),
            (text: "- [] Item", expected: 1),
            (text: "The second regex should consider this as a valid checklist - [ ] Buy avocados - []", expected: 2)
        ]

        let regex = NSRegularExpression.regexForListMarkersEmbeddedAnywhere
        for (sample, expected) in samples {
            let matches = regex.matches(in: sample, options: [], range: sample.fullRange)
            XCTAssertEqual(matches.count, expected)

            for match in matches where match.numberOfRanges != NSRegularExpression.regexForListMarkersExpectedNumberOfRanges {
                XCTFail()
            }
        }
    }
}
