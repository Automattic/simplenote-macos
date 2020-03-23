import XCTest
@testable import Simplenote


// MARK: - NSAttributedStringToMarkdownConverter Unit Tests
//
class NSStringSimplenoteTests: XCTestCase {

    /// Verifies that `fullRange` effectively returns a NSRange that wraps up the entire string
    ///
    func testFullRangeReturnsSomeRangeWrappingTheEntireString() {
        let sample: NSString = "Lorem Ipsum Samplum String"
        let range = sample.fullRange

        XCTAssertEqual(range.location, .zero)
        XCTAssertEqual(range.length, sample.length)
    }

    /// Verifies that `leadingSpaces` effectively returns a string containing the receiver's spaces
    ///
    func testLeadingSpaceReturnsTheExpectedSubstring() {
        let samples: [(sample: String, leading: String)] = [
            ("Lorem Ipsum Non Spaces", ""),
            ("   Lorem Ipsum Spaces", "   "),
            (" \t  Lorem Ipsum Mixed", " \t  "),
        ]

        for (sample, leading) in samples {
            XCTAssertEqual(sample.leadingSpaces(), leading)
        }
    }

    /// Verifies that `rangeOfListMarker` returns nil whenever none of the sample strings contains a valid prefix
    ///
    func testRangeOfListMarkerReturnsNilWheneverThereAreNoValidPrefixes() {
        let samples = [
            "It's strictly business, Sonny",
            "Not a valid - checklist",
            "This one is + also not valid",
            "This one contains a text attachment " + String.attachmentString + " somewhere in the middle"
        ]

        for sample in samples {
            XCTAssertNil(sample.rangeOfListMarker)
        }
    }

    /// Verifies that `rangeOfListMarker` returns the expected range
    ///
    func testRangeOfListMarkerReturnsMarkerRangeWheneverTheLineStartsWithSomeBullet() {
        let expectedRange = NSRange(location: 0, length: 1)

        for marker in String.listMarkers {
            let string0 = marker + "NoSpaces"
            let string1 = marker + " Space"
            let string2 = marker + "\tTab"

            XCTAssertEqual(string0.rangeOfListMarker, expectedRange)
            XCTAssertEqual(string1.rangeOfListMarker, expectedRange)
            XCTAssertEqual(string2.rangeOfListMarker, expectedRange)
        }
    }

    /// Verifies that `rangeOfListMarker` returns the expected range whenever the receiver contains whitespaces
    ///
    func testRangeOfListMarkerReturnsMarkerRangeWhenStringContainsPrefixes() {
        for marker in String.listMarkers {
            let samples = [
                (text: " "      + marker + " Prefixed", location: 1),
                (text: "    "   + marker + " Prefixed", location: 4),
                (text: "\t "    + marker + " Prefixed", location: 2),
                (text: "\t\t\t" + marker + " Prefixed", location: 3),
            ]

            for (sample, location) in samples {
                let range = NSRange(location: location, length: 1)
                XCTAssertEqual(sample.rangeOfListMarker, range)
            }
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
        for marker in markers {
            let samples = [
                (text: marker + " Some sample string",              location: 0),
                (text: "\t" + marker + "  Some sample string",      location: 1),
                (text: "  " + marker + " Some sample string",       location: 2),
                (text: "     " + marker + " Some sample string",    location: 5),
                (text: "     " + marker + " Some sample string",    location: 5),
            ]

            for (text, location) in samples {
                let range = NSRange(location: location, length: 1)
                XCTAssertEqual(text.rangeOfAnyPrefix(prefixes: markers), range)
            }
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
