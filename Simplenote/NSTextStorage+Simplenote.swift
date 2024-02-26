import Foundation

// MARK: - NSTextStorage
//
extension NSTextStorage {

    /// Returns the font at the specified character, if any
    ///
    func font(at charIndex: Int) -> NSFont? {
        return attribute(.font, at: charIndex, effectiveRange: nil) as? NSFont
    }
}
