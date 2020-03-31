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

    /// Verifies that `shouldChangeTextInRanges` returns `true` whenever both, Ranges and Strings, are empty
    ///
    func testShouldChangeTextReturnsFalseWhenBothRangesAndStringsAreEmpty() {
        let output = inputHandler.textView(textView, shouldChangeTextInRanges: [], strings: [])
        XCTAssertTrue(output)
    }

    /// Verifies that `shouldChangeTextInRanges` returns `false` when:
    ///
    ///     1.  Ranges and Strings arrays are not empty, and their number of elements match
    ///     2.  UndoManager is not nil
    ///     3.  TextStorage is also not nil
    ///
    func testShouldChangeTextReturnsFalseAndInsertsTextAttachmentsWhenInputParametersAreValid() {
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

    /// Verifies that `shouldChangeTextInRanges` performs the requested Replacement OP in the TextView, and correctly sets the Selected Range
    /// right after the newly inserted text.
    ///
    func testShouldChangeTextPerformsReplacementOPAndSetsExpectedRangeAfterInsertedContent() {
        // Insert a string in between
        let initialHead = "Heading\n\n"
        let initialTail = "\nTail"

        let replaceText = "- [ ] L1\n- [ ] L2\nLINE\n"
        let replaceRange = NSRange(location: initialHead.utf16.count, length: .zero)
        let replaceRangeAsValue = NSValue(range: replaceRange)

        let initialText = initialHead + initialTail
        let expectedText = initialHead + replaceText + initialTail

        // Account for "Processed" List Items: the expected Selected Range should be shorter than the actual string length
        let replacementLengthDelta = "- [ ] ".utf16.count - String.richListMarker.utf16.count
        let expectedLocation = initialHead.utf16.count + replaceText.utf16.count - replacementLengthDelta * 2
        let expectedSelectedRange = NSRange(location: expectedLocation, length: .zero)

        // And finally.. perform the actual OPs
        textView.displayNote(content: initialText)
        textView.setSelectedRange(replaceRange)

        let output = inputHandler.textView(textView, shouldChangeTextInRanges: [replaceRangeAsValue], strings: [replaceText])

        XCTAssertFalse(output)
        XCTAssertEqual(textView.plainTextContent(), expectedText)
        XCTAssertEqual(textView.selectedRange(), expectedSelectedRange)
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
