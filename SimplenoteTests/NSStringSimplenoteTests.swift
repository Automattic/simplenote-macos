import XCTest
@testable import Simplenote


// MARK: - NSAttributedStringToMarkdownConverter Unit Tests
//
class NSStringSimplenoteTests: XCTestCase {

    /// Verifies that `byEncodingAsTagHash` effectively escapes all of the non alphanumeric characters
    ///
    func testByEncodingAsTagHashEncodesAllOfTheNonAlphanumericCharactersInTheReceiver() {
        let sample = "1234567890!@#$%^&*()-_+[]';./,qwertyuiopasdfghjkl;'zxcvbnm,./🔥😂😃🤪👍🦆🏴‍☠️☝️😯"
        let encoded = sample.byEncodingAsTagHash
        let escapedSet = CharacterSet(charactersIn: encoded)
        let expectedSet = CharacterSet(charactersIn: "%").union(.alphanumerics)

        XCTAssertTrue(expectedSet.isSuperset(of: escapedSet))
    }

    /// Verifies that `byEncodingAsTagHash` allows us to properly compare Unicode Strings that would otherwise evaluate as not equal.
    /// Although our (three) sample strings yield the exact same character`ṩ`, regular `isEqualString` API returns `false`.
    ///
    /// By relying on `byEncodingAsTagHash` we can properly identify matching strings.
    ///
    /// - Note: When using the `Swift.String` class, the same comparison is actually correct.
    ///
    func testByEncodingTagAsHashAllowsUsToProperlyCompareStringsThatEvaluateAsNotEqualOtherwise() {
        let sampleA = NSString(stringLiteral: "\u{0073}\u{0323}\u{0307}")
        let sampleB = NSString(stringLiteral: "\u{0073}\u{0307}\u{0323}")
        let sampleC = NSString(stringLiteral: "\u{1E69}")

        let hashA = sampleA.byEncodingAsTagHash
        let hashB = sampleB.byEncodingAsTagHash
        let hashC = sampleC.byEncodingAsTagHash

        XCTAssertNotEqual(sampleA, sampleB)
        XCTAssertNotEqual(sampleA, sampleC)
        XCTAssertNotEqual(sampleB, sampleC)

        XCTAssertEqual(hashA, hashB)
        XCTAssertEqual(hashA, hashC)
        XCTAssertEqual(hashB, hashC)
    }

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
            XCTAssertEqual(sample.leadingSpaces, leading)
        }
    }

    /// Verifies that `line(at range:)` returns the expected line / range
    ///
    func testLineAtRangeReturnsTheLineAtTheSpecifiedRange() {
        let samples = [
            "Lorem Ipsum Sample Line\n",
            "Lorem Ipsum Second Line\n",
            "Lorem Ipsum Third Line"
        ]

        let sampleText = samples.joined() as NSString
        var locationInText = Int.zero

        for expectedText in samples {
            for location in 0 ..< expectedText.utf16.count {
                let rangeOfQuery = NSRange(location: locationInText + location, length: .zero)
                let (retrievedRange, retrievedText) = sampleText.line(at: rangeOfQuery)

                XCTAssertEqual(retrievedText, expectedText)
                XCTAssertEqual(retrievedRange.location, locationInText)
            }

            locationInText += expectedText.utf16.count
        }
    }

    /// Verifies that `line(at range:)` returns the range of the **full lines** affected by the specified range, even when it's partial
    ///
    func testLineAtRangeReturnsTheLinesAndRangeAffectingTheSpecifiedRangeEvenWhenItIsPartial() {
        let samples = [
            "Lorem Ipsum Sample Line\n",
            "Lorem Ipsum Second Line\n",
            "Lorem Ipsum Third Line\n",
            "Lorem Ipsum Fourth Line\n",
        ]

        let sampleText = samples.joined()
        let lengthOfPartialText = sampleText.utf16.count - samples[2].utf16.count + 1

        let rangeOfQuery = NSRange(location: .zero, length: lengthOfPartialText)
        let (retrievedRange, retrievedText) = sampleText.line(at: rangeOfQuery)

        XCTAssertEqual(retrievedRange, sampleText.fullRange)
        XCTAssertEqual(retrievedText, sampleText)
        XCTAssertNotEqual(retrievedRange, rangeOfQuery)
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

    /// Veifies that `insertingListMarkers` adds markers to every line (including empty lines)
    ///
    func testInsertingListMarkersAddsMarkersToEveryLine() {
        let sample = "L1\nL2\n"
        let expected = .richListMarker + "L1" + .newline + .richListMarker + "L2" + .newline + .richListMarker

        XCTAssertEqual(sample.insertingListMarkers.string, expected)
    }

    /// Verifies that `insertingListMarkers` adds the List Marker to an empty string
    ///
    func testInsertingListMarkersAddsMarkerToSingleLinedEmptyString() {
        let sample = ""
        let expected = String.richListMarker

        XCTAssertEqual(sample.insertingListMarkers.string, expected)
    }

    /// Verifies that `insertingListMarkers` respects the leading on every
    ///
    func testInsertingListMarkersRespectsTheLeadingOfEachLine() {
        let sample: [String] = [
            .space + "L1" + .newline,
            .tab + "L2" + .newline,
            .space + .space + .newline,
            "L3"
        ]
        let expected: [String] = [
            .space + .richListMarker + "L1" + .newline,
            .tab + .richListMarker + "L2" + .newline,
            .space + .space + .richListMarker + .newline,
            .richListMarker + "L3"
        ]

        XCTAssertEqual(sample.joined().insertingListMarkers.string, expected.joined())
    }

    /// Verifies that `removingListMarkers` returns a new String that does not contain our List Marker substrings (Attachment + Space).
    ///
    func testRemovingListMarkersEffectivelyNukesAttachmentAndWhitespacesInTheReceiver() {
        let sample: [String] = [
            .richListMarker + "L1" + .newline,
            .richListMarker + "L2" + .newline,
            "\n",
            .richListMarker + "L3" + .newline,
            "L4\n",
            "L5"
        ]
        let expected = "L1\nL2\n\nL3\nL4\nL5"

        XCTAssertEqual(sample.joined().removingListMarkers.string, expected)
    }

    /// Verifies that `removingListMarkers` returns a new String that does not contain our List Marker substrings (Attachment).
    ///
    func testRemovingListMarkersEffectivelyNukesAttachmentWithNoTrailingSpacesInTheReceiver() {
        let sample: [String] = [
            .attachmentString + "L1" + .newline,
            .attachmentString + "L2" + .newline,
        ]
        let expected = "L1\nL2\n"

        XCTAssertEqual(sample.joined().removingListMarkers.string, expected)
    }

    /// Verifies that `removingListMarkers` does nothing to strings that do not contain attachments
    ///
    func testRemovingListMarkersDoesNothingToStringsThatDontContainMarkers() {
        let sample = "L1\nL2\n\nL3\nL4\nL5"
        XCTAssertEqual(sample.removingListMarkers.string, sample)
    }
}
