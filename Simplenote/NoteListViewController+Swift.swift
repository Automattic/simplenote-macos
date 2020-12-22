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

    /// Refreshes the receiver's style
    ///
    @objc
    func refreshStyle() {
        backgroundBox.boxType = .simplenoteSidebarBoxType
        backgroundBox.fillColor = .simplenoteSecondaryBackgroundColor
        addNoteButton.contentTintColor = .simplenoteActionButtonTintColor
        statusField.textColor = .simplenoteSecondaryTextColor
        titleLabel.textColor = .simplenoteTextColor

        reloadDataAndPreserveSelection()
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


// MARK: - Dynamic Properties
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


/* TODO: Nuke!

// MARK: - State
//
extension NoteListViewController {

    /// Indicates if we're in Search Mode
    ///
    @objc
    var isSearching: Bool {
        searchKeyword?.isEmpty == false
    }
}


// MARK: - Filtering
//
extension NoteListViewController {

    /// Refreshes the Filtering Predicate
    ///
    @objc
    func refreshPredicate() {
        setNotesPredicate(filteringPredicate)
    }

    /// Predicate: Filters the current notes list, accounting for Search Keywords (OR) Selected Filters
    ///
    @objc
    var filteringPredicate: NSPredicate {
        state.predicateForNotes(filter: filter)
    }

    /// Sort Descriptors: Matches the current Settings
    ///
    @objc
    var sortDescriptors: [NSSortDescriptor] {
        state.descriptorsForNotes(sortMode: Options.shared.notesListSortMode)
    }

    /// Filter: Matches the selected TagsList Row
    ///
    private var filter: NotesListFilter {
        SimplenoteAppDelegate.shared().selectedNotesFilter
    }

    /// State: Current NotesList State
    ///
    private var state: NotesListState {
        guard let keyword = searchKeyword, !keyword.isEmpty else {
            return .results
        }

        return .searching(keyword: keyword)
    }
}


// MARK: - Helpers
//
private extension NoteListViewController {

    var simperium: Simperium {
        SimplenoteAppDelegate.shared().simperium
    }

    var isSelectionNotEmpty: Bool {
        selectedNotes().isEmpty == false
    }
}
*/


// MARK: - ListController API(s) 🤟
//
extension NoteListViewController {

    /// Initializes the NSTableView <> NoteListController Link
    ///
    @objc
    func startDisplayingEntities() {
        tableView.dataSource = self

        // We'll preserve the selected rows during an Update OP
        var selectedKeysBeforeChange = [String]()

        listController.onWillChangeContent = { [weak self] in
            selectedKeysBeforeChange = self?.selectedNotes.compactMap { $0.simperiumKey } ?? []
        }

        listController.onDidChangeContent = { [weak self] objectsChangeset in
            guard let `self` = self else {
                return
            }

            /// Refresh TableView
            self.tableView.performBatchChanges(objectsChangeset: objectsChangeset)

            /// Display Empty State
            self.refreshPlaceholder()

            /// Restore previously selected notes
            self.selectNotes(with: selectedKeysBeforeChange)
            selectedKeysBeforeChange.removeAll()

            /// # Always make sure there's at least one selected row:
            ///  - No previously selected indexes
            ///  - Old Indexes aren't valid anymore
            self.ensureSelectionIsNotEmpty()
        }
    }
}


// MARK: - Refreshing
//
extension NoteListViewController {

    /// Refresh: All of the Interface components
    ///
    @objc
    func refreshEverything() {
        refreshListController()
        refreshEnabledActions()
        refreshTitle()
        refreshPlaceholder()
        displayAndSelectFirstNote()
        refreshPresentedNoteIfNeeded()
    }

    /// Refresh: Filters relevant Notes
    ///
    func refreshSearchResults(keyword: String) {
        refreshListControllerState(keyword: keyword)
        refreshEverything()
    }

    /// Refresh: ListController <> TableView
    ///
    private func refreshListController() {
        listController.filter = SimplenoteAppDelegate.shared().selectedNotesFilter
        listController.sortMode = Options.shared.notesListSortMode
        listController.performFetch()

        tableView.reloadData()
    }

    /// Refresh: ListController Internal State
    ///
    private func refreshListControllerState(keyword: String) {
        listController.searchKeyword = keyword
    }

    /// Refresh:  Actions
    ///
    private func refreshEnabledActions() {
        addNoteButton.isEnabled = !viewingTrash
    }

    /// Refresh: Placeholder
    ///
    private func refreshPlaceholder() {
        statusField.isHidden = listController.numberOfNotes > .zero
    }

    /// Refresh: Title
    /// - Important: Update the ListController first!!
    ///
    private func refreshTitle() {
        titleLabel.stringValue = listController.filter.title
    }

    /// Although we refresh the Editor in `tableViewSelectionDidChange`, whenever we manually update the ListController and the resulting collection is empty,
    /// we won't be getting any kind of callback.
    ///
    private func refreshPresentedNoteIfNeeded() {
        guard listController.numberOfNotes == .zero, !noteEditorViewController.selectedNotes.isEmpty else {
            return
        }

        refreshPresentedNote()
    }

    /// Refresh: Presented Note in the Editor
    ///
    private func refreshPresentedNote() {
// TODO: Review how many times this gets called
        let selectedNotes = self.selectedNotes
        guard selectedNotes.count > .zero else {
NSLog("# Display NIL")
            noteEditorViewController.displayNote(nil)
            return
        }

        guard selectedNotes.count == 1, let targetNote = selectedNotes.first else {
NSLog("# Display \(selectedNotes.count)")
            noteEditorViewController.display(selectedNotes)
            return
        }

        SPTracker.trackListNoteOpened()
NSLog("# Display \(targetNote.simperiumKey.debugDescription)")
        noteEditorViewController.displayNote(targetNote)
    }
}


// MARK: - Row Selection API(s)
//
extension NoteListViewController {

    /// Indicates if the Note with the specified SimperiumKey is being displayed
    ///
    func displaysNote(with simperiumKey: String) -> Bool {
        listController.indexOfNote(withSimperiumKey: simperiumKey) != nil
    }

    /// Displays and selects the very first row
    ///
    func displayAndSelectFirstNote() {
        displayAndSelectNote(at: .zero)
    }

    /// Displays and Selects the Note with a given SimperiumKey
    ///
    @objc(displayAndSelectNoteWithSimperiumKey:)
    func displayAndSelectNote(with simperiumKey: String) {
        guard let index = listController.indexOfNote(withSimperiumKey: simperiumKey) else {
            return
        }

        displayAndSelectNote(at: index)
    }

    /// Displays and Selects the Note at a given Index
    ///
    private func displayAndSelectNote(at index: Int) {
        tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        tableView.scrollRowToVisible(index)
    }

    /// Whenever there are no selected rows, we'll select the top of the list!
    ///
    func ensureSelectionIsNotEmpty() {
        guard tableView.selectedRowIndexes.isEmpty else {
            return
        }

        displayAndSelectFirstNote()
    }

    /// Selects the Notes with the specified SimperiumKeys.
    /// - Note: Scroll Offset **is NOT** altered anyhow
    ///
    func selectNotes(with simperiumKeys: [String]) {
        let indexes = simperiumKeys.compactMap { simperiumKey in
            listController.indexOfNote(withSimperiumKey: simperiumKey)
        }

        tableView.selectRowIndexes(IndexSet(indexes), byExtendingSelection: false)
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

    public func tableViewSelectionDidChange(_ notification: Notification) {
        NSLog("# TableView Selection \(tableView.selectedRow)")
// TODO: Proper fix please
        DispatchQueue.main.async {
            self.refreshPresentedNote()
        }
    }
}


// MARK: - NSTableViewDataSource
//
extension NoteListViewController: NSTableViewDataSource {

    public func numberOfRows(in tableView: NSTableView) -> Int {
        listController.numberOfNotes
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        listController.note(at: row).map { note in
            noteTableViewCell(for: note)
        }
    }

    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
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
        displayAndSelectNote(with: simperiumKey)
    }

    public func editorController(_ controller: NoteEditorViewController, deletedNoteWithSimperiumKey simperiumKey: String) {
        // NO-OP
    }

    public func editorController(_ controller: NoteEditorViewController, pinnedNoteWithSimperiumKey simperiumKey: String) {
        displayAndSelectNote(with: simperiumKey)
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
        refreshSearchResults(keyword: keyword)
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
