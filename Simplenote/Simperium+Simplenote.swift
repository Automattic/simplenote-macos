import Foundation


// MARK: - Simperium Convenience API(s)
//
extension Simperium {

    /// Returns the subset of Tags that start with the specified string
    ///
    func searchTags(with keyword: String) -> [String] {
        let lowercasedKeyword = keyword.lowercased()

        return allTags.compactMap { tag in
            guard tag.name.lowercased().starts(with: lowercasedKeyword) else {
                return nil
            }

            return tag.name
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
}
