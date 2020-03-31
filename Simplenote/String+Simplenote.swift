import Foundation


// MARK: - String Simplenote APIs
//
extension String {

    /// String containing the NSTextAttachment Marker
    ///
    static let attachmentString = String(Character(UnicodeScalar(NSTextAttachment.character)!))

    /// Newline
    ///
    static let newline = "\n"

    /// Space
    ///
    static let space = " "

    /// Tabs
    ///
    static let tab = "\t"

    /// All of the supported List Markers
    ///
    static let listMarkers = [ attachmentString, "*", "-", "+", "•" ]

    /// Rich List Item: Represented with an Attachment + Space
    ///
    static let richListMarker = .attachmentString + .space

    /// Returns the receiver casted as a Foundation String. For convenience
    ///
    var asNSString: NSString {
        self as NSString
    }
}
