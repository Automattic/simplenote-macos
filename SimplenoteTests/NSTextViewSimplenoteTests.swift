import XCTest
@testable import Simplenote


// MARK: - NSAttributedStringToMarkdownConverter Unit Tests
//
class NSTextViewSimplenoteTests: XCTestCase {

    /// TextView!
    ///
    private var textView = MockupTextView()

    /// Mockup TextViewDelegate
    ///
    private let delegate = MockupTextViewDelegate()


    // MARK: - Overridden Methods

    override func setUp() {
        textView.delegate = delegate
        textView.string = String()
        textView.internalUndoManager.removeAllActions()

        delegate.reset()
    }

    /// Verifies that `attributedSubstring` yields the expected substring
    ///
    func testAttributedSubstringReturnsTheExpectedText() {
        let text = samplePlainText.joined()
        textView.string = text

        let result = textView.attributedSubstring(from: .zero, length: text.utf16.count)
        XCTAssertEqual(result.string, text)
    }


    /// Verifies that `selectedLineDroppingTrailingNewline` returns the expected line Range / String, excluding trailing newlines
    ///
    func testSelectedLineDroppingTrailingNewlineEffectivelyReturnsTheLineAtTheSelectedRange() {
        let lines = samplePlainText
        let text = lines.joined()
        textView.string = text

        var absoluteLocation = Int.zero
        for line in lines {

            for relativeLocation in Int.zero ..< line.count {
                let selectecRange = NSRange(location: absoluteLocation + relativeLocation, length: .zero)
                textView.setSelectedRange(selectecRange)

                let (retrievedRange, retrievedLine) = textView.selectedLineDroppingTrailingNewline()
                let expectedLine = line.dropTrailingNewline()

                XCTAssertEqual(retrievedLine, expectedLine)
                XCTAssertEqual(text.asNSString.substring(with: retrievedRange), expectedLine)
            }

            absoluteLocation += line.count
        }
    }

    /// Verifies that `lineAtSelectedRange` does not trigger any exception when the TextView is empty
    ///
    func testSelectedLineDroppingTrailingNewlineDoesNotCrashOnEmptyStrings() {
        let (range, line) = textView.selectedLineDroppingTrailingNewline()

        XCTAssertEqual(line, String())
        XCTAssertEqual(range, .zero)
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

    /// Verifies that `performUndoableReplacement(at:string:)` updates the specified (Range,  String) and posts a textDidChange Note.
    ///
    func testPerformUndoableReplacementWithStringReplacesTextAndPostsTextDidChangeNotification() {
        let sample = samplePlainText.dropFirst().joined()
        let replacement = samplePlainText[.zero]
        let expected = samplePlainText.joined()

        textView.string = sample
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, .zero)

        textView.performUndoableReplacement(at: .zero, string: replacement)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 1)

