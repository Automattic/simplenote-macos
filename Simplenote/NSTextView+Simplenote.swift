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
    ///
    @discardableResult
    func performUndoableReplacement(at range: NSRange, string: String) -> Bool {
        performUndoableTextChangeOperation { (undoManager, storage) in
            storage.replaceCharacters(in: range, string: string, undoManager: undoManager)
        }
    }

    /// Replaces the receiver's contents at a given range, with the specified AttributedString, and registers the inverse OP in our UndoManager.
    ///
    @discardableResult
    func performUndoableReplacement(at range: NSRange, attrString: NSAttributedString) -> Bool {
        performUndoableTextChangeOperation { (undoManager, storage) in
            storage.replaceCharacters(in: range, attrString: attrString, undoManager: undoManager)
        }
    }

    /// Replaces the receiver's contents at a given range, with the specified String, and registers the inverse OP in our UndoManager.
    /// This API will also process Markdown Lists: both the Replacement and List Processing will be undoable in a single step.
    ///
    @discardableResult
    func performUndoableReplacementAndProcessLists(at range: NSRange, string: String) -> Bool {
        performUndoableTextChangeOperation { (undoManager, storage) in
            storage.replaceCharacters(in: range, string: string, undoManager: undoManager)
            storage.processChecklists(with: .textListColor, undoManager: undoManager)
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

    /// Removes the text at the specified range, and notifies the delegate.
    ///
    @discardableResult
    func removeText(at range: NSRange) -> Bool {
        performUndoableReplacement(at: range, string: String())
    }
}


// MARK: - Private!
//
private extension NSTextView {

    /// Performs an Undoable TextChange OP:
    ///
    ///     A.  Posts a TextDidChange Notification
    ///     B.  Registers an Undo Operation, which will restore the SelectedRange and post a TextDidChange Note
    ///
    func performUndoableTextChangeOperation(block: (UndoManager, NSTextStorage) -> Void) -> Bool {
        guard let storage = textStorage, let undoManager = undoManager else {
            return false
        }

        let undoSelectedRange = selectedRange()

        undoManager.beginUndoGrouping()
        undoManager.registerUndo(withTarget: self) { textView in
            textView.setSelectedRange(undoSelectedRange)
            textView.didChangeText()
        }

        block(undoManager, storage)
        undoManager.endUndoGrouping()

        didChangeText()

        return true
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
    ///
    @objc
    func displayNote(content: String) {
        string = content
        textStorage?.processChecklists(with: .textListColor)
        undoManager?.removeAllActions()
    }

    /// Returns the content represented as Plain Text
    ///
    @objc
    func plainTextContent() -> String {
        return NSAttributedStringToMarkdownConverter.convert(string: attributedString())
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
        return performUndoableReplacement(at: insertionRange, string: .tab)
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
            return removeText(at: lineRange)
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

        return performUndoableReplacement(at: selectedRange, attrString: insertionText)
    }
}


// MARK: - New Lists
//
extension NSTextView {

    /// Inserts (or) Removes List Markers at the Selected Range
    ///
    @discardableResult @objc
    func toggleListMarkersAtSelectedRange() -> Bool {
        let (range, line) = selectedLineDroppingTrailingNewline()
        let updated = line.containsAttachment ? line.removingListMarkers : line.insertingListMarkers
        let oldSelectedRange = selectedRange()

        guard performUndoableReplacement(at: range, attrString: updated) else {
            return false
        }

        let delta = updated.length - range.length
        let newSelectedRange = NSRange(location: oldSelectedRange.upperBound + delta, length: .zero)
        setSelectedRange(newSelectedRange)

        return true
    }
}
