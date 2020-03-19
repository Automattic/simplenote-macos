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
        let lines = sampleText
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
        let sample = "- L1\n- L2\n- L3"
        let expected = "- L1\n- L3"
        let targetRange = NSRange(location: 5, length: 5)

        textView.string = sample
        textView.removeText(at: targetRange)

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

    /// Verifies that `processTabInsertion` does nothing if there are no lists at the selected range
    ///
    func testProcessTabInsertionDoesNotIndentWheneverThereAreNoListsInTheCurrentRange() {
        let lines = sampleText
        let text = lines.joined()
        textView.string = text

        XCTAssertFalse(textView.processTabInsertion())
        XCTAssertEqual(textView.string, text)
    }
}


// MARK: -
//
private extension NSTextViewSimplenoteTests {

    var samplesForIndentation: [(text: String, indented: String)] {
        let marker = String.attachmentString
        return [
            (text: "- L1",   indented: "\t- L1"),
            (text: "\t- L2", indented: "\t\t- L2"),
            (text: "  - L3", indented: "\t  - L3"),
            (text: "* L1",   indented: "\t* L1"),
            (text: "\t* L2", indented: "\t\t* L2"),
            (text: "  * L3", indented: "\t  * L3"),
            (text: "+ L1",   indented: "\t+ L1"),
            (text: "\t+ L2", indented: "\t\t+ L2"),
            (text: "  + L3", indented: "\t  + L3"),
            (text: marker + " L1", indented: "\t" + marker + " L1"),
        ]
    }

    var sampleText: [String] {
        return [
            "Here comes the sun, here comes the sun\n",
            "And I say it's all right\n",
            "Little darling, it's been a long cold lonely winter\n",
            "Little darling, it feels like years since it's been here"
        ]
    }
}
