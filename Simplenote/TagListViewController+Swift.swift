import Foundation


// MARK: - Interface Initialization
//
extension TagListViewController {

    @objc
    func refreshExtendedContentInsets() {
        clipView.extendedContentInsets.top = Settings.extendedTopInset
    }
}


// MARK: - Interface Initialization
//
extension TagListViewController {

    /// Regenerates the TableView's Rows
    ///
    @objc
    func refreshState() {
        state = TagListState(tags: tagArray)
        tableView.reloadData()
    }
}


// MARK: - NSTableViewDelegate Helpers
//
extension TagListViewController: NSTableViewDataSource, SPTableViewDelegate {

    public func numberOfRows(in tableView: NSTableView) -> Int {
        state.rows.count
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let row = rowAtIndex(row) else {
            return nil
        }

        switch row {
        case .allNotes:
            return allNotesTableViewCell()
        case .trash:
            return trashTableViewCell()
        case .header:
            return tagHeaderTableViewCell()
        case .tag(let tag):
            return tagTableViewCell(for: tag)
        case .untagged:
            // TODO: Implement!
            return nil
        }
    }

    public func tableView(_ tableView: NSTableView, menuForTableColumn column: Int, row: Int) -> NSMenu? {
        guard let row = rowAtIndex(row) else {
            return nil
        }

        switch row {
        case .trash:
            return trashDropdownMenu
        case .tag:
            return tagDropdownMenu
        default:
            return nil
        }
    }


    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRowView()
        rowView.selectedBackgroundColor = .simplenoteSelectedBackgroundColor
        return rowView
    }

    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if rowAtIndex(row) == .header {
            return false
        }

        if rowAtIndex(tableView.selectedRow) == .trash {
            NotificationCenter.default.post(name: .TagListWillFinishViewingTrash, object: self)
        }

        return true
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        let isViewingTrash = rowAtIndex(tableView.selectedRow) == .trash
        let notificationName: NSNotification.Name = isViewingTrash ? .TagListDidBeginViewingTrash : .TagListDidBeginViewingTag

        NotificationCenter.default.post(name: notificationName, object: self)

// TODO: Fixme
//    [self.noteListViewController filterNotes:nil];
//    [self.noteListViewController selectRow:0];
    }
}


// MARK: - Convienience API(s)
//
extension TagListViewController {

    /// Returns the `TagListRow` entity at the specified Index
    /// - Note: YES we perform Bounds Check, just in order to avoid guarding for `NSNotFound` all over the place.
    ///
    func rowAtIndex(_ index: Int) -> TagListRow? {
        guard index >= .zero && index < state.rows.count else {
            return nil
        }

        return state.rows[index]
    }

    /// Returns the location of the `All Notes` row.
    /// - Note: This row is mandatory, it's expected to *always* be present.
    ///
    @objc
    var indexOfAllNotes: IndexSet {
        guard let index = state.rows.firstIndex(of: .allNotes) else {
            fatalError()
        }

        return IndexSet(integer: index)
    }

    /// Returns the Index of the tag with the specified Name (If any!)
    ///
    @objc
    func indexOfTag(name: String) -> IndexSet? {
        for (index, row) in state.rows.enumerated() {
            guard case let .tag(tag) = row, tag.name == name else {
                continue
            }

            return IndexSet(integer: index)
        }

        return nil
    }

    /// Returns the location of the first Tag Row.
    /// - Note: This API should return an optional. But because of ObjC bridging, we simply refuse to use NSNotFound as a sentinel.
    ///
    @objc
    var numberOfFirstTagRow: Int {
        for (index, row) in state.rows.enumerated() {
            guard case .tag = row else {
                continue
            }

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


// MARK: - NSTableViewDelegate Helpers
//
extension TagListViewController {

    /// Returns a HeaderTableCellView instance, meant to be used as Tags List Header
    ///
    func tagHeaderTableViewCell() -> HeaderTableCellView {
        let headerView = tableView.makeTableViewCell(ofType: HeaderTableCellView.self)
        headerView.textField?.stringValue = NSLocalizedString("Tags", comment: "Tags Section Name").uppercased()
        return headerView
    }

    /// Returns a TagTableCellView instance, initialized to be used as All Notes Row
    ///
    func allNotesTableViewCell() -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.iconImageView.image = NSImage(named: .allNotes)
        tagView.iconImageView.isHidden = false
        tagView.nameTextField.stringValue = NSLocalizedString("All Notes", comment: "Title of the view that displays all your notes")

        return tagView
    }

    /// Returns a TagTableCellView instance, initialized to be used as Trash Row
    ///
    func trashTableViewCell() -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.iconImageView.image = NSImage(named: .trash)
        tagView.iconImageView.isHidden = false
        tagView.nameTextField.stringValue = NSLocalizedString("Trash", comment: "Title of the view that displays all your deleted notes")

        return tagView
    }

    /// Returns a TagTableCellView instance, initialized to render a specified Tag
    ///
    func tagTableViewCell(for tag: Tag) -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.nameTextField.delegate = self
        tagView.nameTextField.isEditable = true
        tagView.nameTextField.stringValue = tag.name

        return tagView
    }
}


// MARK: - SPTextFieldDelegate
//
extension TagListViewController: SPTextFieldDelegate {

    func controlAcceptsFirstResponder(_ control: NSControl) -> Bool {
        !menuShowing
    }
}


// MARK: - Settings!
//
private enum Settings {
    static let extendedTopInset = CGFloat(48)
}


// MARK: - List Row
//
enum TagListRow: Equatable {
    case allNotes
    case trash
    case header
    case tag(tag: Tag)
    case untagged
}


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
//        rows.append(.untagged)

        self.rows = rows
    }
}
