import Foundation


// MARK: - UnicodeScalar Simplenote Methods
//
extension UnicodeScalar {

    /// Indicates if the receiver is a Whitespace character (Spaces / Tabs alike)
    ///
    var isWhitespace: Bool {
        CharacterSet.whitespaces.contains(self)
    }
}
