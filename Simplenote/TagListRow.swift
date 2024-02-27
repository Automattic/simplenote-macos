import Foundation

// MARK: - Tag List Row
//
enum TagListRow: Equatable {
    case allNotes
    case trash
    case spacer
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

    /// Indicates if the receiver should allow selection
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

        let tags: [TagListRow] = tags.map { .tag($0) }

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

// MARK: - TagListRow: Filter Mapping
//
extension TagListRow {

    /// Returns the matching Tag Filter
    ///
    var matchingFilter: TagListFilter {
        switch self {
        case .tag(let tag):
            return .tag(name: tag.name)
        case .trash:
            return .deleted
        case .untagged:
            return .untagged
        default:
            return .everything
        }
    }
}
