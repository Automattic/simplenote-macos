import Foundation


// MARK: - NSMutableAttributedString Simplenote Methods
//
extension NSAttributedString {

    /// Returns the full range of the receiver.
    ///
    @objc
    var fullRange: NSRange {
        NSRange(location: .zero, length: length)
    }

    /// Enumerates all of the NSTextAttachment(s) of the specified kind.
    ///
    func enumerateAttachments<T: NSTextAttachment>(of type: T.Type, closure: (_ attachment: T, _ range: NSRange) -> Void) {
        enumerateAttribute(.attachment, in: fullRange, options: .reverse) { (payload, range, _) in
            guard let attachment = payload as? T else {
                return
            }

            closure(attachment, range)
        }
    }

    /// Returns the number of TextAttachment(s) contained within the receiver.
    ///
    var numberOfAttachments: Int {
        var count = Int.zero
        enumerateAttachments(of: NSTextAttachment.self) { (_, _) in
            count += 1
        }

        return count
    }

    /// Returns the Range of the **first** NSTextAttachment whose stringValue matches the specified string.
    /// - Note: Yes. We check for `attachmentCell.stringValue`!
    ///
    func rangeOfFirstAttachment(stringValue: String) -> NSRange? {
        var output: NSRange?
        enumerateAttribute(.attachment, in: fullRange, options: []) { (payload, range, stop) in
            guard let attachment = payload as? NSTextAttachment,
                let attachmentCell = attachment.attachmentCell as? NSTextAttachmentCell,
                attachmentCell.stringValue == stringValue
                else {
                    return
            }

            output = range
            stop.pointee = true
        }

        return output
    }
}
