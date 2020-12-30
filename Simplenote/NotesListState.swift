import Foundation
import SimplenoteSearch


// MARK: - NotesListState
//
enum NotesListState: Equatable {
    case results
    case searching(keyword: String)
}


// MARK: - NotesListState: Public API
//
extension NotesListState {

    /// Returns a NSPredicate to filter out Notes in the current state, with the specified Filter
    ///
    func predicateForNotes(filter: NotesListFilter) -> NSPredicate {
        var subpredicates = [NSPredicate]()

        switch self {
        case .results:
            subpredicates.append( NSPredicate.predicateForNotes(deleted: filter == .deleted) )

            switch filter {
            case .tag(let name):
                subpredicates.append( NSPredicate.predicateForNotes(tag: name) )
            case .untagged:
                subpredicates.append( NSPredicate.predicateForUntaggedNotes() )
            default:
                break
            }
        case .searching(let keyword):
            subpredicates += [
                NSPredicate.predicateForNotes(deleted: false),
                NSPredicate.predicateForNotes(searchText: keyword)
            ]
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }

    /// Returns a collection of NSSortDescriptors that, once applied to a Notes collection, the specified SortMode will be reflected
    ///
    func descriptorsForNotes(sortMode: SortMode) -> [NSSortDescriptor] {
        var descriptors = [NSSortDescriptor]()

        switch self {
        case .results:
            descriptors.append(NSSortDescriptor.descriptorForPinnedNotes())
        default:
            // Search shouldn't be affected by pinned notes
            break
        }

        descriptors.append(NSSortDescriptor.descriptorForNotes(sortMode: sortMode))

        return descriptors
    }
}
