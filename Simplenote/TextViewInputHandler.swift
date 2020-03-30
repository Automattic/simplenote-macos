import Foundation


// MARK: - Input Handler: Encapsulates Simplenote's TextView Input Logic
//
class TextViewInputHandler: NSObject {

    /// Handles TextView's `shouldChangeTextInRanges:strings:` Delegate API:
    ///
    /// -   Note:
    ///    Whenever all of the input parameters are valid, this method will always return *false* and will proceed with performing the Replacement OP.
    ///
    ///     A.  Both Strings and Ranges arrays must not be empty, and must have the exact same number of entries
    ///     B.  TextView's TextStorage and UndoManager are not nil
    ///
    /// -   Important:
    ///    Reason to have this mechanism is: whenever any of the Text Insertion OP(s) results in a (new) List Item to be rendered, we want to group
    ///    the "Replacement" and "Process Checklists" operations as a single transaction.
    ///
    ///    Pressing CMD + Z is expected to undo *both*, otherwise we'd risk UndoManager integrity issues.
    ///
    @objc
    func textView(_ textView: NSTextView, shouldChangeTextInRanges ranges: [NSValue], strings: [String]?) -> Bool {
        guard let strings = strings,
            !ranges.isEmpty,
            ranges.count == strings.count,
            let storage = textView.textStorage,
            let undoManager = textView.undoManager
            else {
                return true
        }

        undoManager.beginUndoGrouping()

        for (range, string) in zip(ranges, strings).reversed() {
            storage.replaceCharacters(in: range.rangeValue, string: string, undoManager: undoManager)
        }

        storage.processChecklists(with: .textListColor, undoManager: undoManager)

        undoManager.endUndoGrouping()
        textView.didChangeText()

        return false
    }
}
