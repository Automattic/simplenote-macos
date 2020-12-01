import Foundation


// MARK: - Interface Initialization
//
extension TagListViewController {

    /// Setup: TableView
    ///
    @objc
    func setupTableView() {
        tableView.ensureStyleIsFullWidth()
        tableView.sizeLastColumnToFit()
    }

    /// Setup: Top Header
    ///
    @objc
    func setupHeaderSeparator() {
        headerSeparatorView.drawsBottomBorder = true
        refreshHeaderSeparatorAlpha()
    }

    /// Refreshes the Top Content Insets: We'll match the Notes List Insets
    ///
    @objc
    func refreshExtendedContentInsets() {
        clipView.contentInsets.top = Settings.defaultTopInset
    }

    /// Regenerates the Internal List State
    ///
    @objc
    func refreshState() {
        state = TagListState(tags: tagArray)
        tableView.reloadData()
    }
}


// MARK: - Public API
//
extension TagListViewController {

    /// Returns the Selected Row
    ///
    var selectedRow: TagListRow? {
        let selectedIndex = tableView.selectedRow
        guard selectedIndex != NSNotFound else {
            return nil
        }

        return state.rowAtIndex(selectedIndex)
    }
}


// MARK: - Notifications
//
extension TagListViewController {

    @objc
    func startListeningToScrollNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clipViewDidScroll),
                                               name: NSView.boundsDidChangeNotification,
                                               object: clipView)
    }

    @objc
    func clipViewDidScroll(sender: Notification) {
        refreshHeaderSeparatorAlpha()
    }

    @objc
    func refreshHeaderSeparatorAlpha() {
        headerSeparatorView.alphaValue = alphaForHeaderSeparatorView
    }

    private var alphaForHeaderSeparatorView: CGFloat {
        let absoluteOffSetY = scrollView.documentVisibleRect.origin.y + clipView.contentInsets.top
        return min(max(absoluteOffSetY / Settings.maximumAlphaGradientOffset, 0), 1)
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
        case .spacer:
            return spacerTableViewCell()
        case .tag(let tag):
            return tagTableViewCell(for: tag)
        case .untagged:
            return untaggedTableViewCell()
        default:
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
        rowView.style = .sidebar
        return rowView
    }

    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        state.rowAtIndex(row)?.isSelectable ?? false
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
        headerView.title = NSLocalizedString("Tags", comment: "Tags Section Name").uppercased()
        headerView.titleColor = .simplenoteSecondaryTextColor
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

    /// Returns a SpacerTableView Instance.
    ///
    func spacerTableViewCell() -> SpacerTableViewCell {
        return tableView.makeTableViewCell(ofType: SpacerTableViewCell.self)
    }

    /// Returns a TagTableCellView instance, initialized to be used as Trash Row
    ///
    func untaggedTableViewCell() -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.iconImageView.image = NSImage(named: .untagged)
        tagView.iconImageView.isHidden = false
        tagView.nameTextField.stringValue = NSLocalizedString("Untagged Notes", comment: "Untagged Notes Filter")

        return tagView
    }
}


// MARK: - Actions
//
extension TagListViewController {

    @IBAction
    func emptyTrashWasPressed(_ sender: Any) {
        SPTracker.trackListTrashEmptied()

        simperium.deleteTrashedNotes()
        simperium.save()
        NotificationCenter.default.post(name: .TagListDidEmptyTrash, object: self)
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
    static let defaultTopInset = CGFloat(62)
    static let maximumAlphaGradientOffset = CGFloat(30)
    static let titlebarHeight = CGFloat(22)
}
