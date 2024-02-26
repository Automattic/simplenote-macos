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

    /// Returns the Range enclosing all of the receiver's contents
    ///
    var fullRange: Range<String.Index> {
        startIndex ..< endIndex
    }

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

    /// Returns a new string dropping specified prefix
    ///
    func droppingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }

        return String(dropFirst(prefix.count))
    }

    /// Returns a new string replacing newlines with spaces
    ///
    func replacingNewlinesWithSpaces() -> String {
        split(whereSeparator: { $0.isNewline }).joined(separator: " ")
    }
}

// MARK: - Searching for the first / last characters
//
extension String {

    /// Find and return the location of the first / last character from the specified character set
    ///
    func locationOfFirstCharacter(from searchSet: CharacterSet,
                                  startingFrom startLocation: String.Index,
                                  backwards: Bool = false) -> String.Index? {

        guard startLocation <= endIndex else {
            return nil
        }

        let range = backwards ? startIndex..<startLocation : startLocation..<endIndex

        let characterRange = rangeOfCharacter(from: searchSet,
                                              options: backwards ? .backwards : [],
                                              range: range)

        return characterRange?.lowerBound
    }
}

// MARK: - Searching for keywords
//
extension String {

    /// Finds keywords in a string and optionally trims around the first match
    ///
    /// - Parameters:
    ///     - keywords: A list of keywords
    ///     - range: Range of the string. If nil full range is used
    ///     - leadingLimit: Limit result string to a certain characters before the first match. Only full words are used. Provide 0 to have no limit.
    ///     - trailingLimit: Limit result string to a certain characters after the first match. Only full words are used. Provide 0 to have no limit.
    ///
    func  contentSlice(matching keywords: [String],
                      in range: Range<String.Index>? = nil,
                      leadingLimit: Int = 0,
                      trailingLimit: Int = 0) -> ContentSlice? {

        guard !keywords.isEmpty else {
            return nil
        }

        let range = range ?? startIndex..<endIndex

        var leadingWordsRange: [Range<String.Index>] = []
        var matchingWordsRange: [Range<String.Index>] = []
        var trailingWordsRange: [Range<String.Index>] = []

        enumerateSubstrings(in: range, options: [.byWords, .localized, .substringNotRequired]) { (_, wordRange, _, stop) in

            if trailingLimit > 0, let firstMatch = matchingWordsRange.first {
                if distance(from: firstMatch.upperBound, to: wordRange.upperBound) > trailingLimit {
                    stop = true
                    return
                }

                trailingWordsRange.append(wordRange)
            }

            for keyword in keywords {
                if self.range(of: keyword, options: [.caseInsensitive, .diacriticInsensitive], range: wordRange, locale: Locale.current) != nil {
                    matchingWordsRange.append(wordRange)
                    break
                }
            }

            if leadingLimit > 0 && matchingWordsRange.isEmpty {
                leadingWordsRange.append(wordRange)
            }
        }

        // No matches => return nil
        guard let firstMatch = matchingWordsRange.first, let lastMatch = matchingWordsRange.last else {
            return nil
        }

        let lowerBound: String.Index = {
            if leadingLimit == 0 {
                return range.lowerBound
            }

            let upperBound = firstMatch.lowerBound
            var lowerBound = upperBound

            for range in leadingWordsRange.reversed() {
                if distance(from: range.lowerBound, to: upperBound) > leadingLimit {
                    break
                }

                lowerBound = range.lowerBound
            }

            return lowerBound
        }()

        let upperBound: String.Index = {
            if trailingLimit == 0 {
                return range.upperBound
            }
            return trailingWordsRange.last?.upperBound ?? lastMatch.upperBound
        }()

        return ContentSlice(content: self, range: lowerBound..<upperBound, matches: matchingWordsRange)
    }
}
