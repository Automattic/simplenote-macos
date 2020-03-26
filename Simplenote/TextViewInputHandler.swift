import Foundation


// MARK: - Input Handler: Encapsulates Simplenote's TextView Input Logic
//
class TextViewInputHandler: NSObject {

    /// Indicates if the TextView should perform the specified change (Ranges, Strings), or not:
    ///
    /// -   Note:
    ///    Whenever the delta results in at least one new TextAttachment (because List Markers were added) this Handler will return *false* and
    ///    will proceed to replacing such substrings with proper SPTextAttachments.
    ///
    /// -   Important:
    ///    Reason to have this mechanism is:
    ///
    ///     A.  Type `- [ `: the substring should show up without further issues
    ///     B.  If the user inserts `]` we'll prevent this character from being visible. Immediately we'll insert a TextAttachment with a List Marker
    ///     C. Pressing `CTRL + Z` should replace the Text Attachment with the `- [ ` substring again
    ///
    ///     It really boils down to keeping the UndoManager's stack in good shape.
    ///
    @objc
    func textView(_ textView: NSTextView, shouldChangeTextInRanges ranges: [NSValue], strings: [String]?) -> Bool {
        guard let strings = strings, let storage = textView.textStorage, let undoManager = textView.undoManager else {
            return true
        }

        let replacementString = NSMutableAttributedString(attributedString: storage)
        guard replacementString.replaceCharacters(in: ranges, with: strings) else {
            return true
        }

        let attachments = replacementString.processChecklists(with: .textListColor)
        guard !attachments.isEmpty else {
            return true
        }

        storage.replaceCharacters(with: replacementString, undoManager: undoManager)
        textView.didChangeText()

        return false
    }
}
