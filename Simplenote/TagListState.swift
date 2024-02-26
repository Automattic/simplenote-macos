import Foundation

// MARK: - List State: Allows us to wrap a native Swift type into an ObjC Property
//         TODO: Let's remove this the second TagListController is Swift native!
//
class TagListState: NSObject {

    /// List Rows that should be rendered
    ///
    private let rows: [TagListRow]

    /// Initial State Initializer: We don't really show tags here
    ///
    override init() {
        self.rows = TagListRow.buildListRows()
        super.init()
    }

    /// Initializes the State so that the specified Tags collection is rendered
    ///
    init(tags: [Tag]) {
        self.rows = TagListRow.buildListRows(for: tags)
        super.init()
    }
}

// MARK: - Public API(s)
//
extension TagListState {

    /// Returns the number of rows
    ///
    var numberOfRows: Int {
        rows.count
    }

    /// Returns the `TagListRow` entity at the specified Index
    ///
    func rowAtIndex(_ index: Int) -> TagListRow? {
        guard index >= .zero && index < rows.count else {
            return nil
        }

        return rows[index]
    }

    /// Returns the location of the `All Notes` row.
    /// - Note: This row is mandatory, it's expected to *always* be present.
    ///
    @objc
    var indexSetForAllNotesRow: IndexSet {
        IndexSet(integer: indexOfAllNotesTagRow)
    }

    /// Returns the Index of the `Tag` Row with the specified Name (If any!)
    ///
    @objc
    func indexSetForTagRow(name: String) -> IndexSet? {
        for (index, row) in rows.enumerated() {
            guard case let .tag(tag) = row, tag.name == name else {
                continue
            }

            return IndexSet(integer: index)
        }

        return nil
    }

    /// Returns the Index of the `All Notes` Row
    ///
    @objc
    var indexOfAllNotesTagRow: Int {
        guard let index = rows.firstIndex(of: .allNotes) else {
            fatalError()
        }

        return index
    }

    /// Returns the location of the First Tag Row.
    /// - Note: This API should return an optional. But because of ObjC bridging, we simply refuse to use NSNotFound as a sentinel.
    ///
    @objc
    var indexOfFirstTagRow: Int {
        let index = rows.firstIndex {
            $0.isTagRow
        }

        return index ?? .zero
    }

    /// Returns the location of the Last Tag Row.
    /// - Note: This API should return an optional. But because of ObjC bridging, we simply refuse to use NSNotFound as a sentinel.
    ///
    @objc
    var indexOfLastTagRow: Int {
        let index = rows.lastIndex {
            $0.isTagRow
        }

        return index ?? .zero
    }

    /// Returns the Tag Row at the specified location
    ///
    @objc
    func tag(atIndex index: Int) -> Tag? {
        guard let row = rowAtIndex(index), case let .tag(tag) = row else {
            return nil
        }

        return tag
    }
}
