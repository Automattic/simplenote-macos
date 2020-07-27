import Foundation


// MARK: - NSPredicate Methods
//
extension NSPredicate {

    /// Returns a collection of NSPredicates that will match, as a compound, a given Search Text
    ///
    @objc(predicateForSearchText:)
    static func predicateForNotes(searchText: String) -> NSPredicate {
        let keywords = searchText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces)
        var output = [NSPredicate]()

        for keyword in keywords where !keyword.isEmpty {
            output.append( NSPredicate(format: "content CONTAINS[cd] %@", keyword) )
        }

        guard !output.isEmpty else {
            return NSPredicate(value: true)
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: output)
    }

    /// Returns a NSPredicate that will match Notes with the specified `deleted` flag
    ///
    @objc(predicateForNotesWithDeletedStatus:)
    static func predicateForNotes(deleted: Bool) -> NSPredicate {
        let status = NSNumber(booleanLiteral: deleted)
        return NSPredicate(format: "deleted == %@", status)
    }

    /// Returns a NSPredicate that will match a given Tag
    ///
    @objc
    static func predicateForNotes(tag: String) -> NSPredicate {
        return NSPredicate(format: "tags CONTAINS[c] %@", formattedTag(for: tag))
    }

    /// Returns a NSPredicate that will match:
    ///
    ///     A. Empty JSON Arrays (with random padding)
    ///     B. Empty Strings
    ///
    @objc
    static func predicateForUntaggedNotes() -> NSPredicate {
        // Since the `Tags` field is a JSON Encoded Array, we'll need to look up for Untagged Notes with a RegEx:
        // Empty String  (OR)  Spaces* + [ + Spaces* + ] + Spaces*
        let regex = "^()|(null)|(\\s*\\[\\s*]\\s*)$"
        return NSPredicate(format: "tags MATCHES[n] %@", regex)
    }
}


// MARK: - Private Methods
//
private extension NSPredicate {

    /// Returns the received tag, escaped and surrounded by quotes: ensures only the *exact* tag matches are hit
    ///
    static func formattedTag(for tag: String) -> String {
        let filtered = tag.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "/", with: "\\/")
        return String(format: "\"%@\"", filtered)
    }
}
