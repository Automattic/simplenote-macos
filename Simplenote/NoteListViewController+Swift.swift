import Foundation
import SimplenoteSearch


// MARK: - Private Helpers
//
extension NoteListViewController {

    /// Setup: Results Controller
    ///
    @objc
    func setupResultsController() {
        listController = NotesListController(viewContext: SimplenoteAppDelegate.shared().managedObjectContext)
        listController.performFetch()
    }

    /// Setup: TableView
    ///
    @objc
    func setupTableView() {
        tableView.rowHeight = NoteTableCellView.rowHeight
        tableView.selectionHighlightStyle = .regular
        tableView.backgroundColor = .clear

        tableView.ensureStyleIsFullWidth()
    }

    /// Setup: Progress Indicator
    ///
    @objc
    func setupProgressIndicator() {
        progressIndicator.wantsLayer = true
        progressIndicator.alphaValue = AppKitConstants.alpha0_5
        progressIndicator.isHidden = true
    }

    /// Refreshes the Top Content Insets: We'll match the Notes List Insets
    ///
    @objc
    func refreshScrollInsets() {
        clipView.contentInsets.top = SplitItemMetrics.sidebarTopInset
        scrollView.scrollerInsets.top = SplitItemMetrics.sidebarTopInset
    }

    /// Ensures only the actions that are valid can be performed
    ///
    @objc
    func refreshEnabledActions() {
        addNoteButton.isEnabled = !viewingTrash
    }

    @objc
    func refreshTitle() {
        titleLabel.stringValue = listController.filter.title
    }

    /// Refreshes the receiver's style
    ///
    @objc
    func refreshStyle() {
        backgroundBox.boxType = .simplenoteSidebarBoxType
        backgroundBox.fillColor = .simplenoteSecondaryBackgroundColor
        addNoteButton.contentTintColor = .simplenoteActionButtonTintColor
        statusField.textColor = .simplenoteSecondaryTextColor
        titleLabel.textColor = .simplenoteTextColor

        tableView.reloadData()
    }
}


// MARK: - Layout
//
extension NoteListViewController {

    open override func updateViewConstraints() {
        if mustSetupSemaphoreLeadingConstraint {
            setupSemaphoreLeadingConstraint()
        }

        refreshSemaphoreLeadingConstant()
        super.updateViewConstraints()
    }

    /// Indicates if the Semaphore Leading hasn't been initialized
    ///
    private var mustSetupSemaphoreLeadingConstraint: Bool {
        titleSemaphoreLeadingConstraint == nil
    }

    /// # Semaphore Leading:
    /// We REALLY need to avoid collisions between the TitleLabel and the Window's Semaphore (Zoom / Close buttons).
    ///
    /// - Important:
    ///     `priority` is set to `defaultLow` (250) for the constraint between TitleLabel and Window.contentLayoutGuide, whereas the regular `leading` is set to (249).
    ///     This way we avoid choppy NSSplitView animations (using a higher priority interfers with AppKit internals!)
    ///
    private func setupSemaphoreLeadingConstraint() {
        guard let contentLayoutGuide = view.window?.contentLayoutGuide as? NSLayoutGuide else {
            return
        }

        let newConstraint = titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.leadingAnchor)
        newConstraint.priority = .defaultLow
        newConstraint.isActive = true
        titleSemaphoreLeadingConstraint = newConstraint
    }

    /// Refreshes the Semaphore Leading
    ///
    private func refreshSemaphoreLeadingConstant() {
        guard let semaphorePaddingX = view.window?.semaphorePaddingX else {
            return
        }

        titleSemaphoreLeadingConstraint?.constant = semaphorePaddingX + SplitItemMetrics.toolbarSemaphorePaddingX
    }
}


// MARK: - ListController API(s) 🤟
//
extension NoteListViewController {

    /// Initializes the NSTableView <> NoteListController Link
    ///
    @objc
    func startDisplayingEntities() {
        tableView.dataSource = self

        listController.onBatchChanges = { [weak self] objectsChangeset in
            defer {
                self?.displayPlaceholderIfNeeded()
            }

            guard let `self` = self else {
                return
            }

            /// Failsafe: Brought to you by our iOS Sibling
            ///
            guard let _ = self.view.window else {
                self.tableView.reloadData()
                return
            }

            self.tableView.performChanges(objectsChangeset: objectsChangeset)
        }
    }

    /// Displays the Empty State placeholder / If Needed
    ///
    func displayPlaceholderIfNeeded() {
        statusField.isHidden = listController.numberOfNotes > .zero
    }

}


// MARK: - Refreshing
//
extension NoteListViewController {

    /// Refreshes: Actions / Title / TableView
    ///
    @objc
    func refreshEverything() {
        refreshEnabledActions()
        refreshListController()
        refreshTitle()
        selectFirstRow()
    }

