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

    /// Returns the (Range, String) representing the line or lines at the Selected Range
    ///
    func lineAtSelectedRange() -> (NSRange, String) {
        string.asNSString.line(at: selectedRange)
    }

    /// Removes the text at the specified range, and notifies the delegate.
    ///
    func removeText(at range: NSRange) {
        insertText(String(), replacementRange: range)
    }
}


// MARK: - Processing Special Characters
//
extension NSTextView {

    /// Indents the List at the selected range (if any)
    ///
    @objc
    func processTabInsertion() -> Bool {
        let (lineRange, lineString) = lineAtSelectedRange()

        guard let _ = lineString.rangeOfListMarker else {
            return false
        }

        // Inject a Tab character at the beginning of the line
        let insertionRange = NSRange(location: lineRange.location, length: .zero)
        insertText(String.tab, replacementRange: insertionRange)

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
        let (lineRange, lineString) = lineAtSelectedRange()

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
        let (lineRange, lineString) = lineAtSelectedRange()

        guard lineString.containsAttachment else {
            insertText(lineString.insertingListMarkers, replacementRange: lineRange)
            return
        }

        insertText(lineString.removingListMarkers, replacementRange: lineRange)
    }
}
