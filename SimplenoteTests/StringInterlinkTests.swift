import XCTest
@testable import Simplenote


// MARK: - String+Interlink Unit Tests
//
class StringInterlinkTests: XCTestCase {

    /// Verifies that `interlinkKeyword(at:)` returns nil whenever the `[keyword` is not located at the left hand side of the specified location
    ///
    func testInterlinkKeywordReturnsNilWheneverTheSpecifiedLocationDoesNotContainTrailingOpeningBrackets() {
        let keyword = "Some long keyword should be here"
        let text = "irrelevant prefix string here [" + keyword

        let rangeOfKeyword = text.range(of: keyword)!
        let locationOfKeyword = text.location(for: rangeOfKeyword.lowerBound)

        for location in 0..<locationOfKeyword {
            XCTAssertNil(text.interlinkKeyword(at: location))
        }
    }

    /// Verifies that `interlinkKeyword(at:)` returns the `[keyword substring` at the specified location
    /// We use a `sample text containing [a simplenote innerlink`, and verify the keyword on the left hand side is always returned
    ///
    func testInterlinkKeywordReturnsTheTextOnTheLeftHandSideOfTheSpecifiedLocationAndPerformsSuper() {
        let keyword = "Some long keyword should be here"
        let lhs = String(repeating: "an extremely long text should probably go here ", count: 2048)
        let text = lhs + "[" + keyword

        let rangeOfKeyword = text.range(of: keyword)!
        let locationOfKeyword = text.location(for: rangeOfKeyword.lowerBound)

        for location in locationOfKeyword...text.count {
            let currentIndex = text.index(for: location)
            let expectedKeywordSlice = String(text[rangeOfKeyword.lowerBound ..< currentIndex])
            let resultingKeywordSlice = text.interlinkKeyword(at: location) ?? ""

            XCTAssertEqual(resultingKeywordSlice, expectedKeywordSlice)
        }
    }

    /// Verifies that `interlinkKeyword(at:)` returns nil whenever the receiver contains an Opening Bracket, but no text
    ///
    func testInterlinkKeywordReturnsNilWheneverThereIsNoTextAfterOpeningBracket() {
        let text = "["
        XCTAssertNil(text.interlinkKeyword(at: .zero))
    }

    /// Verifies that `interlinkKeyword(at:)` returns nil whenever the receiver contains a properly closed Interlink
    ///
    func testInterlinkKeywordReturnsNilWheneverTheBracketsAreClosed() {
        let text = "irrelevant prefix string here [Some text should also go here maybe!]"

        for location in 0..<text.count {
            XCTAssertNil(text.interlinkKeyword(at: location))
        }
    }

    /// Verifies that `interlinkKeyword(at:)` can extract a new keyword being edited, located in between two closed keywords
    ///
    func testInterlinkKeywordReturnsTheProperSubstringWhenEditingSomeNewLinkInBetweenTwoProperlyFormedLinks() {
        let keyword = "new keyword"
        let text = "Hexadecimal is made up of [numbers](simplenote://note/123456) and [" + keyword + " [letters](simplenote://note/abcdef)."

        let rangeOfKeyword = text.range(of: keyword)!
        let keywordStart = text.location(for: rangeOfKeyword.lowerBound)
        let keywordEnd = text.location(for: rangeOfKeyword.upperBound)

        for location in keywordStart...keywordEnd {
            let currentIndex = text.index(for: location)
            let expectedKeywordSlice = String(text[rangeOfKeyword.lowerBound ..< currentIndex])
            let resultingKeywordSlice = text.interlinkKeyword(at: location) ?? ""

            XCTAssertEqual(resultingKeywordSlice, expectedKeywordSlice)
        }
    }

    /// Verifies that `containsUnbalancedClosingCharacter` returns true whenever the receiver contains unbalanced balanced `[]` pairs
    ///
    func testContainsUnbalancedClosingCharacterReturnsTrueWhenTheReceiverContainsUnbalancedClosingCharacters() {
        let samples = [
            "[][",
            "][]",
            "[[]][",
            "[[]]["
        ]

        for sample in samples {
            XCTAssertTrue(sample.containsUnbalancedClosingCharacter(opening: Character("["), closing: Character("]")))
        }
    }

