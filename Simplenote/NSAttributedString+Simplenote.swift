import Foundation


// MARK: - NSAttributedString Simplenote Methods
//
extension NSAttributedString {

    /// Returns the full range of the receiver
    ///
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
}
