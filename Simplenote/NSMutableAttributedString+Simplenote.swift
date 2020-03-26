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


// MARK: - Text Replacement
//
extension NSMutableAttributedString {

    /// Replaces the *FULL* contents of the receiver with the specified AttributedString. We also register the inverse OP in the UndoManager
    ///
    @objc(replaceCharactersWithAttrString:undoManager:)
    func replaceCharacters(with attrString: NSAttributedString, undoManager: UndoManager) {
        let undoString = attributedSubstring(from: fullRange)
        let undoRange = attrString.fullRange

        undoManager.registerUndo(withTarget: self) { _ in
            self.replaceCharacters(in: undoRange, with: undoString)
        }

        replaceCharacters(in: fullRange, with: attrString)
    }

    /// Applies the changes encapsualted in a specified array of Ranges and Strings
    ///
    func replaceCharacters(in ranges: [NSValue], with strings: [String]) -> Bool {
        guard ranges.count == strings.count else {
            return false
        }

        for (value, string) in zip(ranges, strings).reversed() {
            replaceCharacters(in: value.rangeValue, with: string)
        }

        return true
    }
}
