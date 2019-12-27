import Foundation


// MARK: - NSAttributedString Simplenote Methods
//
extension NSAttributedString {

    /// Returns the full range of the receiver
    ///
    var rangeOfEntireString: NSRange {
        return NSRange(location: 0, length: length)
    }
}
