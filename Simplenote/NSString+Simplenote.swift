import Foundation


// MARK: - Simplenote API
//
extension NSString {

    /// Returns the Range of the List Marker: This also includes NSTextAttachments
    ///
    var rangeOfListMarker: NSRange? {
        return rangeOfAnyPrefix(prefixes: String.allListMarkers)
    }

    /// Returns the Range of the Text List Marker (if any)
    ///
    var rangeOfTextListMarker: NSRange? {
        return rangeOfAnyPrefix(prefixes: String.textListMarkers)
    }

    /// Returns the range of the Prefix contained in the receiver (if any!)
    ///
    func rangeOfAnyPrefix(prefixes: [String]) -> NSRange? {
        let trimmedString = trimmingCharacters(in: .whitespacesAndNewlines)

        for prefix in prefixes where trimmedString.hasPrefix(prefix) {
            return range(of: prefix)
        }

        return nil
    }

    /// Returns the UnicodeScalar at the specified location, if any.
    ///
    /// - Note: For convenience, we'll check bounds!
    ///
    func unicodeScalar(at location: Int) -> UnicodeScalar? {
        guard location < length else {
            return nil
        }

        return UnicodeScalar(character(at: location))
    }
}
