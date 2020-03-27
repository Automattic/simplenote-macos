import XCTest
@testable import Simplenote


// MARK: - TextViewInputHandler Tests
//
class TextViewInputHandlerTests: XCTestCase {

    /// Testing InputHandler
    ///
    let inputHandler = TextViewInputHandler()

    /// Mockup TextView
    ///
    let textView = MockupTextView()

    /// Mockup TextViewDelegate
    ///
    let delegate = MockupTextViewDelegate()


    // MARK: - Overridden

    override func setUp() {
        textView.string = ""
        textView.delegate = delegate
        textView.internalUndoManager.removeAllActions()

        delegate.reset()
    }

    /// Verifies that `shouldChangeTextInRanges` returns `true` whenever the replacement strings are null. We expect the TextView's default
    /// behavior in such cases.
    ///
    func testShouldChangeTextReturnsNilWheneverTheStringsArrayIsNil() {
        let output = inputHandler.textView(textView, shouldChangeTextInRanges: [], strings: nil)
        XCTAssertTrue(output)
    }

    /// Verifies that `shouldChangeTextInRanges` returns `true` whenever the two input arrays don't have the same size
    ///
    func testShouldChangeTextReturnsTrueWheneverInputArraysDoNotMatch() {
        let range = NSRange(location: .zero, length: .zero)
        let rangeAsValue = NSValue(range: range)

        let output = inputHandler.textView(textView, shouldChangeTextInRanges: [rangeAsValue], strings: [])
        XCTAssertTrue(output)
    }

    /// Verifies that `shouldChangeTextInRanges` returns `true` whenever the resulting text does not require a new TextAttachment
    ///
    func testShouldChangeTextReturnsTrueWheneverTheResultingTextDoesNotRequireNewAttachments() {
        let text = "Lorem Ipsum Text"

        let range = NSRange(location: .zero, length: .zero)
        let rangeAsValue = NSValue(range: range)

        let output = inputHandler.textView(textView, shouldChangeTextInRanges: [rangeAsValue], strings: [text])
        XCTAssertTrue(output)
    }

    /// Verifies that `shouldChangeTextInRanges` returns `false` when the resulting string (after the proposed edition) contains at least
    /// one Markdown List Item
    ///
    func testShouldChangeTextReturnsFalseAndInsertsTextAttachmentsWhenResultingStringContainsListMarkers() {
        let initialText = "- [ "
        let replacementText = "]"
        let expectedText = initialText + replacementText

        let replacementRange = NSRange(location: initialText.utf16.count, length: .zero)
        let replacementAsValue = NSValue(range: replacementRange)

        textView.displayNote(content: initialText)
        let output = inputHandler.textView(textView, shouldChangeTextInRanges: [replacementAsValue], strings: [replacementText])

        XCTAssertFalse(output)
        XCTAssertTrue(textView.attributedString().containsAttachments)
        XCTAssertEqual(textView.plainTextContent(), expectedText)
    }

    /// Verifies that `shouldChangeTextInRanges` performs an *undoable* operation whenever the resulting string contains at least one
    /// Markdown List Item.
    ///
    func testShouldChangeTextMarkdownReplacementOperationIsUndoableAndRunningSuchResultsInTheInitialString() {
        let initialText = "- [ "
        let replacementText = "]"

        let replacementRange = NSRange(location: initialText.utf16.count, length: .zero)
        let replacementAsValue = NSValue(range: replacementRange)

        textView.displayNote(content: initialText)
        let output = inputHandler.textView(textView, shouldChangeTextInRanges: [replacementAsValue], strings: [replacementText])

        XCTAssertFalse(output)

        XCTAssertTrue(textView.internalUndoManager.canUndo)
        textView.internalUndoManager.undo()

        XCTAssertEqual(textView.plainTextContent(), initialText)
    }

    /// Verifies that `shouldChangeTextInRanges` posts a `textDidChange` notification whenever the Replacement OP is handled by the
    /// TextInputHandler itself.
    ///
    func testShouldChangeTextReplacementOperationPostsOneTextDidChangeNotification() {
        let replacementText = "- [ ]"
        let replacementRange = NSRange(location: .zero, length: .zero)
        let replacementAsValue = NSValue(range: replacementRange)


        textView.displayNote(content: replacementText)
        XCTAssertTrue(delegate.receivedTextDidChangeNotifications.isEmpty)

        let output = inputHandler.textView(textView, shouldChangeTextInRanges: [replacementAsValue], strings: [replacementText])
        XCTAssertFalse(output)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 1)
    }
}