    /// Refreshes the ListController / TableView
    ///
    func refreshListController() {
        listController.filter = SimplenoteAppDelegate.shared().selectedNotesFilter
        listController.sortMode = Options.shared.notesListSortMode
        listController.performFetch()

        tableView.reloadData()
        displayPlaceholderIfNeeded()
    }

    /// Refreshes the ListController / TableView for a given Keyword
    /// - Note: This will switch the state to `.searching` or `.results`, depending on the keyword length (!!!)
    ///
    func refreshListController(keyword: String) {
        listController.refreshSearchResults(keyword: keyword)

        tableView.reloadData()
        displayPlaceholderIfNeeded()
        scrollView.scrollToTop()
    }
}


// MARK: - Properties
//
extension NoteListViewController {

    @objc
    var selectedNotes: [Note] {
        listController.notes(at: tableView.selectedRowIndexes)
    }

    var simperium: Simperium {
        SimplenoteAppDelegate.shared().simperium
    }

    @objc
    var isSearching: Bool {
        listController.state != .results
    }

    var isSelectionNotEmpty: Bool {
        selectedNotes.isEmpty == false
    }
}


// MARK: - Public API(s)
//
extension NoteListViewController {

    func displaysNote(for simperiumKey: String) -> Bool {
        listController.indexOfNote(withSimperiumKey: simperiumKey) != nil
    }

    func indexOfNote(with simperiumKey: String) -> Int? {
        listController.indexOfNote(withSimperiumKey: simperiumKey)
    }

    @objc
    func selectFirstRow() {
        scrollToRow(at: .zero)
    }

    func selectRow(at index: Int) {
        guard index >= .zero else {
            return
        }

        tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
    }

    @objc(selectRowForNoteWithSimperiumKey:)
    func selectRowForNote(with simperiumKey: String) {
        guard let index = indexOfNote(with: simperiumKey) else {
            return
        }

        selectRow(at: index)
        scrollToRow(at: index)
    }

    func scrollToRow(at index: Int) {
        guard index >= .zero else {
            return
        }

        tableView.scrollRowToVisible(index)
    }
}


// MARK: - Notifications
//
extension NoteListViewController {

    @objc
    func startListeningToScrollNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clipViewDidScroll),
                                               name: NSView.boundsDidChangeNotification,
                                               object: clipView)
    }

    @objc
    func startListeningToWindowNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowDidResize),
                                               name: NSWindow.didResizeNotification,
                                               object: nil)
    }

    @objc
    func clipViewDidScroll(sender: Notification) {
        refreshHeaderState()
    }

    @objc
    func windowDidResize(sender: Notification) {
        // We might need to adjust the Title constraints (in order to prevent collisions!)
        view.needsUpdateConstraints = true
    }

    @objc
    func refreshHeaderState() {
        let newAlpha = alphaForHeader
        headerEffectView.alphaValue = newAlpha
        headerEffectView.state = newAlpha > SplitItemMetrics.headerAlphaActiveThreshold ? .active : .inactive
    }

    private var alphaForHeader: CGFloat {
        let contentOffSetY = scrollView.documentVisibleRect.origin.y + clipView.contentInsets.top
        return min(max(contentOffSetY / SplitItemMetrics.headerMaximumAlphaGradientOffset, 0), 1)
    }
}


// MARK: - NSTableViewDelegate
//
extension NoteListViewController: SPTableViewDelegate {

    public func tableView(_ tableView: NSTableView, menuForTableColumn column: Int, row: Int) -> NSMenu? {
        viewingTrash ? trashListMenu : noteListMenu
    }

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRowView()
        rowView.style = .list
        return rowView
    }
}


// MARK: - NSTableViewDataSource
//
extension NoteListViewController: NSTableViewDataSource {

    public func numberOfRows(in tableView: NSTableView) -> Int {
        listController.numberOfNotes
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let note = listController.note(at: row) else {
            return nil
        }

        return noteTableViewCell(for: note)
    }
}


// MARK: - NSTableViewDelegate Helpers
//
extension NoteListViewController {

    @objc(noteTableViewCellForNote:)
    func noteTableViewCell(for note: Note) -> NoteTableCellView {
        note.ensurePreviewStringsAreAvailable()

        let noteView = tableView.makeTableViewCell(ofType: NoteTableCellView.self)

        noteView.displaysPinnedIndicator = note.pinned
        noteView.displaysSharedIndicator = note.published
        noteView.title = note.titlePreview
        noteView.body = note.bodyPreview
        noteView.rendersInCondensedMode = Options.shared.notesListCondensed

        noteView.refreshStyle()

        return noteView
    }
}


// MARK: - EditorControllerNoteActionsDelegate
//
extension NoteListViewController: EditorControllerNoteActionsDelegate {

