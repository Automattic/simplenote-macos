import Foundation


// MARK: - Simperium Convenience API(s)
//
extension Simperium {

    /// Returns the number of Deleted Notes
    ///
    @objc
    func numberOfDeletedNotes() -> Int {
        let predicate = NSPredicate.predicateForNotes(deleted: true)
        return notesBucket.numObjects(for: predicate)
    }

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

    ///
    ///
    @objc
    func searchNotesWithTag(_ tag: Tag) -> [Note] {
        guard let name = tag.name else {
            return []
        }

        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [
            NSPredicate.predicateForNotes(tag: name),
            NSPredicate.predicateForNotes(deleted: false)
        ])

        guard let notes = notesBucket.objects(for: compound) as? [Note] else {
            return []
        }

        return notes
    }

    ///
    ///
    func deleteTrashedNotes() {
        let predicate = NSPredicate.predicateForNotes(deleted: true)
        let bucket = notesBucket

        guard let trashed = bucket.objects(for: predicate) as? [Note] else {
            return
        }

        for note in trashed {
            bucket.delete(note)
        }

        save()
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
