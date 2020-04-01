import Foundation


// MARK: - Input Handler: Encapsulates Simplenote's TextView Input Logic
//
class TextViewInputHandler: NSObject {

    /// Lists Processing RegEx
    ///
    private let regexForListMarkers = NSRegularExpression.regexForListMarkers


    /// Handles TextView's `shouldChangeTextInRange:string:` Delegate API:
    ///
    /// -   Note:
    ///    This method will `only return false` (and thus, will override NSTextView's default Text Insertion) whenever the resulting
    ///    document contains  `at least` one Markdown List Item, this method
    ///
    /// -   Important:
    ///    Reason to have this mechanism is: whenever any of the Text Insertion OP(s) results in a (new) List Item to be rendered, we want to group
    ///    the "Replacement" and "Process Checklists" operations as a single transaction: **CMD + Z** is expected to undo *both*.
    ///
    @objc
    func textView(_ textView: NSTextView, shouldChangeTextInRange range: NSRange, string: String?) -> Bool {
        guard let string = string else {
            return true
        }

        let oldText = textView.string as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)

        guard let _ = regexForListMarkers.firstMatch(in: newText, options: [], range: newText.fullRange) else {
            return true
        }

        guard textView.performUndoableReplacementAndProcessLists(at: range, string: string) else {
            return true
        }

        return false
    }
}
