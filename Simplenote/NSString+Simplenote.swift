import Foundation


// MARK: - Simplenote API
//
extension NSString {

    /// Encodes the receiver as a `Tag Hash`
    ///
    @objc
    var byEncodingAsTagHash: String {
        precomposedStringWithCanonicalMapping
            .lowercased()
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self as String
    }

    /// Returns the full range of the receiver
    ///
    @objc
    var fullRange: NSRange {
        NSRange(location: .zero, length: length)
    }

    /// Indicates if the receiver contains an Attachment
    ///
    var containsAttachment: Bool {
        range(of: .attachmentString).location != NSNotFound
    }

    /// Returns the Substring containing the receiver's leading spaces
    ///
    /// - Note: This includes both newlines and tabs
    ///
    var leadingSpaces: String {
        let regex = NSRegularExpression.regexForLeadingSpaces
        guard let match = regex.firstMatch(in: self as String, options: [], range: fullRange) else {
            return String()
        }

        return substring(with: match.range)
    }

    /// Returns the (Range, String) representing the line or lines containing a given range.
    ///
    func line(at range: NSRange) -> (NSRange, String) {
        let resultRange = lineRange(for: range)
        let resultText = substring(with: resultRange)

        return (resultRange, resultText)
    }

    /// Returns the Range of the List Marker in the receiver
    ///
    /// - Important: Only Markers in the **first line** will be picked up.
    ///
    var rangeOfListMarker: NSRange? {
        return rangeOfAnyPrefix(prefixes: String.listMarkers)
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
    /// - Note: For convenience, we'll disregard any `location` that is greater than the receiver's length
    ///
    func unicodeScalar(at location: Int) -> UnicodeScalar? {
        guard location < length else {
            return nil
        }

        return UnicodeScalar(character(at: location))
    }
}


// MARK: - Lists Convenience API
//
extension NSString {

    /// Returns a new AttributedString instance, by inserting list markers at the beginning of each line
    ///
    var insertingListMarkers: NSAttributedString {
        let output = NSMutableAttributedString()
        let lines = components(separatedBy: .newlines) as [NSString]
        let indexOfLastLine = lines.count - 1

        for (index, line) in lines.enumerated() {
            let leading = line.leadingSpaces
            let payload = line.substring(from: leading.utf16.count)
            let attachment = SPTextAttachment(tintColor: .simplenoteEditorTextColor)

            output.append(string: leading)
            output.append(attachment: attachment)
            output.append(string: .space)
            output.append(string: payload)

            if index != indexOfLastLine {
                output.append(string: .newline)
            }
        }

        return output
    }

    /// Returns a new AttributedString instance, by removing all of the List Markers (with or without trailing spaces) in the receiver
    ///
    var removingListMarkers: NSAttributedString {
        let output = replacingOccurrences(of: .richListMarker, with: String())
                        .replacingOccurrences(of: String.attachmentString, with: String())

        return NSAttributedString(string: output)
    }
}


// MARK: - Constants
//
extension NSString {

    /// Space: We simply refuse to inject `" "` all over!
    ///
    @objc
    class var space: NSString {
        " "
    }
}
