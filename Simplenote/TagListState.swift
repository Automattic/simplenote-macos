import Foundation


// MARK: - List State: Allows us to wrap a native Swift type into an ObjC Property
//         TODO: Let's remove this the second TagListController is Swift native!
//
@objc
class TagListState: NSObject {

    /// List Rows that should be rendered
    ///
    let rows: [TagListRow]

    /// Initial State Initializer: We don't really show tags here
    ///
    override init() {
        rows = [ .allNotes, .trash ]
        super.init()
    }

    /// Initializes the State so that the specified Tags collection is rendered
    ///
    init(tags: [Tag]) {
        let tags: [TagListRow] = tags.map { .tag(tag: $0) }
        var rows: [TagListRow] = []

        rows.append(.allNotes)
        rows.append(.trash)
        rows.append(.header)
        rows.append(contentsOf: tags)
// TODO: Implement
        rows.append(.untagged)

        self.rows = rows
    }
}


// MARK: - Public API(s)
//
extension TagListState {

    /// Returns the `TagListRow` entity at the specified Index
    /// - Note: YES we perform Bounds Check, just in order to avoid guarding for `NSNotFound` all over the place.
    ///
    func rowAtIndex(_ index: Int) -> TagListRow? {
        index >= .zero && index < rows.count ? rows[index] : nil
    }

    /// Returns the location of the `All Notes` row.
    /// - Note: This row is mandatory, it's expected to *always* be present.
    ///
    @objc
    var indexSetForAllNotes: IndexSet {
        guard let index = rows.firstIndex(of: .allNotes) else {
            fatalError()
        }

        return IndexSet(integer: index)
    }

    /// Returns the Index of the tag with the specified Name (If any!)
    ///
    @objc
    func indexSetForTag(name: String) -> IndexSet? {
        for (index, row) in rows.enumerated() {
            guard case let .tag(tag) = row, tag.name == name else {
                continue
            }

            return IndexSet(integer: index)
        }

        return nil
    }

    /// Returns the location of the First Tag Row.
    /// - Note: This API should return an optional. But because of ObjC bridging, we simply refuse to use NSNotFound as a sentinel.
    ///
    @objc
    var indexOfFirstTagRow: Int {
        for (index, row) in rows.enumerated() where row.isTagRow {
            return index
        }

        return .zero
    }

    /// Returns the location of the Last Tag Row.
    /// - Note: This API should return an optional. But because of ObjC bridging, we simply refuse to use NSNotFound as a sentinel.
    ///
    @objc
    var indexOfLastTagRow: Int {
        for (index, row) in rows.enumerated().reversed() where row.isTagRow {
            return index
        }

        return .zero
    }

    /// Returns the Tag Row at the specified location
    ///
    @objc
    func tag(atIndex index: Int) -> Tag? {
        guard case let .tag(tag) = rowAtIndex(index) else {
            return nil
        }

        return tag
    }
}
