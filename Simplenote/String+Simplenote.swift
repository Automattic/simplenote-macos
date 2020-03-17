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

    /// Tabs
    ///
    static let tab = "\t"

    /// Space
    ///
    static let space = " "

    /// All Markers: markers for Text and Media based Lists
    ///
    static let allListMarkers = [ attachmentString, "*", "-", "+", "•" ]

    /// List Markers: *Only* the markers for Text based Lists
    ///
    static let textListMarkers = [ "*", "-", "+", "•" ]
}
