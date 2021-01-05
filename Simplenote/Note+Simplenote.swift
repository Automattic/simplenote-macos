import Foundation


// MARK: - Helpers
//
extension Note {

    /// Returns the Creation / Modification date for a given SortMode
    ///
    func date(for sortMode: SortMode) -> Date? {
        switch sortMode {
        case .alphabeticallyAscending, .alphabeticallyDescending:
            return nil

        case .createdNewest, .createdOldest:
            return creationDate

        case .modifiedNewest, .modifiedOldest:
            return modificationDate
        }
    }

    /// Given a collection of Tag Names, this API will return the subset that's not already associated with the receiver.
    ///
    func filterUnassociatedTagNames(from names: [String]) -> [String] {
        return names.filter { name in
            self.hasTag(name) == false
        }
    }
}