    /// Verifies that `containsUnbalancedClosingCharacter` returns false whenever the receiver contains properly balanced `[]` pairs
    ///
    func testContainsUnbalancedClosingCharacterReturnsFalseWhenTheReceiverDoesNotContainUnbalancedClosingCharacters() {
        let samples = [
            "[]",
            "[[]]",
            "[[[]]]",
            "[][][]"
        ]

        for sample in samples {
            XCTAssertFalse(sample.containsUnbalancedClosingCharacter(opening: Character("["), closing: Character("]")))
        }
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns nil whenever the receiver does not contain any lookup keywords
    ///
    func testTrailingLookupKeywordReturnsNilWhenThereAreNoLookupKeywords() {
        let text = "qwertyuiop"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns nil whenever the receiver contains a closed keyword
    ///
    func testTrailingLookupKeywordReturnsNilWhenTheLookupKeywordIsClosedYetEmpty() {
        let text = "[]"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns nil whenever the receiver contains multiple closed keywords
    ///
    func testTrailingLookupKeywordReturnsNilWhenThereAreNoUnclosedLookupKeywords() {
        let text = "[keyword 1] lalalala [keyword 2] lalalalaa [keyword 3]"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns any trailing `[lookup keyword`
    /// - Note: It must not contain a closing `]`!
    ///
    func testTrailingLookupKeywordReturnsTheKeywordAfterTheOpeningCharacter() {
        let keyword = "some keyword here"
        let text = "qwertyuiop [" + keyword
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertEqual(result, keyword)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns the trailing `[lookup keyword`, whenever there's more than one keyword
    ///
    func testTrailingLookupKeywordReturnsTheLastKeywordWhenThereAreManyKeywords() {
        let keyword1 = "some keyword here"
        let keyword2 = "the real keyword"

        let text = "qwertyuiop [" + keyword1 + "] asdfghjkl [" + keyword2
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertEqual(result, keyword2)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` works as expected, when the receiver actually starts with the `[lookup keyword`
    ///
    func testTrailingLookupKeywordWorksAsExpectedWheneverTheInputStringStartsWithTheOpeningCharacter() {
        let keyword = "some keyword here"
        let text = "[" + keyword
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertEqual(result, keyword)
    }

    /// Verifies that `trailingLookupKeyword(opening: closing)` returns nil whenever the receiver only contains an  opening character `[`
    ///
    func testTrailingLookupKeywordReturnsNilWhenTheActualKeywordIsEmpty() {
        let text = "["
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }



    /// Verifies that `split(at:)` properly cuts the receiver at the specified location
    ///
    func testSplitAtLocationReturnsTheExpectedSubstrings() {
        let lhs = "some random text on the left hand side"
        let rhs = "and some more random text on the right hand side"
        let text = lhs + rhs

        let (splitLHS, splitRHS) = text.split(at: lhs.count)
        XCTAssertEqual(lhs, splitLHS)
        XCTAssertEqual(rhs, splitRHS)
    }

    /// Verifies that `split(at:)` properly handles Empty Strings
    ///
    func testSplitAtLocationReturnsEmptyStringsWhenTheReceiverIsEmpty() {
        let (lhs, rhs) = "".split(at: .zero)

        XCTAssertTrue(lhs.isEmpty)
        XCTAssertTrue(rhs.isEmpty)
    }

    /// Verifies that `split(at:)` returns an empty `RHS` string, whenever the cut location matches the end of the receiver
    ///
    func testSplitAtLocationProperlyHandlesLocationsAtTheEndOfTheString() {
        let text = "this is supposed to be a single but relatively long line of text"
        let (lhs, rhs) = text.split(at: text.count)

        XCTAssertEqual(lhs, text)
        XCTAssertEqual(rhs, "")
    }



    /// Verifies that `relativeLocation(for: in:)` does not alter the Location, whenever the specified Range covers the full string
    ///
    func testRelativeLocationForLocationReturnsTheUnmodifiedLocationWhenTheRangeEnclosesTheFullString() {
        let text = "this is supposed to be a single but relatively long line of text"

        let substringRange = text.startIndex ..< text.endIndex
        let substringStart = text.location(for: substringRange.lowerBound)
        let substringEnd = text.location(for: substringRange.upperBound)

        for location in substringStart..<substringEnd {
            XCTAssertEqual(text.relativeLocation(for: location, in: substringRange), location)
        }
    }

    /// Verifies that `relativeLocation(for: in:)` converts the specified Absolute Location into a Relative Location, with regards of a specified range
    ///
    func testRelativeLocationForLocationReturnsTheExpectedLocationWhenTheRangeIsNotTheFullString() {
        let text = "this is supposed to be a single but relatively long line of text"

        let substringRange = text.range(of: "line of text")!
        let substringStart = text.location(for: substringRange.lowerBound)
        let substringEnd = text.location(for: substringRange.upperBound)

        for location in substringStart..<substringEnd {
            XCTAssertEqual(text.relativeLocation(for: location, in: substringRange), location - substringStart)
        }
    }



    /// Verifies that `line(at:)` returns a touple with Range + Text for the Line at the specified Location
    ///
    func testLineAtLocationReturnsTheExpectedLineForTheSpecifiedLocation() {
        let lines = [
            "alala lala long long le long long long!\n",
            "this is supposed to be the second line\n",
            "and this would be the third line in the document\n",
            "only to be followed by a trailing and final line!"
        ]

        let text = lines.joined()
        var padding = Int.zero

        for line in lines {
            for location in Int.zero ..< line.count {
                let (_, lineText) = text.line(at: location + padding)!
                XCTAssertEqual(lineText, line)
            }

            padding += line.count
        }
    }



    /// Verifies that `rangeOfLine(at:)` returns `nil` whenever the specified location exceeds the receiver's length.
    ///
    func testLineAtLocationReturnsNilWheneverTheLocationExceedsTheValidBounds() {
        let text = "text and some more text yes!"
        let locationStart = text.count + 1
        let locationEnd = text.count * 2

        for location in locationStart ..< locationEnd {
            XCTAssertNil(text.rangeOfLine(at: location))
        }
    }
}

