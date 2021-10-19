import Foundation



// MARK: - TagListDelegate
//
@objc
protocol TagsControllerDelegate: AnyObject {
    func tagsControllerDidUpdateFilter(_ controller: TagListViewController)
    func tagsControllerDidRenameTag(_ controller: TagListViewController, oldName: String, newName: String)
    func tagsControllerDidDeleteTag(_ controller: TagListViewController, name: String)
}


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
        refreshHeaderSeparatorAlpha()
    }
}


// MARK: - Refreshing
//
extension TagListViewController {

    /// Refreshes the Top Content Insets: We'll match the Notes List Insets
    ///
    @objc
    func refreshExtendedContentInsets() {
        clipView.contentInsets.top = SplitItemMetrics.sidebarTopInset
    }

    /// Regenerates the Internal List State
    ///
    @objc
    func refreshState() {
        state = TagListState(tags: tagArray)
        tableView.reloadData()
    }

    /// Reloads the TableView while preserving the selected index
    /// - Important: `TagListDidBeginViewingZZZ` will only be posted *if* the actual selected filter was changed
    ///
    @objc
    func reloadDataAndPreserveSelection() {
        let previouslySelectedRow = selectedRow
        mustSkipSelectionDidChange = true

        tableView.performPreservingSelection {
            self.refreshState()
        }

        mustSkipSelectionDidChange = false

        if previouslySelectedRow != selectedRow {
            notifyTagsListFilterDidChange()
        }
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

    /// Selected TagListFilter, matching the current row
    ///
    var selectedFilter: TagListFilter {
        selectedRow?.matchingFilter ?? .everything
    }

    /// Makes table view first responder
    ///
    func focus() {
        guard isViewLoaded && !view.isHiddenOrHasHiddenAncestor else {
            return
        }
        view.window?.makeFirstResponder(tableView)
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
    func startListeningToLaunchNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(finishedLaunching),
                                               name: NSApplication.didFinishLaunchingNotification,
                                               object: nil)
    }

    @objc
    func clipViewDidScroll(sender: Notification) {
        refreshHeaderSeparatorAlpha()
    }

    @objc
    func finishedLaunching(sender: Notification) {
        /// # Workaround:
        /// -   Triggering this notification right here helps us avoid timming issues between Storyboard Instantiation and delegate setup.
        /// -   This used to be a hook in `viewWillAppear`. But since the app can launch in Focus Mode directly (macOS State Restoration) we're forced to go nuclear.
        notifyTagsListFilterDidChange()
    }

    @objc
    func refreshHeaderSeparatorAlpha() {
        headerSeparatorView.alphaValue = alphaForHeaderSeparatorView
    }

    @objc
    func notifyTagsListFilterDidChange() {
        delegate?.tagsControllerDidUpdateFilter(self)
    }

    private var alphaForHeaderSeparatorView: CGFloat {
        let absoluteOffSetY = scrollView.documentVisibleRect.origin.y + clipView.contentInsets.top
        return min(max(absoluteOffSetY / SplitItemMetrics.headerMaximumAlphaGradientOffset, 0), 1)
    }

    private func trackTagsFilterDidChange() {
        guard selectedFilter == .deleted else {
            SPTracker.trackTagRowPressed()
            return
        }

        SPTracker.trackListTrashPressed()
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
        rowView.isActive = isActive
        return rowView
    }

    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        state.rowAtIndex(row)?.isSelectable ?? false
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        if mustSkipSelectionDidChange {
            return
        }

        notifyTagsListFilterDidChange()
        trackTagsFilterDidChange()
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


// MARK: - Keyboard Navigation
//
extension TagListViewController {
    @objc
    func switchToTrailingPanel() {
        SimplenoteAppDelegate.shared().focusOnTheNoteList()
    }
}


// MARK: - SPTextFieldDelegate
//
extension TagListViewController: SPTextFieldDelegate {

    func controlAcceptsFirstResponder(_ control: NSControl) -> Bool {
        !menuShowing
    }
}


// MARK: - Appearance
//
extension TagListViewController {
    @objc
    func refreshTableRowsActiveStatus() {
        tableView.refreshRows(isActive: isActive)
        tableView.reloadSelectedRow()
    }
}
