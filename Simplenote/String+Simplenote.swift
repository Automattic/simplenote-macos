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

    /// All Markers: markers for Text and Media based Lists
    ///
    static let allListMarkers = [ attachmentString, "*", "-", "+", "•" ]

    /// List Markers: *Only* the markers for Text based Lists
    ///
    static let textListMarkers = [ "*", "-", "+", "•" ]

    /// Returns the receiver casted as a Foundation String. For convenience
    ///
    var asNSString: NSString {
        self as NSString
    }
}
