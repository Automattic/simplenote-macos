import Foundation


// MARK: - Simplenote API
//
extension NSTextView {

    /// Returns the Attributed Substring with the specified range
    ///
    func attributedSubstring(from start: Int, length: Int) -> NSAttributedString {
        let range = NSRange(location: start, length: length)
        return attributedString().attributedSubstring(from: range)
    }

    /// Replaces the receiver's contents at a given range, with the specified String, and registers the inverse OP in our UndoManager.
    /// This API will also process Markdown Lists: both the Replacement and List Processing will be undoable in a single step.
    ///
    @discardableResult
    func performUndoableReplacementAndProcessLists(at range: NSRange, string: String) -> Bool {
        registerUndoCheckpointAndPerform { storage in
            storage.replaceCharacters(in: range, with: string)
            storage.processChecklists(with: .simplenoteEditorTextColor)
        }
    }

    /// Returns the (Range, String) representing the line or lines at the Selected Range.
    ///
    /// - Important: The trailing `\n` will be dropped from both, the resulting String and Range.
    ///
    func selectedLineDroppingTrailingNewline() -> (NSRange, String) {
        let (range, line) = string.asNSString.line(at: selectedRange)

        let trimmedLine = line.dropTrailingNewline()
        let trimmedRange = NSRange(location: range.location, length: trimmedLine.utf16.count)

        return (trimmedRange, trimmedLine)
    }

    /// Inserts the specified Text at a given range, and ensures the document is linkified
    ///
    func insertTextAndLinkify(text: String, in range: Range<String.Index>) {
        registerUndoCheckpointAndPerform { storage in
            let range = string.utf16NSRange(from: range)
            storage.replaceCharacters(in: range, with: text)
            processLinksInDocumentAsynchronously()
        }
    }

    /// Removes the text at the specified range, and notifies the delegate.
    ///
    func removeText(at range: NSRange) {
        insertText(String(), replacementRange: range)
    }

    /// Indicates if the Character at the specified location is selected
    ///
    func isCharacterSelected(at charIndex: Int) -> Bool {
        for wrappedRange in selectedRanges where NSLocationInRange(charIndex, wrappedRange.rangeValue) {
            return true
        }

        return false
    }
}


// MARK: - Private!
//
private extension NSTextView {

    /// Registers an Undo Checkpoint, and performs a given block `in a transactional fashion`: an Undo Group will wrap its execution
    ///
    ///     1.  Registers an Undo Operation which is expected to restore the TextView to its previous state
    ///     2.  Wraps up a given `Block` within an Undo Group
    ///     3.  Post a TextDidChange Notification
    ///
    @discardableResult
    func registerUndoCheckpointAndPerform(block: (NSTextStorage) -> Void) -> Bool {
        guard let storage = textStorage, let undoManager = undoManager else {
            return false
        }

        undoManager.beginUndoGrouping()
        registerUndoCheckpoint(in: undoManager, storage: storage)
        block(storage)
        undoManager.endUndoGrouping()

        didChangeText()

        return true
    }

    /// Registers an Undo Checkpoint, which is expected to restore the receiver to its previous state:
    ///
    ///     1.  Restores the full contents of our TextStorage
    ///     2.  Reverts the SelectedRange
    ///     3.  Post a textDidChange Notification
    ///
    func registerUndoCheckpoint(in undoManager: UndoManager, storage: NSTextStorage) {
        let oldSelectedRange = selectedRange()
        let oldText = storage.attributedSubstring(from: storage.fullRange)

        undoManager.registerUndo(withTarget: self) { textView in
            // Register an Undo *during* an Undo? > Also known as Redo!
            textView.registerUndoCheckpoint(in: undoManager, storage: storage)

            // And the actual Undo!
            storage.replaceCharacters(in: storage.fullRange, with: oldText)
            textView.setSelectedRange(oldSelectedRange)
            textView.didChangeText()
        }
    }
}


