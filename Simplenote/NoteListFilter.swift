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
}
