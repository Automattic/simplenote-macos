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

        // Verify the Selected Location is valid!
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
