import Foundation


// MARK: - Tag List Row
//
enum TagListRow: Equatable {
    case allNotes
    case trash
    case header
    case tag(tag: Tag)
    case untagged
}


// MARK: - Helpers API(s)
//
extension TagListRow {

    /// Indicates if the receiver is a Tag Row
    ///
    var isTagRow: Bool {
        guard case .tag = self else {
            return false
        }

        return true
    }
}