// MARK: - I/O
//
extension NSTextView {

    /// Displays the specified Note's Contents
    ///
    ///     -   List Markers will be replaced by Text Attachments
    ///     -   Our UndoManager will be reset right after processing the Lists. Otherwise CTRL + Z would
    ///         result in Attachments replacee by `-[]`!
    ///     -   Links will be processed asynchronously
    ///
    @objc
    func displayNote(content: String) {
        string = content
        textStorage?.processChecklists(with: .simplenoteEditorTextColor)
        undoManager?.removeAllActions()
        processLinksInDocumentAsynchronously()
    }

    /// Returns the content represented as Plain Text
    ///
    @objc
    func plainTextContent() -> String {
        return NSAttributedStringToMarkdownConverter.convert(string: attributedString())
    }
}


// MARK: - Linkification
//
extension NSTextView {

    /// Asynchronously Processess Links in the Document
    ///
    @objc
    func processLinksInDocumentAsynchronously() {
        DispatchQueue.main.async(execute: processLinksInDocument)
    }

    /// Processess Links in the document
    ///
    /// - Important: This API temporarily disables the `delegate`.
    /// - Note: Invoking `checkTextInDocument` results in a call to`delegate.textDidChange`.
    ///         This causes the Editor to update the Note's Modification Date, and may affect the List Sort Order (!)
    ///
    func processLinksInDocument() {
        /// Disable the Delegate:
        let theDelegate = delegate
        delegate = nil

        /// Issue #472: Linkification should not be undoable
        undoManager?.disableUndoRegistration()

        if let textStorage = textStorage as? Storage {

            // checkTextInDocument calculate bounds for links and we need to ensure that layout is current before calling beginEditing
            // otherwise it will crash trying to update layout inside beginEditing / endEditing block
            ensureLayout()
            textStorage.beginEditing()
            checkTextInDocument(nil)
            textStorage.endEditingWithoutRestyling()
        } else {
            checkTextInDocument(nil)
        }

        undoManager?.enableUndoRegistration()

        /// Restore the Delegate
        delegate = theDelegate
    }
}


// MARK: - Processing Special Characters
//
extension NSTextView {

    /// Indents the List at the selected range (if any)
    ///
    @objc
    func processTabInsertion() -> Bool {
        let (lineRange, lineString) = selectedLineDroppingTrailingNewline()

        guard let _ = lineString.rangeOfListMarker else {
            return false
        }

        // Inject a Tab character at the beginning of the line
        let insertionRange = NSRange(location: lineRange.location, length: .zero)
        insertText(String.tab, replacementRange: insertionRange)

        return true
    }

    /// De-indents the List at the selected range (if any)
    ///
    @objc
    func processTabDeletion() -> Bool {
        let (lineRange, lineString) = selectedLineDroppingTrailingNewline()

        guard let rangeOfListMarker = lineString.rangeOfListMarker, rangeOfListMarker.location > 0 else {
            return false
        }
        
        // Make sure there is a Tab character at the beginning of the line
        if !lineString.hasPrefix(String.tab) {
            return false
        }
       
        // Delete the Tab character at the beginning of the line
        let deletionRange = NSRange(location: lineRange.location, length: 1)
        insertText("", replacementRange: deletionRange)

        return true
    }

