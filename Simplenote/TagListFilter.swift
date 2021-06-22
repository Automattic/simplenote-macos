import Foundation


// MARK: - TagListFilter
//
enum TagListFilter: Equatable {
    case everything
    case deleted
    case untagged
    case tag(name: String)
}


// MARK: - Public API(s)
//
extension TagListFilter {

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
        }
    }
}