        XCTAssertEqual(textView.string, expected)
    }

    /// Verifies that `performUndoableReplacement(at:string:)` reverts the Replaced Text and post a TextDidChange Note on Undo.
    ///
    func testPerformUndoableReplacementWithStringRevertsReplacementeAndPostsTextDidChangeOnUndo() {
        let initial = samplePlainText.dropFirst().joined()
        let replacement = samplePlainText[.zero]

        textView.string = initial
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, .zero)

        textView.performUndoableReplacement(at: .zero, string: replacement)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 1)

        XCTAssertTrue(textView.internalUndoManager.canUndo)

        textView.internalUndoManager.undo()
        XCTAssertEqual(textView.string, initial)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 2)
    }

    /// Verifies that `performUndoableReplacement(at:string:)` restores the SelectedRange On Undo.
    ///
    func testPerformUndoableReplacementWithStringRestoresSelectedRangeOnUndo() {
        let initial = samplePlainText.dropFirst().joined()
        let replacement = samplePlainText[.zero]

        textView.string = initial

        textView.setSelectedRange(.zero)
        textView.performUndoableReplacement(at: .zero, string: replacement)
        XCTAssertEqual(textView.selectedRange.location, replacement.utf16.count)

        textView.internalUndoManager.undo()
        XCTAssertEqual(textView.selectedRange, .zero)
    }

    /// Verifies that `performUndoableReplacement(at:attrString:)` updates the specified (Range,  AttrString) and posts a textDidChange Note.
    ///
    func testPerformUndoableReplacementWithAttrStringReplacesTextAndPostsTextDidChangeNotification() {
        let sample = samplePlainText.dropFirst().joined()
        let replacement = NSAttributedString(string: samplePlainText[.zero])
        let expected = samplePlainText.joined()

        textView.string = sample
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, .zero)

        textView.performUndoableReplacement(at: .zero, attrString: replacement)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 1)

        XCTAssertEqual(textView.string, expected)
    }

    /// Verifies that `performUndoableReplacement(at:attrString:)` reverts the Replaced Text and post a TextDidChange Note on Undo.
    ///
    func testPerformUndoableReplacementWithAttrStringRevertsReplacementeAndPostsTextDidChangeOnUndo() {
        let initial = samplePlainText.dropFirst().joined()
        let replacement = NSAttributedString(string: samplePlainText[.zero])

        textView.string = initial
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, .zero)

        textView.performUndoableReplacement(at: .zero, attrString: replacement)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 1)

        XCTAssertTrue(textView.internalUndoManager.canUndo)

        textView.internalUndoManager.undo()
        XCTAssertEqual(textView.string, initial)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 2)
    }

    /// Verifies that `performUndoableReplacement(at:attrString:)` restores the SelectedRange On Undo.
    ///
    func testPerformUndoableReplacementWithAttrStringRestoresSelectedRangeOnUndo() {
        let initial = samplePlainText.dropFirst().joined()
        let replacement = NSAttributedString(string: samplePlainText[.zero])

        textView.string = initial

        textView.setSelectedRange(.zero)
        textView.performUndoableReplacement(at: .zero, attrString: replacement)
        XCTAssertEqual(textView.selectedRange.location, replacement.length)

        textView.internalUndoManager.undo()
        XCTAssertEqual(textView.selectedRange, .zero)
    }

    /// Verifies that `performUndoableReplacementAndProcessLists(at:string:)` updates the specified (Range,  AttrString) and posts a textDidChange Note.
    ///
    func testPerformUndoableReplacementsProcessingListsReplacesTextAndPostsTextDidChangeNotification() {
        let sample = sampleListText.dropFirst().joined()
        let replacement = sampleListText[.zero]
        let expected = sampleListText.joined()

        textView.string = sample
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, .zero)

        textView.performUndoableReplacementAndProcessLists(at: .zero, string: replacement)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 1)

        XCTAssertEqual(textView.plainTextContent(), expected)
    }

    /// Verifies that `performUndoableReplacementAndProcessLists(at:string:)` reverts the Replaced Text and post a TextDidChange Note on Undo.
    ///
    func testPerformUndoableReplacementsProcessingListsRevertsReplacementeAndPostsTextDidChangeOnUndo() {
        let sample = sampleListText.dropFirst().joined()
        let replacement = sampleListText[.zero]

        textView.string = sample
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, .zero)

        textView.performUndoableReplacementAndProcessLists(at: .zero, string: replacement)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 1)

        XCTAssertTrue(textView.internalUndoManager.canUndo)

        textView.internalUndoManager.undo()
        XCTAssertEqual(textView.plainTextContent(), sample)
        XCTAssertEqual(delegate.receivedTextDidChangeNotifications.count, 2)
    }

    /// Verifies that `performUndoableReplacementAndProcessLists(at:string:)` restores the SelectedRange On Undo.
    ///
    func testPerformUndoableReplacementsProcessingListsRestoresSelectedRangeOnUndo() {
        let initial = samplePlainText.dropFirst().joined()
        let replacement = samplePlainText[.zero]

        textView.string = initial

        textView.setSelectedRange(.zero)
        textView.performUndoableReplacementAndProcessLists(at: .zero, string: replacement)
        XCTAssertEqual(textView.selectedRange.location, replacement.utf16.count)

        textView.internalUndoManager.undo()
        XCTAssertEqual(textView.selectedRange, .zero)
    }

    /// Verifies that `processTabInsertion` indents the List at the selected range
    ///
    func testProcessTabInsertionEffectivelyIndentsTextListsWhenTheCurrentLineContainsSomeListMarker() {
        for (text, indented) in samplesForIndentation {
            textView.string = text
            textView.setSelectedRange(.zero)

            XCTAssertTrue(textView.processTabInsertion())
            XCTAssertEqual(textView.string, indented)
        }
    }

    /// Verifies that `processTabInsertion` registers an Undo OP when indenting Text Lists
    ///
    func testProcessTabInsertionRegistersAnUndoableOperationWhenIndentingTextLists() {
        let undoManager = textView.internalUndoManager

        for (initial, _) in samplesForIndentation {
            textView.string = initial
            textView.setSelectedRange(.zero)

            XCTAssertTrue(textView.processTabInsertion())
            XCTAssertTrue(undoManager.canUndo)

            undoManager.undo()
            XCTAssertEqual(textView.string, initial)
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

    /// Verifies that `processNewlineInsertion` registers an Undoable OP whenever a new list marker is inserted
    ///
    func testProcessNewlineRegistersAnUndoableOperationWhenRemovingListMarkersfromEmptyListLine() {
        let undoManager = textView.internalUndoManager

        for sample in samplesForNewlineRemoval {
            textView.string = sample

            let newSelectedRange = NSRange(location: sample.utf16.count, length: .zero)
            textView.setSelectedRange(newSelectedRange)

            XCTAssertTrue(textView.processNewlineInsertion())
            XCTAssertTrue(undoManager.canUndo)

            undoManager.undo()
            XCTAssertEqual(textView.string, sample)
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

    /// Verifies that `processNewlineInsertion` registers an Undoable OP whenever a new list marker is inserted
    ///
    func testProcessNewlineInsertionRegistersAnUndoableOperationWhenInsertingListMarkers() {
        let undoManager = textView.internalUndoManager

        for (initial, _) in samplesForNewline {
            textView.string = initial

            let newSelectedRange = NSRange(location: initial.utf16.count, length: .zero)
            textView.setSelectedRange(newSelectedRange)

            XCTAssertTrue(textView.processNewlineInsertion())
            XCTAssertTrue(undoManager.canUndo)

            undoManager.undo()
            XCTAssertEqual(textView.string, initial)
        }
    }

    /// Verifies that `processNewlineInsertion` effectively inserts a new bullet (with padding + tail) whenever we're at the end of a list, and hit return
    ///
    func testProcessNewlineInsertionEffectivelyInsertNewTextAttachmentInstance() {
        let sampleText = String.attachmentString + " L1"
        textView.string = sampleText

        // Inject the List Attachment
        let attachment = SPTextAttachment()
        let range = NSRange(location: .zero, length: String.attachmentString.utf16.count)
        textView.textStorage?.addAttribute(.attachment, value: attachment, range: range)

        // Select the tail of the first line
        let newSelectedRange = NSRange(location: textView.string.utf16.count, length: .zero)
        textView.setSelectedRange(newSelectedRange)

        XCTAssertTrue(textView.processNewlineInsertion())

        // Verify there are *two* different TextAttachment instances
        var attachments = Set<SPTextAttachment>()

        textView.attributedString().enumerateAttachments(of: SPTextAttachment.self) { (attachment, range) in
            XCTAssertFalse(attachments.contains(attachment))
            attachments.insert(attachment)
        }

        XCTAssertEqual(attachments.count, 2)
    }

    /// Verifies that `toggleListMarkersAtSelectedRange` inserts a List on empty documents
    ///
    func testToggleListMarkersAtSelectedRangeInsertsListMarkerOnEmptyDocument() {
        let sample = ""
        let expected: String = .attachmentString + .space

        textView.string = sample
        textView.toggleListMarkersAtSelectedRange()

        XCTAssertEqual(textView.string, expected)
    }

    /// Verifies that `toggleListMarkersAtSelectedRange` inserts List Markers on every line, ignoring the last empty one
    ///
    func testToggleListMarkersAtSelectedRangeIgnoresLastEmptyLine() {
        let sample = "L1" + .newline
        let expected: String = .attachmentString + .space + "L1" + .newline

        textView.string = sample
        textView.setSelectedRange(sample.asNSString.fullRange)
        textView.toggleListMarkersAtSelectedRange()

        XCTAssertEqual(textView.string, expected)
    }

    /// Verifies that `toggleListMarkersAtSelectedRange` inserts a List Marker on every selected line
    ///
    func testToggleListMarkersAtSelectedRangeInsertsListMarkerOnEveryLine() {
        let sample = [
            "L1" + .newline +
            "L2"
        ].joined()

        let expected = [
            .richListMarker + "L1" + .newline,
            .richListMarker + "L2"
        ].joined()

        textView.string = sample
        textView.setSelectedRange(sample.asNSString.fullRange)
        textView.toggleListMarkersAtSelectedRange()

        XCTAssertEqual(textView.string, expected)
    }

    /// Verifies that `toggleListMarkersAtSelectedRange` registers an Undoable OP when inserting List Markers on every line
    ///
    func testToggleListMarkersAtSelectedRangeRegistersAnUndoableOperationWhenInsertingListMarkers() {
        let sample = "L1" + .newline + "L2"

        textView.string = sample
        textView.setSelectedRange(sample.asNSString.fullRange)
        textView.toggleListMarkersAtSelectedRange()

        let undoManager = textView.internalUndoManager
        XCTAssertTrue(undoManager.canUndo)

        undoManager.undo()
        XCTAssertEqual(textView.string, sample)
    }

    /// Verifies that `toggleListMarkersAtSelectedRange` nukes all list markers from the SelectedRange, whenver there is at least one marker
    ///
    func testToggleListMarkersAtSelectedRangeRemovesAllMarkersWheneverThereWasAtLeastOneAttachmentInTheText() {
        let sample = [
            .space + "L1" + .newline,
            .tab + "L2" + .newline,
            .richListMarker + .newline,
            "L3" + .newline,
        ].joined()

        let expected = [
            .space + "L1" + .newline,
            .tab + "L2" + .newline,
            .newline,
            "L3" + .newline,
        ].joined()

        textView.string = sample
        textView.setSelectedRange(sample.asNSString.fullRange)
        textView.toggleListMarkersAtSelectedRange()

        XCTAssertEqual(textView.string, expected)
    }

    /// Verifies that `toggleListMarkersAtSelectedRange` removes all markers in the selected range
    ///
    func testToggleListMarkersAtSelectedRangeRemovesListMarkerAtSelectedRange() {
        let sample = [
            .space + .attachmentString + .space + "L1" + .newline,
            .tab + .attachmentString + .space + "L2" + .newline,
            .attachmentString + .space + .newline,
            .attachmentString + .space + "L3" + .newline,
        ]

        let expected = [
            .space + "L1" + .newline,
            .tab + "L2" + .newline,
            .attachmentString + .space + .newline,
            .attachmentString + .space + "L3" + .newline,
        ].joined()

        let rangeForFirstTwoLines = NSRange(location: .zero, length: sample[0].utf16.count + 2)

        textView.string = sample.joined()
        textView.setSelectedRange(rangeForFirstTwoLines)
        textView.toggleListMarkersAtSelectedRange()

        XCTAssertEqual(textView.string, expected)
    }

    /// Verifies that `displayNote` effectively replaces all of the List Markers (`- [ ]`) with a corresponding TextAttachment
    ///
    func testDisplayNoteAddsOneTextAttachmentPerValidListMarker() {
        let list = sampleListText
        let text = list.joined()

        textView.displayNote(content: text)

        let attrString = textView.attributedString()
        var attachments = Set<NSTextAttachment>()

        attrString.enumerateAttribute(.attachment, in: attrString.fullRange, options: []) { (attachment, _, _) in
            guard let attachment = attachment as? NSTextAttachment else {
                return
            }

            attachments.insert(attachment)
        }

        XCTAssertEqual(sampleListText.count, attachments.count)
    }

    /// Verifies that `plainTextContent` encodes (TextAttachment based) Lists as Markdown
    ///
    func testPlainTextContentEncodesTextAttachmentBasedListsAsMarkdown() {
        let sample = samplePlainText.joined()
        let expected = sampleListText.joined()

        textView.displayNote(content: sample)

        textView.setSelectedRange(sample.asNSString.fullRange)
        textView.toggleListMarkersAtSelectedRange()

        XCTAssertEqual(textView.plainTextContent(), expected)
    }

    /// Verifies that `toggleListMarkersAtSelectedRange` preserves the currently selected location
    ///
    func testToggleListMarkersAtSelectedRangeMovesCursorMatchingInsertedMarkerLength() {
        let text = "Automattic"

        textView.string = text + .newline + .newline
        textView.setSelectedRange(.zero)
        textView.toggleListMarkersAtSelectedRange()

        let selectedRange = textView.selectedRange()
        let expectedSelectedLocation = textView.string.asNSString.range(of: text).location
        XCTAssertEqual(selectedRange.location, expectedSelectedLocation)

        textView.toggleListMarkersAtSelectedRange()
        XCTAssertEqual(textView.selectedRange(), .zero)
    }

    /// Verifies that `toggleListMarkersAtSelectedRange` affects only the current line
    ///
    func testToggleListMarkerAtSelectedRangeAffectsOnlyCurrentLine() {
        let text = "L1\n"
        let expected: String = .richListMarker + "L1\n" + .richListMarker

        textView.string = text

        let lastLineRange = NSRange(location: text.utf16.count, length: .zero)
        textView.setSelectedRange(lastLineRange)
        textView.toggleListMarkersAtSelectedRange()

        textView.setSelectedRange(.zero)
        textView.toggleListMarkersAtSelectedRange()

        XCTAssertEqual(textView.string, expected)
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
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n",
            "Donec in arcu efficitur, aliquam nulla sed, venenatis justo.\n",
            "Nunc imperdiet sem quis ultricies efficitur.\n",
            "Sed a enim at justo dictum pellentesque sollicitudin sed enim."
        ]
    }

    var sampleListText: [String] {
        return [
            "- [ ] Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n",
            "- [ ] Donec in arcu efficitur, aliquam nulla sed, venenatis justo.\n",
            "- [ ] Nunc imperdiet sem quis ultricies efficitur.\n",
            "- [ ] Sed a enim at justo dictum pellentesque sollicitudin sed enim."
        ]
    }
}
