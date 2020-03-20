import XCTest
@testable import Simplenote


// MARK: - NSAttributedStringToMarkdownConverter Unit Tests
//
class NSTextViewSimplenoteTests: XCTestCase {

    /// TextView!
    ///
    private var textView = NSTextView()


    // MARK: - Overridden Methods

    override func setUp() {
        textView.string = String()
    }

    /// Verifies that `lineAtSelectedRange` returns the expected line Range / String
    ///
    func testLineAtSelectedRangeEffectivelyReturnsTheLineAtTheSelectedRange() {
        let lines = samplePlainText
        let text = lines.joined()
        textView.string = text

        var absoluteLocation = Int.zero
        for expectedLine in lines {

            for relativeLocation in Int.zero ..< expectedLine.count {
                let selectecRange = NSRange(location: absoluteLocation + relativeLocation, length: .zero)
                textView.setSelectedRange(selectecRange)

                let (retrievedRange, retrievedLine) = textView.lineAtSelectedRange()
                XCTAssertEqual(retrievedLine, expectedLine)
                XCTAssertEqual(text.asNSString.substring(with: retrievedRange), expectedLine)
            }

            absoluteLocation += expectedLine.count
        }
    }

    /// Verifies that `lineAtSelectedRange` does not trigger any exception when the TextView is empty
    ///
    func testLineAtSelectedRangeDoesNotCrashWithEmptyStrings() {
        let (range, line) = textView.lineAtSelectedRange()

        XCTAssertEqual(line, String())
        XCTAssertEqual(range, NSRange(location: .zero, length: .zero))
    }

    /// Verifies that `removeText(at:)` effectively nukes the text at the specified range
    ///
    func testRemoveTextNukesSpecifiedRange() {
        let sample = samplePlainText.joined()
        let expected = samplePlainText.dropFirst().joined()
        let range = NSRange(location: .zero, length: samplePlainText[0].utf16.count)

        textView.string = sample
        textView.removeText(at: range)

        XCTAssertEqual(textView.string, expected)
    }

    /// Verifies that `processTabInsertion` indents the List at the selected range
    ///
    func testProcessTabInsertionEffectivelyIndentsTextListsWhenTheCurrentLineContainsSomeListMarker() {
        for (text, indented) in samplesForIndentation {
            textView.string = text

            let selectedRange = NSRange(location: .zero, length: .zero)
            textView.setSelectedRange(selectedRange)

            XCTAssertTrue(textView.processTabInsertion())
            XCTAssertEqual(textView.string, indented)
        }
    }

    /// Verifies that `processTabInsertion` does nothing if there are no lists at the document
    ///
    func testProcessTabInsertionDoesNotIndentWheneverThereAreNoListsInTheCurrentRange() {
        let text = samplePlainText.joined()
        textView.string = text

        XCTAssertFalse(textView.processTabInsertion())
        XCTAssertEqual(textView.string, text)
    }

    /// Verifies that `processNewlineInsertion` does nothing if there are no lists in the document
    ///
    func testProcessNewlineInsertionDoesNothingWheneverThereAreNoListsInTheDocument() {
        let text = samplePlainText.joined()
        textView.string = text

        XCTAssertFalse(textView.processNewlineInsertion())
        XCTAssertEqual(textView.string, text)
    }

    /// Verifies that `processNewlineInsertion` does nothing whenever the Selected Range is set to the left hand side of the list marker
    ///
    func testProcessNewlineInsertionDoesNotInsertNewListMarkerWheneverTheSelectedLocationIsBeforeTheCurrentLineMarker() {
        for (sample, _) in samplesForNewline {
            guard let rangeOfMarker = sample.rangeOfListMarker else {
                XCTFail()
                continue
            }

            textView.string = sample

            for location in 0...rangeOfMarker.location {
                let newSelectedRange = NSRange(location: location, length: .zero)
                textView.setSelectedRange(newSelectedRange)

                XCTAssertFalse(textView.processNewlineInsertion())
                XCTAssertEqual(textView.string, sample)
            }
        }
    }

    /// Verifies that `processNewlineInsertion` cleans up empty list lines, when hitting return at the end
    ///
    func testProcessNewlineRemovesListMarkerWhenHittingReturnAtTheEndOfAnEmptyListLine() {
        for sample in samplesForNewlineRemoval {
            textView.string = sample

            let newSelectedRange = NSRange(location: sample.utf16.count, length: .zero)
            textView.setSelectedRange(newSelectedRange)

            XCTAssertTrue(textView.processNewlineInsertion())
            XCTAssertEqual(textView.string, "")
        }
    }


    /// Verifies that `processNewlineInsertion` effectively inserts a new bullet (with padding + tail) whenever we're at the end of a list, and hit return
    ///
    func testProcessNewlineInsertionEffectivelyInsertsBulletInNewlineWithPrefixAndSuffixWhenAppropriate() {
        for (sample, expected) in samplesForNewline {
            textView.string = sample

            let newSelectedRange = NSRange(location: sample.utf16.count, length: .zero)
            textView.setSelectedRange(newSelectedRange)

            XCTAssertTrue(textView.processNewlineInsertion())
            XCTAssertEqual(textView.string, expected)
        }
    }
}


// MARK: - Helpers!
//
private extension NSTextViewSimplenoteTests {

    var samplesForIndentation: [(text: String, indented: String)] {
        let marker = String.attachmentString
        return [
            (text: "- L1",          indented: "\t- L1"),
            (text: "\t- L2",        indented: "\t\t- L2"),
            (text: "  - L3",        indented: "\t  - L3"),
            (text: "* L1",          indented: "\t* L1"),
            (text: "\t* L2",        indented: "\t\t* L2"),
            (text: "  * L3",        indented: "\t  * L3"),
            (text: "+ L1",          indented: "\t+ L1"),
            (text: "\t+ L2",        indented: "\t\t+ L2"),
            (text: "  + L3",        indented: "\t  + L3"),
            (text: marker + " L1",  indented: "\t" + marker + " L1"),
        ]
    }

    var samplesForNewline: [(text: String, enhanced: String)] {
        let marker = String.attachmentString
        return [
            (text: "- L1",          enhanced: "- L1\n- "),
            (text: "\t- L2",        enhanced: "\t- L2\n\t- "),
            (text: "  - L3",        enhanced: "  - L3\n  - "),
            (text: "* L1",          enhanced: "* L1\n* "),
            (text: "\t* L2",        enhanced: "\t* L2\n\t* "),
            (text: "  * L3",        enhanced: "  * L3\n  * "),
            (text: "+ L1",          enhanced: "+ L1\n+ "),
            (text: "\t+ L2",        enhanced: "\t+ L2\n\t+ "),
            (text: "  + L3",        enhanced: "  + L3\n  + "),
            (text: marker + " L1",  enhanced: marker + " L1\n" + marker + String.space),
        ]
    }

    var samplesForNewlineRemoval: [String] {
        let marker = String.attachmentString
        return [
            "-",
            "\t- ",
            "  - ",
            "* ",
            "\t* ",
            "  * ",
            "+ ",
            "\t+ ",
            "  + ",
            marker,
            "\t\t\t" + marker
        ]
    }

    var samplePlainText: [String] {
        return [
            "Here comes the sun, here comes the sun\n",
            "And I say it's all right\n",
            "Little darling, it's been a long cold lonely winter\n",
            "Little darling, it feels like years since it's been here"
        ]
    }
}
