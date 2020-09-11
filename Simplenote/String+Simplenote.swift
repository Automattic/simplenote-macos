import Foundation


// MARK: - String Constants
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


// MARK: - Helper API(s)
//
extension String {

    /// Returns a copy of the receiver minus its trailing newline (if any)
    ///
    func dropTrailingNewline() -> String {
        return last == Character(.newline) ? String(dropLast()) : self
    }

    /// Truncates the receiver's full words, up to a specified maximum length.
    /// - Note: Whenever this is not possible (ie. the receiver doesn't have words), regular truncation will be performed
    ///
    func truncateWords(upTo maximumLength: Int) -> String {
        var output = String()

        for word in components(separatedBy: .whitespaces) {
            if (output.count + word.count) >= maximumLength {
                break
            }

            let prefix = output.isEmpty ? String() : .space
            output.append(prefix)
            output.append(word)
        }

        if output.isEmpty {
            return prefix(maximumLength).trimmingCharacters(in: .whitespaces)
        }

        return output
    }
}
