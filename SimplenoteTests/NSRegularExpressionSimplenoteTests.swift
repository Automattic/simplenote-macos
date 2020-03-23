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
}
