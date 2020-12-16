import Foundation


// MARK: - NotesListFilter
//
enum NotesListFilter: Equatable {
    case everything
    case deleted
    case untagged
    case tag(name: String)
}