    /// Processes a Newline Insertion on List Items:
    ///
    ///     -   No List Marker: in the current line, this method does nothing.
    ///     -   SelectedRange.location < List Marker.location: NSTextView is expected to just insert a \n
    ///     -   If the Line has *only* the List Marker, we'll nuke it
    ///     -   Otherwise: We'll add a newline, with the same Marker indentation and padding!
    ///
    @objc
    func processNewlineInsertion() -> Bool {
        let (lineRange, lineString) = selectedLineDroppingTrailingNewline()

        // No Marker, no processing!
        guard let rangeOfMarker = lineString.rangeOfListMarker else {
            return false
        }

        // Avoid inserting a *new* Marker when the caret isn't on the right hand side of the current one
        let locationOfMarkerInText = lineRange.location + rangeOfMarker.location
        guard selectedRange.location > locationOfMarkerInText else {
            return false
        }

        // Empty Line: Remove the bullet
        let trimmedString = lineString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.utf16.count != rangeOfMarker.length else {
            removeText(at: lineRange)
            return true
        }

        // Insert: newline + Padding + Marker + Space?
        let insertionText = NSMutableAttributedString(string: .newline)

        let paddingAndMarker = attributedSubstring(from: lineRange.location, length: rangeOfMarker.upperBound)
        insertionText.append(paddingAndMarker)

        if let tail = lineString.unicodeScalar(at: rangeOfMarker.upperBound), tail.isWhitespace {
            insertionText.append(character: tail)
        }

        // Replace any SPTextAttachments instances by a new one:
        // Sharing the same SPTextAttachment instance with the previous line causes its inner state to be shared all over.
        // Which in turn... makes it impossible to "Check" a single attachment.
        //
        insertionText.enumerateAttachments(of: SPTextAttachment.self) { (oldAttachment, range) in
            let newAttachment = SPTextAttachment()
            newAttachment.tintColor = oldAttachment.tintColor
            insertionText.addAttribute(.attachment, value: newAttachment, range: range)
        }

        insertText(insertionText, replacementRange: selectedRange)

        return true
    }
}


// MARK: - New Lists
//
extension NSTextView {

    /// Inserts (or) Removes List Markers at the Selected Range
    ///
    @objc
    func toggleListMarkersAtSelectedRange() {
        let (range, line) = selectedLineDroppingTrailingNewline()
        let updated = line.containsAttachment ? line.removingListMarkers : line.insertingListMarkers

        let oldSelectedRange = selectedRange()
        insertText(updated, replacementRange: range)

        let delta = updated.length - range.length
        let newSelectedRange = NSRange(location: oldSelectedRange.upperBound + delta, length: .zero)
        setSelectedRange(newSelectedRange)
    }
}


// MARK: - Interlinks
//
extension NSTextView {

    /// Returns the Interlinking Keyword at the current Location (if any)
    ///
    var interlinkKeywordAtSelectedLocation: (Range<String.Index>, Range<String.Index>, String)? {
        let text = string
        return text.indexFromLocation(selectedRange().location).flatMap { index in
            text.interlinkKeyword(at: index)
        }
    }
}


// MARK: - Geometry
//
extension NSTextView {

    /// Returns the Bounding Rect for the specified `Range<String.Index>`
    ///
    func boundingRect(for range: Range<String.Index>) -> NSRect {
        let nsRange = string.utf16NSRange(from: range)
        return boundingRect(for: nsRange)
    }

    /// Returns the Bounding Rect for the specified NSRange
    ///
    func boundingRect(for range: NSRange) -> NSRect {
        guard let layoutManager = layoutManager, let textContainer = textContainer else {
            return .zero
        }

        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        return NSOffsetRect(rect, textContainerOrigin.x, textContainerOrigin.y)
    }

    /// Returns the Screen Location for the text at the specified range
    ///
    func locationOnScreenForText(in range: Range<String.Index>) -> CGRect {
        let rectInEditor = boundingRect(for: range)
        let rectInWindow = convert(rectInEditor, to: nil)

        return window?.convertToScreen(rectInWindow) ?? rectInWindow
    }

    /// Ensure layout
    ///
    func ensureLayout() {
        guard let layoutManager = layoutManager,
              let textContainer = textContainer else {
            return
        }

        layoutManager.ensureLayout(for: textContainer)
    }

    /// Scrolls to the Selected Location
    ///
    func scrollToSelectedLocation() {
        guard let location = selectedRanges.first?.rangeValue.location else {
            return
        }

        scrollRangeToVisible(NSRange(location: location, length: .zero))
    }
}

