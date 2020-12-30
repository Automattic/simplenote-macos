import Foundation


// MARK: - NoteListFilter: Public API
//
extension TagListRow {

    /// Returns the NoteListFilter that matches with the receiver (if any)
    ///
    var matchingNotesFilter: NoteListFilter? {
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
