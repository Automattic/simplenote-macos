import Foundation


// MARK: - Simperium + Buckets
//
extension Simperium {

    /// Notes Bucket
    ///
    var notesBucket: SPBucket {
        bucket(forName: Note.classNameWithoutNamespaces)
    }

    /// Tags Bucket
    ///
    @objc
    var tagsBucket: SPBucket {
        bucket(forName: Tag.classNameWithoutNamespaces)
    }
}


// MARK: - Simperium + Tags
//
extension Simperium {

    /// Returns all of the available `Tags`
    ///
    var allTags: [Tag] {
        tagsBucket.allObjects(ofType: Tag.self)
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
}


// MARK: - Simperium + Notes
//
extension Simperium {

    /// Deletes all of the Note entities, from Core Data, whose `deleted` flag are set to `true`.
    /// - Note: It's up to the caller to actually persist the change.
    ///
    func deleteTrashedNotes() {
        let predicate = NSPredicate.predicateForNotes(deleted: true)

        for note in notesBucket.objects(ofType: Note.self, for: predicate) {
            notesBucket.delete(note)
        }
    }

    /// Returns the number of Deleted Notes
    ///
    @objc
    var numberOfDeletedNotes: Int {
        let predicate = NSPredicate.predicateForNotes(deleted: true)
        return notesBucket.numObjects(for: predicate)
    }

    /// Returns the subset of Notes that contain the specified Tag
    ///
    @objc
    func searchNotesWithTag(_ tag: Tag) -> [Note] {
        guard let name = tag.name else {
            return []
        }

        return notesBucket.objects(ofType: Note.self, for: NSCompoundPredicate(andPredicateWithSubpredicates: [
            .predicateForNotes(tag: name),
            .predicateForNotes(deleted: false)
        ]))
    }
}
