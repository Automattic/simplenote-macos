import Foundation


// MARK: - Tag List Row
//
enum TagListRow: Equatable {
    case allNotes
    case trash
    case header
    case tag(_ tag: Tag)
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

    /// Returns a collection of Rows that
    ///
    static func buildListRows(for tags: [Tag] = []) -> [TagListRow] {
        var rows: [TagListRow] = [
            .allNotes,
            .trash
        ]

        guard !tags.isEmpty else {
            return rows
        }

        let tags: [TagListRow] = tags.map { .tag($0) }
        rows.append(.header)
        rows.append(contentsOf: tags)
// TODO: Implement
//        rows.append(.untagged)

        return rows
    }
}
