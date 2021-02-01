import Foundation
import SimplenoteSearch


// MARK: - NoteListFilter
//
enum NoteListFilter: Equatable {
    case deleted
    case everything
    case tag(name: String)
    case untagged
    case search(query: SearchQuery)
}


// MARK: - NoteListFilter: Public API
//
extension NoteListFilter {

    /// Returns a NSPredicate to filter out Notes in the current state, with the specified Filter
    ///
    func predicateForNotes() -> NSPredicate {
        var subpredicates = [
            NSPredicate.predicateForNotes(deleted: self == .deleted)
        ]

        switch self {
        case .deleted, .everything:
            break

        case .tag(let name):
            subpredicates.append( NSPredicate.predicateForNotes(tag: name) )

        case .untagged:
            subpredicates.append( NSPredicate.predicateForUntaggedNotes() )

        case .search(let query):
            subpredicates.append( NSPredicate.predicateForNotes(query: query) )
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }

    /// Returns a collection of NSSortDescriptors that, once applied to a Notes collection, the specified SortMode will be reflected
    ///
    func descriptorsForNotes(sortMode: SortMode) -> [NSSortDescriptor] {
        var descriptors = [NSSortDescriptor]()

        switch self {
        case .search:
            // Search shouldn't be affected by pinned notes
            break
        default:
            descriptors.append(NSSortDescriptor.descriptorForPinnedNotes())
        }

        descriptors.append(NSSortDescriptor.descriptorForNotes(sortMode: sortMode))

        return descriptors
    }

    /// Returns the Title matching the current state
    ///
    var title: String {
        switch self {
        case .everything:
            return NSLocalizedString("All Notes", comment: "Title of the all notes filter")
        case .deleted:
            return NSLocalizedString("Trash", comment: "Title for the Trash filter")
        case .tag(let name) where name.isEmpty:
            return NSLocalizedString("Unnamed Tag", comment: "Title for Tag with no Name")
        case .tag(let name):
            return name
        case .untagged:
            return NSLocalizedString("Untagged", comment: "Untagged Notes Title")
        case .search:
            return NSLocalizedString("Searching", comment: "Search Results Title")
        }
    }
}
