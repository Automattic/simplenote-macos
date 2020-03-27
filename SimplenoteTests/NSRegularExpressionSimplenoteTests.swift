import XCTest
@testable import Simplenote


// MARK: - NSRegularExpression Simplenote Unit Tests
//
class NSRegularExpressionSimplenoteTests: XCTestCase {

    /// Verifies that `NSRegularExpression.regexForChecklists` will not match checklists that are in the middle of a string
    ///
    func testRegexForChecklistsWillNotMatchChecklistsLocatedAtTheMiddleOfTheString() {
        let string = "This is a badly formed todo - [ ] Buy avocados - []"
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` matches multiple spacing prefixes
    ///
    func testRegexForChecklistsProperlyMatchesMultipleWhitespacePrefixes() {
        let string = "           - [ ] Buy avocados - [ ]"
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 1)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` only matches corretly formed strings
    ///
    func testRegexForChecklistsMatchProperlyFormattedChecklists() {
        let string = "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct."
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 3)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` will not match malformed strings
    ///
    func testRegexForChecklistsWillNotMatchMalformedChecklists() {
        let string = "- [x ] Malformed!"
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertTrue(matches.isEmpty)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` will match checklists with no spaces between brackets
    ///
    func testRegexForChecklistsWillMatchChecklistsWithNoInternalSpaces() {
        let string = "- [] Item"
        let regex = NSRegularExpression.regexForChecklists
        let matches = regex.matches(in: string, options: [], range: string.fullRange)

        XCTAssertEqual(matches.count, 1)
    }

    /// Verifies that `NSRegularExpression.regexForChecklists` always produces the expected number of ranges
    ///
    func testRegexForChecklistsAlwaysProduceTwoRanges() {
        let samples = [
            (text: "           - [ ] Buy avocados - [ ]", expected: 1),
            (text: "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct.", expected: 3),
            (text: "- [] Item", expected: 1)
        ]

        let regex = NSRegularExpression.regexForChecklists
        for (sample, expected) in samples {
            let matches = regex.matches(in: sample, options: [], range: sample.fullRange)
            XCTAssertEqual(matches.count, expected)

            for match in matches where match.numberOfRanges != NSRegularExpression.regexForChecklistsExpectedNumberOfRanges {
                XCTFail()
            }
        }
    }

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
}
