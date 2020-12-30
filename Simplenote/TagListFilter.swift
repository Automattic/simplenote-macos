import Foundation


// MARK: - TagListFilter
//
enum TagListFilter: Equatable {
    case everything
    case deleted
    case untagged
    case tag(name: String)
}
