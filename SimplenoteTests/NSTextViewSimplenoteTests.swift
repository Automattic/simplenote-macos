import XCTest
@testable import Simplenote


// MARK: - NSAttributedStringToMarkdownConverter Unit Tests
//
class NSTextViewSimplenoteTests: XCTestCase {

    /// TextView!
    ///
    private var textView: NSTextView!


    // MARK: - Overridden Methods

    override func setUp() {
        textView = NSTextView()
    }

    /// Verifies that `lineAtSelectedRange` returns the expected line Range / String
    ///
    func testLineAtSelectedRangeEffectivelyReturnsTheLineAtTheSelectedRange() {
        let lines = [
            "Here comes the sun, here comes the sun\n",
            "And I say it's all right\n",
            "Little darling, it's been a long cold lonely winter\n",
            "Little darling, it feels like years since it's been here"
        ]

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
    func testRemoveTextNukesSpecifiedRangeAndNotifiesDelegate() {
        let sample = "- L1\n- L2\n- L3"
        let expected = "- L1\n- L3"
        let targetRange = NSRange(location: 5, length: 5)

        textView.string = sample
        textView.removeText(at: targetRange)

        XCTAssertEqual(textView.string, expected)
    }
}
