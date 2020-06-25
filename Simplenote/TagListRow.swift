import Foundation


// MARK: - Tag List Row
//
enum TagListRow: Equatable {
    case allNotes
    case trash
    case spacer
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

    /// Indicates if the receiver should allow selction
    ///
    var isSelectable: Bool {
        self != .header && self != .spacer
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

        // Tags Section
        let tags: [TagListRow] = tags.map { .tag(tag: $0) }
        rows.append(.spacer)
        rows.append(.header)
        rows.append(contentsOf: tags)

        // Untagged
        rows.append(.spacer)
        rows.append(.untagged)
        rows.append(.spacer)

        return rows
    }
}
