import Foundation


// MARK: - Simperium Convenience API(s)
//
extension Simperium {

    /// Returns the subset of Tag Names that start with the specified string
    ///
    func searchTagNames(prefix: String) -> [String] {
        let lowercasedKeyword = prefix.lowercased()

        return allTags.compactMap { tag in
            guard tag.name.lowercased().starts(with: lowercasedKeyword) else {
                return nil
            }

            return tag.name
        }
    }

    /// Returns the Tag instance with a specified Name
    ///
    @objc
    func searchTag(name: String) -> Tag? {
        let lowercasedName = name.lowercased()

        return allTags.first { tag in
            tag.name.lowercased() == lowercasedName
        }
    }

    /// Returns all of the available `Tags`
    ///
    var allTags: [Tag] {
        guard let tags = tagsBucket.allObjects() as? [Tag] else {
            return []
        }

        return tags
    }

    /// Returns the Tags Bucket instance
    ///
    var tagsBucket: SPBucket {
        bucket(forName: Tag.classNameWithoutNamespaces)
    }

    /// Returns the Notes Bucket instance
    ///
    var notesBucket: SPBucket {
        bucket(forName: Note.classNameWithoutNamespaces)
    }
}
