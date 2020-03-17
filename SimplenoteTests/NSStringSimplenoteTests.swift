import XCTest
@testable import Simplenote


// MARK: - NSAttributedStringToMarkdownConverter Unit Tests
//
class NSStringSimplenoteTests: XCTestCase {

    /// Verifies that `rangeOfTextListMarker` returns nil whenever none of the sample strings contains a valid prefix
    ///
    func testRangeOfTextListMarkerReturnsNilWheneverThereAreNoValidPrefixes() {
        let samples = [
            "It's strictly business, Sonny",
            "Not a valid - checklist",
            "This one is + also not valid",
        ]

        for sample in samples {
            XCTAssertEqual(sample.rangeOfTextListMarker, nil)
        }
    }

    /// Verifies that `rangeOfTextListMarker` returns the expected range
    ///
    func testRangeOfTextListMarkerReturnsMarkerRangeWheneverTheLineStartsWithSomeBullet() {
        let expectedRange = NSRange(location: 0, length: 1)
        let samples = [
            "-NoSpaces",
            "•NoSpaces",
            "*NoSpaces",
            "+NoSpaces",
            "- Space",
            "• Space",
            "* Space",
            "+ Space",
            "-\tTab",
            "•\tTab",
            "*\tTab",
            "+\tTab",
        ]

        for sample in samples {
            XCTAssertEqual(sample.rangeOfTextListMarker, expectedRange)
        }
    }

    /// Verifies that `rangeOfTextListMarker` returns the expected range whenever the receiver contains whitespaces
    ///
    func testRangeOfTextListMarkerReturnsMarkerRangeWhenStringContainsPrefixes() {
        let samples = [
            (" - Prefixed",         NSRange(location: 1, length: 1)),
            ("    • Prefixed",      NSRange(location: 4, length: 1)),
            ("\t * Prefixed",       NSRange(location: 2, length: 1)),
            ("\t\t\t+ Prefixed",    NSRange(location: 3, length: 1)),
        ]

        for (sample, range) in samples {
            XCTAssertEqual(sample.rangeOfTextListMarker, range)
        }
    }

    /// Verifies that `rangeOfListMarker` returns the expected range whenever the receiver starts with a Text Attachment
    ///
    func testRangeOfListMarkerReturnsMarkerRangeWheneverTheLineStartsWithSomeTextAttachment() {
        let expectedRange = NSRange(location: 0, length: 1)
        let samples = [
            String.attachmentString + "NoSpaces",
            String.attachmentString + " Space",
            String.attachmentString + "\tTab",
        ]


        for sample in samples {
            XCTAssertEqual(sample.rangeOfListMarker, expectedRange)
        }
    }

    /// Verifies that `rangeOfAnyPrefix` returns nil whenever none of the specified prefixes is contained within the receiver
    ///
    func testRangeOfAnyPrefixReturnsNilWheneverNoneOfThePrefixesAppearsInTheReceiver() {
        let elements = ["1", "2", "3"]
        let sample = "This sample string clearly does not contain any of the elements. Capisci?"

        XCTAssertNil(sample.rangeOfAnyPrefix(prefixes: elements))
    }

    /// Verifies that `rangeOfAnyPrefix` returns the expected range, whenever the (any) of the specified prefixes is effectively contained
    ///
    func testRangeOfAnyPrefixReturnsExpectedRange() {
        let markers = ["•", "-", "+", "*"]
        let sample = [
            ("• Some sample string", NSRange(location: 0, length: 1)),
            ("- Some sample string", NSRange(location: 0, length: 1)),
            ("+ Some sample string", NSRange(location: 0, length: 1)),
            ("* Some sample string", NSRange(location: 0, length: 1)),
            ("\t- Some sample string", NSRange(location: 1, length: 1)),
            ("  - Some sample string", NSRange(location: 2, length: 1)),
            ("     * Some sample string", NSRange(location: 5, length: 1)),
            ("     - Some sample string", NSRange(location: 5, length: 1)),
        ]

        for (sample, range) in sample {
            XCTAssertEqual(sample.rangeOfAnyPrefix(prefixes: markers), range)
        }
    }

    /// Verifies that `unicodeScalar` safely disregards locations out of bounds
    ///
    func testUnicodeScalarReturnsNilWheneverLocationIsOutOfBounds() {
        XCTAssertNil("".unicodeScalar(at: .max))
    }

    /// Verifies that `unicodeScalar` returns the expected character at a given location
    ///
    func testUnicodeScalarReturnsExpectedScalar() {
        let sample = NSString("1234567890")

        for index in 0 ..< sample.length {
            guard let scalar = sample.unicodeScalar(at: index) else {
                XCTFail()
                continue
            }

            XCTAssertEqual(UInt32(sample.character(at: index)), scalar.value)
        }
    }
}
