import Foundation


// MARK: - Simplenote API
//
extension NSTextView {

    /// Returns the line (range, string) at the current selected range
    ///
    func lineAtSelectedRange() -> (NSRange, String) {
        let foundationString = string.asNSString
        let range = foundationString.lineRange(for: selectedRange)
        let string = foundationString.substring(with: range)

        return (range, string)
    }

    @objc
    func processTabInsertion() -> Bool {
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
