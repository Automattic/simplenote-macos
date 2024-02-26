import Foundation

// MARK: - UnicodeScalar Simplenote Methods
//
extension UnicodeScalar {

    /// UnicodeScalar for NSTextAttachment Marker Characters
    ///
    static var textAttachment = UnicodeScalar(NSTextAttachment.character)!

    /// Indicates if the receiver is a Whitespace character (Spaces / Tabs alike)
    ///
    var isWhitespace: Bool {
        CharacterSet.whitespaces.contains(self)
    }
}
