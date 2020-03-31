import Foundation


// MARK: - Input Handler: Encapsulates Simplenote's TextView Input Logic
//
class TextViewInputHandler: NSObject {

    /// Handles TextView's `shouldChangeTextInRange:string:` Delegate API:
    ///
    /// -   Note:
    ///    Whenever the `String` is not nil, and the actual Replacement OP succeeds,  `this method will always return false`,
    ///    since it'll take over the Replacement OP itself (overriding the default implementation).
    ///
    /// -   Important:
    ///    Reason to have this mechanism is: whenever any of the Text Insertion OP(s) results in a (new) List Item to be rendered, we want to group
    ///    the "Replacement" and "Process Checklists" operations as a single transaction.
    ///
    ///    Pressing CMD + Z is expected to undo *both*, otherwise we'd risk UndoManager integrity issues.
    ///
    @objc
    func textView(_ textView: NSTextView, shouldChangeTextInRange range: NSRange, string: String?) -> Bool {
        guard let string = string, textView.performUndoableReplacementProcessingLists(at: range, string: string) else {
            return true
        }

        return false
    }
}
