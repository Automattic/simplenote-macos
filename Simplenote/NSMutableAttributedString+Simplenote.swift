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

    /// Create an attributed string highlighting a term
    ///
    convenience init(string text: String, attributes: [NSAttributedString.Key: Any], highlighting term: String, highlightAttributes: [NSAttributedString.Key: Any]) {
        self.init(string: text, attributes: attributes)

        if let range = text.range(of: term) {
            addAttributes(highlightAttributes, range: NSRange(range, in: text))
        }
    }
}