    public func editorController(_ controller: NoteEditorViewController, addedNoteWithSimperiumKey simperiumKey: String) {
        selectRowForNote(with: simperiumKey)
    }

    public func editorController(_ controller: NoteEditorViewController, deletedNoteWithSimperiumKey simperiumKey: String) {
        // NO-OP
    }

    public func editorController(_ controller: NoteEditorViewController, pinnedNoteWithSimperiumKey simperiumKey: String) {
        selectRowForNote(with: simperiumKey)
    }

    public func editorController(_ controller: NoteEditorViewController, restoredNoteWithSimperiumKey simperiumKey: String) {
        // NO-OP
    }

    public func editorController(_ controller: NoteEditorViewController, updatedNoteWithSimperiumKey simperiumKey: String) {
        // NO-OP
    }
}


// MARK: - EditorControllerSearchDelegate
//
extension NoteListViewController: EditorControllerSearchDelegate {

    public func editorController(_ controller: NoteEditorViewController, didSearchKeyword keyword: String) {
        SPTracker.trackListNotesSearched()
        refreshListController(keyword: keyword)
    }
}


// MARK: - MenuItem(s) Validation
//
extension NoteListViewController: NSMenuItemValidation {

    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let identifier = menuItem.identifier else {
            return true
        }

        switch identifier {
        case .listCopyInterlinkMenuItem:
            return validateListCopyInterlinkMenuItem(menuItem)
        case .listDeleteForeverMenuItem:
            return validateListDeleteForeverMenuItem(menuItem)
        case .listPinMenuItem:
            return validateListPinMenuItem(menuItem)
        case .listRestoreNoteMenuItem:
            return validateListRestoreMenuItem(menuItem)
        case .listTrashNoteMenuItem:
            return validateListTrashMenuItem(menuItem)
        default:
            return true
        }
    }

    func validateListCopyInterlinkMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Copy Internal Link", comment: "Copy Link Menu Action")
        return isSelectionNotEmpty
    }

    func validateListDeleteForeverMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Delete Forever", comment: "Delete Forever List Action")
        return isSelectionNotEmpty
    }

    func validateListPinMenuItem(_ item: NSMenuItem) -> Bool {
        let isPinnedOff = selectedNotes.allSatisfy { $0.pinned == false }
        item.state = isPinnedOff ? .off : .on
        item.title = NSLocalizedString("Pin to Top", comment: "List Pin Action")
        return isSelectionNotEmpty
    }

    func validateListRestoreMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Restore", comment: "Restore List Action")
        return isSelectionNotEmpty
    }

    func validateListTrashMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Move to Trash", comment: "Move to Trash List Action")
        return isSelectionNotEmpty
    }
}


// MARK: - Notifications
//
extension NoteListViewController {

    @objc
    func displayModeDidChange(_ note: Notification) {
        performPerservingSelectedIndex {
            self.tableView.rowHeight = NoteTableCellView.rowHeight
            self.tableView.reloadData()
        }
    }

    @objc
    func sortModeDidChange(_ note: Notification) {
        reloadDataAndPreserveSelection()
    }
}


// MARK: - Actions
//
extension NoteListViewController {

    @IBAction
    func copyInterlinkWasPressed(_ sender: Any) {
        guard let note = selectedNotes.first else {
            return
        }

        NSPasteboard.general.copyInterlink(to: note)
        SPTracker.trackListCopiedInternalLink()
    }

    @IBAction
    func deleteFromTrashWasPressed(_ sender: Any) {
        guard let note = selectedNotes.first else {
            return
        }

        performPerservingSelectedIndex {
            simperium.notesBucket.delete(note)
            simperium.save()
        }

        SPTracker.trackListNoteDeletedForever()
    }

    @IBAction
    func pinWasPressed(_ sender: Any) {
        guard let note = selectedNotes.first, let pinnedItem = sender as? NSMenuItem else {
            return
        }

        note.pinned = pinnedItem.state == .off
        simperium.save()
        reloadDataAndPreserveSelection()

        SPTracker.trackListNotePinningToggled()
    }

    @IBAction
    func restoreWasPressed(_ sender: Any) {
        guard let note = selectedNotes.first else {
            return
        }

        performPerservingSelectedIndex {
            note.deleted = false
            simperium.save()
        }

        SPTracker.trackListNoteRestored()
    }
}


// MARK: - Helpers
//
extension NoteListViewController {

    @objc
    func reloadDataAndPreserveSelection() {
        performPerservingSelectedIndex {
            self.tableView.reloadData()
        }
    }

    @objc
    func performPerservingSelectedIndex(block: () -> Void) {
        var previouslySelectedRow = tableView.selectedRow
        block()

        if previouslySelectedRow == tableView.numberOfRows {
            previouslySelectedRow -= 1
        }

        tableView.selectRowIndexes(IndexSet(integer: previouslySelectedRow), byExtendingSelection: false)
    }
}
