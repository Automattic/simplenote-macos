import XCTest
@testable import Simplenote


// MARK: - String+Interlink Unit Tests
//
class StringInterlinkTests: XCTestCase {

    ///
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

    ///
    ///
    func testInterlinkKeywordReturnsTheTextOnTheLeftHandSideOfTheSpecifiedLocation() {
        let keyword = "Some long keyword should be here"
        let lhs = "irrelevant prefix string here"
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

    ///
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

    ///
    ///
    func testInterlinkKeywordReturnsNilWheneverThereIsNoTextAfterOpeningBracket() {
        let text = "["
        XCTAssertNil(text.interlinkKeyword(at: .zero))
    }

    ///
    ///
    func testInterlinkKeywordReturnsNilWheneverTheBracketsAreClosed() {
        let text = "irrelevant prefix string here [Some text should also go here maybe!]"

        for location in 0..<text.count {
            XCTAssertNil(text.interlinkKeyword(at: location))
        }
    }

    ///
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

            NSLog("# Expected: \(expectedKeywordSlice) Resulting: \(resultingKeywordSlice)")
            XCTAssertEqual(resultingKeywordSlice, expectedKeywordSlice)
        }
    }

    ///
    ///
    func testTrailingLookupKeywordReturnsNilWhenThereAreNoLookupKeywords() {
        let text = "qwertyuiop"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    ///
    ///
    func testTrailingLookupKeywordReturnsNilWhenTheLookupKeywordIsClosedYetEmpty() {
        let text = "[]"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    ///
    ///
    func testTrailingLookupKeywordReturnsNilWhenThereAreNoUnclosedLookupKeywords() {
        let text = "[keyword 1] lalalala [keyword 2] lalalalaa [keyword 3]"
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    ///
    ///
    func testTrailingLookupKeywordReturnsTheKeywordAfterTheOpeningCharacter() {
        let keyword = "some keyword here"
        let text = "qwertyuiop [" + keyword
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertEqual(result, keyword)
    }

    ///
    ///
    func testTrailingLookupKeywordReturnsTheLastKeywordWhenThereAreManyKeywords() {
        let keyword1 = "some keyword here"
        let keyword2 = "the real keyword"

        let text = "qwertyuiop [" + keyword1 + "] asdfghjkl [" + keyword2
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertEqual(result, keyword2)
    }

    ///
    ///
    func testTrailingLookupKeywordWorksAsExpectedWheneverTheInputStringStartsWithTheOpeningCharacter() {
        let keyword = "some keyword here"
        let text = "[" + keyword
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertEqual(result, keyword)
    }

    ///
    ///
    func testTrailingLookupKeywordReturnsNilWhenTheActualKeywordIsEmpty() {
        let text = "["
        let result = text.trailingLookupKeyword(opening: "[", closing: "]")

        XCTAssertNil(result)
    }

    ///
    ///
    func testSplitAtLocationReturnsTheExpectedSubstrings() {
        let lhs = "some random text on the left hand side"
        let rhs = "and some more random text on the right hand side"
        let text = lhs + rhs

        let (splitLHS, splitRHS) = text.split(at: lhs.count)
        XCTAssertEqual(lhs, splitLHS)
        XCTAssertEqual(rhs, splitRHS)
    }

    ///
    ///
    func testSplitAtLocationReturnsEmptyStringsWhenTheReceiverIsEmpty() {
        let (lhs, rhs) = "".split(at: .zero)

        XCTAssertTrue(lhs.isEmpty)
        XCTAssertTrue(rhs.isEmpty)
    }

    ///
    ///
    func testSplitAtLocationProperlyHandlesLocationsAtTheEndOfTheString() {
        let text = "this is supposed to be a single but relatively long line of text"
        let (lhs, rhs) = text.split(at: text.count)

        XCTAssertEqual(lhs, text)
        XCTAssertEqual(rhs, "")
    }

    ///
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

    ///
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

    ///
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

    ///
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

