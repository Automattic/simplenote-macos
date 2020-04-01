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

    /// Verifies that `shouldChangeTextInRange` returns `true` whenever the replacement string is null. We expect the TextView's default
    /// behavior in such cases.
    ///
    func testShouldChangeTextReturnsFalseWheneverTheStringIsNil() {
        let output = inputHandler.textView(textView, shouldChangeTextInRange: .zero, string: nil)
        XCTAssertTrue(output)
    }

    /// Verifies that `shouldChangeTextInRange` returns `true` whenever the resulting string does not require Markdown Lists Processing.
    ///
    func testShouldChangeTextReturnsFalseWheneverTheResultingDocumentDoesNotRequireExtraProcessing() {
        let initialText = "Auto"
        let replacementText = "mattic"
        let replacementRange = NSRange(location: initialText.utf16.count, length: .zero)

        textView.displayNote(content: initialText)
        let output = inputHandler.textView(textView, shouldChangeTextInRange: replacementRange, string: replacementText)

        XCTAssertTrue(output)
    }

    /// Verifies that `shouldChangeTextInRange` returns `false` whenever the resulting document contains at least one Markdown Item
    /// that must be processed (replaced by a NSTextAttachment)
    ///
    func testShouldChangeTextReturnsFalseAndInsertsTextAttachmentsWhenInputParametersAreValid() {
        let initialText = "- [ "
        let replacementText = "]"
        let expectedText = initialText + replacementText
        let replacementRange = NSRange(location: initialText.utf16.count, length: .zero)

        textView.displayNote(content: initialText)
        let output = inputHandler.textView(textView, shouldChangeTextInRange: replacementRange, string: replacementText)

        XCTAssertFalse(output)
        XCTAssertTrue(textView.attributedString().containsAttachments)
        XCTAssertEqual(textView.plainTextContent(), expectedText)
    }

    /// Verifies that `shouldChangeTextInRange` performs the requested Replacement OP in the TextView, and correctly sets the Selected Range
    /// right after the newly inserted text.
    ///
    func testShouldChangeTextPerformsReplacementOPAndSetsExpectedRangeAfterInsertedContent() {
        let initialHead = "Heading" + .newline + .newline
        let initialTail = .newline + "Tail"

        let replaceText = "- [ ] L1" + .newline + "- [ ] L2" + .newline + "LINE" + .newline
        let replaceRange = NSRange(location: initialHead.utf16.count, length: .zero)

        let initialText = initialHead + initialTail
        let expectedText = initialHead + replaceText + initialTail

        // Account for "Processed" List Items: the expected Selected Range should be shorter than the actual string length
        let replacementLengthDelta = "- [ ] ".utf16.count - String.richListMarker.utf16.count
        let expectedLocation = initialHead.utf16.count + replaceText.utf16.count - replacementLengthDelta * 2
        let expectedSelectedRange = NSRange(location: expectedLocation, length: .zero)

        // And finally.. perform the actual OPs
        textView.displayNote(content: initialText)
        textView.setSelectedRange(replaceRange)

        let output = inputHandler.textView(textView, shouldChangeTextInRange: replaceRange, string: replaceText)
        XCTAssertFalse(output)
        XCTAssertEqual(textView.plainTextContent(), expectedText)
        XCTAssertEqual(textView.selectedRange(), expectedSelectedRange)
    }

    /// Verifies that `shouldChangeTextInRange` performs an *undoable* operation whenever the resulting string contains at least one
    /// Markdown List Item.
    ///
    func testShouldChangeTextMarkdownReplacementOperationIsUndoableAndRunningSuchResultsInTheInitialString() {
        let initialText = "- [ "
        let replacementText = "]"
        let replacementRange = NSRange(location: initialText.utf16.count, length: .zero)

        textView.displayNote(content: initialText)

        let output = inputHandler.textView(textView, shouldChangeTextInRange: replacementRange, string: replacementText)
        XCTAssertFalse(output)

        XCTAssertTrue(textView.internalUndoManager.canUndo)
        textView.internalUndoManager.undo()

        XCTAssertEqual(textView.plainTextContent(), initialText)
    }

    /// Verifies that `shouldChangeTextInRange` posts a `textDidChange` notification whenever the Replacement OP is handled by itself.
    ///
    func testShouldChangeTextReplacementOperationPostsOneTextDidChangeNotification() {
        let replacementText = "- [ ]"
        let replacementRange = NSRange.zero

        textView.displayNote(content: replacementText)
        XCTAssertTrue(delegate.receivedTextDidChangeNotifications.isEmpty)

        let output = inputHandler.textView(textView, shouldChangeTextInRange: replacementRange, string: replacementText)
        XCTAssertFalse(output)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 1)
    }
}
