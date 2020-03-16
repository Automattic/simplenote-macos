import Foundation


// MARK: - NSMutableAttributedString Simplenote Methods
//
extension NSMutableAttributedString {

    /// Returns the full range of the receiver
    ///
    @objc
    var rangeOfEntireString: NSRange {
        return NSRange(location: 0, length: length)
    }

    /// Nukes the specified attributes from a given range
    ///
    func removeAttributes(_ names: [NSAttributedString.Key], range: NSRange) {
        for name in names {
            removeAttribute(name, range: range)
        }
    }

    /// Returns a NSMutableAttributedString representing the specified TextAttachment
    ///
    @objc
    func append(attachment: NSTextAttachment) {
        let string = NSAttributedString(attachment: attachment)
        append(string)
    }

    /// Returns a NSMutableAttributedString representing the specified string
    ///
    @objc
    func append(string: String) {
        let string = NSAttributedString(string: string)
        append(string)
    }
}
