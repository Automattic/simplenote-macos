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
        var attachments = [NSTextAttachment]()
        enumerateAttachments(of: NSTextAttachment.self) { (attachment, _) in
            attachments.append(attachment)
        }

        return attachments.count
    }
}
