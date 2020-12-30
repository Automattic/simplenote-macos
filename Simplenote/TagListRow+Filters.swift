import Foundation


// MARK: - NotesListFilter: Public API
//
extension TagListRow {

    /// Returns the NotesListFilter that matches with the receiver (if any)
    ///
    var matchingNotesFilter: NotesListFilter? {
        switch self {
        case .allNotes:
            return .everything
        case .tag(let tag):
            return .tag(name: tag.name)
        case .trash:
            return .deleted
        case .untagged:
            return .untagged
        default:
            return nil
        }
    }
}
