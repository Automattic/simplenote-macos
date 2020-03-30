import Foundation


// MARK: - NSMutableAttributedString Simplenote Methods
//
extension NSMutableAttributedString {

    /// Nukes the specified attributes from a given range
    ///
    func removeAttributes(_ names: [NSAttributedString.Key], range: NSRange) {
        for name in names {
            removeAttribute(name, range: range)
        }
    }

    /// Appends the specified NSTextAttachment
    ///
    func append(attachment: NSTextAttachment) {
        let string = NSAttributedString(attachment: attachment)
        append(string)
    }

    /// Appends the specified String
    ///
    func append(string: String) {
        let string = NSAttributedString(string: string)
        append(string)
    }

    /// Appends the specified UnicodeScalar
    ///
    func append(character: UnicodeScalar) {
        let string = NSAttributedString(string: String(character))
        append(string)
    }
}


// MARK: - Replacement + Undo Support
//
extension NSMutableAttributedString {

    /// Replaces the specified Range with a given String, and registers the inverse OP in the specified UndoManager
    ///
    func replaceCharacters(in range: NSRange, string: String, undoManager: UndoManager) {
        let undoString = attributedSubstring(from: range)
        let undoRange = NSRange(location: range.location, length: string.utf16.count)

        undoManager.registerUndo(withTarget: self) { _ in
            self.replaceCharacters(in: undoRange, with: undoString)
        }

        replaceCharacters(in: range, with: string)
    }

    /// Replaces the specified Range with a given AttributedString, and registers the inverse OP in the specified UndoManager
    ///
    @objc(replaceCharactersInRange:withAttributedString:undoManager:)
    func replaceCharacters(in range: NSRange, attrString: NSAttributedString, undoManager: UndoManager) {
        let undoString = attributedSubstring(from: range)
        let undoRange = NSRange(location: range.location, length: attrString.length)

        undoManager.registerUndo(withTarget: self) { _ in
            self.replaceCharacters(in: undoRange, with: undoString)
        }

        replaceCharacters(in: range, with: attrString)
    }
}
