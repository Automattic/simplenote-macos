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
