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

        return notesBucket.objects(ofType: Note.self, for: compound)
    }

    ///
    ///
    func deleteTrashedNotes() {
        let predicate = NSPredicate.predicateForNotes(deleted: true)
        let trashed = notesBucket.objects(ofType: Note.self, for: predicate)

        for note in trashed {
            notesBucket.delete(note)
        }

        save()
    }

    /// Returns all of the available `Tags`
    ///
    var allTags: [Tag] {
        tagsBucket.allObjects(ofType: Tag.self)
    }

    /// Returns the Tags Bucket instance
    ///
    @objc
    var tagsBucket: SPBucket {
        bucket(forName: Tag.classNameWithoutNamespaces)
    }

    /// Returns the Notes Bucket instance
    ///
    @objc
    var notesBucket: SPBucket {
        bucket(forName: Note.classNameWithoutNamespaces)
    }
}
