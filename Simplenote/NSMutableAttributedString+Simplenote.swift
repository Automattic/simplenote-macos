import Foundation


// MARK: - NSMutableAttributedString Simplenote Methods
//
extension NSMutableAttributedString {

    /// Returns the full range of the receiver
    ///
    @objc
    var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }

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

    /// Enumerates all of the NSTextAttachment(s) of the specified kind
    ///
    func enumerateAttachments<T: NSTextAttachment>(of type: T.Type, closure: (_ attachment: T, _ range: NSRange) -> Void) {
        enumerateAttribute(.attachment, in: fullRange, options: .reverse) { (payload, range, _) in
            guard let attachment = payload as? T else {
                return
            }

            closure(attachment, range)
        }
    }
}
