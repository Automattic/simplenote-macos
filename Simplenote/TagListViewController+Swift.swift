import Foundation


// MARK: - Interface Initialization
//
extension TagListViewController {

    @objc
    func refreshExtendedContentInsets() {
        clipView.extendedContentInsets.top = Settings.extendedTopInset
    }

    /// Regenerates the Internal List State
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
        state.numberOfRows
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch state.rowAtIndex(row) {
        case .allNotes:
            return allNotesTableViewCell()
        case .trash:
            return trashTableViewCell()
        case .header:
            return tagHeaderTableViewCell()
        case .tag(let tag):
            return tagTableViewCell(for: tag)
        case .untagged:
            // TODO: Coming UP >> Soon!
            return nil
        }
    }

    public func tableView(_ tableView: NSTableView, menuForTableColumn column: Int, row: Int) -> NSMenu? {
        switch state.rowAtIndex(row) {
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
        state.rowAtIndex(row) != .header
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        let isViewingTrash = tableView.selectedRow != NSNotFound && state.rowAtIndex(tableView.selectedRow) == .trash
        let name: NSNotification.Name = isViewingTrash ? .TagListDidBeginViewingTrash : .TagListDidBeginViewingTag

        NotificationCenter.default.post(name: name, object: self)
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
