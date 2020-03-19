import Foundation


// MARK: - Simplenote API
//
extension NSTextView {

    /// Returns the line (range, string) at the current selected range
    ///
    func lineAtSelectedRange() -> (NSRange, String) {
        string.asNSString.line(at: selectedRange.location)
    }

    /// Indents the List at the selected range (if any)
    ///
    @objc
    func processTabInsertion() -> Bool {
        let (lineRange, lineString) = lineAtSelectedRange()

        guard let _ = lineString.rangeOfListMarker else {
            return false
        }

        let insertionRange = NSRange(location: lineRange.location, length: .zero)
        insertText(String.tab, replacementRange: insertionRange)

        notifyTextViewDidChange()

        return true
    }

    ///
    ///
    @objc
    func processNewlineInsertion() -> Bool {
        let (lineRange, lineString) = lineAtSelectedRange()

        // Stop right here... if there's no bullet!
        guard let rangeOfMarker = lineString.rangeOfListMarker else {
            return false
        }

        // Avoid inserting a bullet when the caret isn't at the end of the line
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

        // Attempt to apply the bullet
        let prefixAndMarkerRange = NSRange(location: lineRange.location, length: rangeOfMarker.upperBound)
        let prefixAndMarkerString = attributedString().attributedSubstring(from: prefixAndMarkerRange)
        let text = NSMutableAttributedString()

        text.append(string: .newline)
        text.append(prefixAndMarkerString)

        if let character = lineString.unicodeScalar(at: rangeOfMarker.upperBound), character.isWhitespace {
            text.append(string: String(character))
        }

        insertText(text, replacementRange: selectedRange)
        notifyTextViewDidChange()

        return true
    }

    /// Remove the text at the specified range, and notifies the delegate.
    ///
    func removeText(at range: NSRange) {
        insertText(String(), replacementRange: range)
        notifyTextViewDidChange()
    }

    /// Notifies the delegate that the Text was updated
    ///
    private func notifyTextViewDidChange() {
        let note = Notification(name: NSText.didChangeNotification)
        delegate?.textDidChange?(note)
    }
}
