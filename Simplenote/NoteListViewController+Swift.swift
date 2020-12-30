import Foundation
import SimplenoteSearch


// MARK: - NoteListViewController
//
class NoteListViewController: NSViewController {

    /// Storyboard Outlets
    ///
    @IBOutlet private var backgroundBox: NSBox!
    @IBOutlet private var titleLabel: NSTextField!
    @IBOutlet private var statusField: NSTextField!
    @IBOutlet private var progressIndicator: NSProgressIndicator!
    @IBOutlet private var scrollView: NSScrollView!
    @IBOutlet private var clipView: NSClipView!
    @IBOutlet private var tableView: SPTableView!
    @IBOutlet private var headerEffectView: NSVisualEffectView!
    @IBOutlet private var addNoteButton: NSButton!
    @IBOutlet private var noteListMenu: NSMenu!
    @IBOutlet private var trashListMenu: NSMenu!
    @IBOutlet private var titleSemaphoreLeadingConstraint: NSLayoutConstraint!

    /// ListController
    ///
    private lazy var listController = NotesListController(viewContext: SimplenoteAppDelegate.shared().managedObjectContext)

    /// TODO: Work in Progress. Decouple with a delegate please
    ///
    private var noteEditorViewController: NoteEditorViewController {
        SimplenoteAppDelegate.shared().noteEditorViewController
    }


    // MARK: - ViewController Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupProgressIndicator()
        setupTableView()
        startListeningToNotifications()
        startListControllerSync()

        refreshStyle()
        refreshEverything()
    }

    override func viewWillLayout() {
        super.viewWillLayout()

        refreshScrollInsets()
        refreshHeaderState()
    }

    @objc
    func setWaitingForIndex(_ waiting: Bool) {
        guard waiting else {
            progressIndicator.stopAnimation(self)
            return
        }

        progressIndicator.startAnimation(self)
    }
}


// MARK: - Interface Initialization
//
private extension NoteListViewController {

    /// Setup: TableView
    ///
    func setupTableView() {
        tableView.rowHeight = NoteTableCellView.rowHeight
        tableView.selectionHighlightStyle = .regular
        tableView.backgroundColor = .clear

        tableView.ensureStyleIsFullWidth()
    }

    /// Setup: Progress Indicator
    ///
    func setupProgressIndicator() {
        progressIndicator.wantsLayer = true
        progressIndicator.alphaValue = AppKitConstants.alpha0_5
    }

    /// Refreshes the Top Content Insets: We'll match the Notes List Insets
    ///
    func refreshScrollInsets() {
        clipView.contentInsets.top = SplitItemMetrics.listContentTopInset
        scrollView.scrollerInsets.top = SplitItemMetrics.listScrollerTopInset
    }
}


// MARK: - Skinning
//
extension NoteListViewController {

    /// Refreshes the receiver's style
    ///
    @objc
    func refreshStyle() {
        backgroundBox.boxType = .simplenoteSidebarBoxType
        backgroundBox.fillColor = .simplenoteSecondaryBackgroundColor
        addNoteButton.contentTintColor = .simplenoteActionButtonTintColor
        statusField.textColor = .simplenoteSecondaryTextColor
        titleLabel.textColor = .simplenoteTextColor

        tableView.reloadAndPreserveSelection()
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
*/


// MARK: - Dynamic Properties
//
private extension NoteListViewController {

    var selectedNotes: [Note] {
        listController.notes(at: tableView.selectedRowIndexes)
    }

    var simperium: Simperium {
        SimplenoteAppDelegate.shared().simperium
    }

    var isSelectionNotEmpty: Bool {
        selectedNotes.isEmpty == false
    }

    var isViewingTrash: Bool {
        listController.filter == .deleted
    }
}


// MARK: - ListController API(s) 🤟
//
private extension NoteListViewController {

    /// Initializes the NSTableView <> NoteListController Link
    ///
    func startListControllerSync() {
        tableView.dataSource = self

        // We'll preserve the selected rows during an Update OP
        var selectedKeysBeforeChange: [String]?
        var selectedIndexBeforeChange: Int?

        listController.onWillChangeContent = { [weak self] in
            selectedKeysBeforeChange = self?.selectedNotes.compactMap { $0.simperiumKey }
            selectedIndexBeforeChange = self?.tableView.selectedRow
        }

        listController.onDidChangeContent = { [weak self] objectsChangeset in
            guard let `self` = self else {
                return
            }

            /// Refresh Interface
            self.tableView.performBatchChanges(objectsChangeset: objectsChangeset)
            self.restoreSelectionBeforeChanges(oldSelectedKeys: selectedKeysBeforeChange, oldSelectedIndex: selectedIndexBeforeChange)
            self.refreshPlaceholder()

            /// Cleanup
            selectedKeysBeforeChange = nil
            selectedIndexBeforeChange = nil
        }
    }
}


// MARK: - Refreshing
//
private extension NoteListViewController {

    /// Refresh: All of the Interface components
    ///
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
        addNoteButton.isEnabled = !isViewingTrash
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
        let selectedNotes = self.selectedNotes
        guard selectedNotes.count > .zero else {
            noteEditorViewController.displayNote(nil)
            return
        }

        guard selectedNotes.count == 1, let targetNote = selectedNotes.first else {
            noteEditorViewController.display(selectedNotes)
            return
        }

        SPTracker.trackListNoteOpened()
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
    private func displayAndSelectFirstNote() {
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

    /// This API will attempt to restore the Rows selected before applying a ResultsController Change
    ///     1.  If there were previously Selected Notes, we'll attempt to preselect them
    ///     2.  If ther was a previously Selected Index, we'll attempt to select the `n - 1` row
    ///     3.  As a fallback, we'll automatically `preselect the first row`
    ///
    private func restoreSelectionBeforeChanges(oldSelectedKeys: [String]?, oldSelectedIndex: Int?) {
        if let targetKeys = oldSelectedKeys, let targetIndexes = listController.indexesOfNotes(withSimperiumKeys: targetKeys) {
            tableView.selectRowIndexes(targetIndexes, byExtendingSelection: false)
            return
        }

        guard let oldSelectedIndex = oldSelectedIndex, oldSelectedIndex >= .zero else {
            displayAndSelectFirstNote()
            return
        }

        let newIndex = oldSelectedIndex < tableView.numberOfRows ? oldSelectedIndex : oldSelectedIndex - 1
        displayAndSelectNote(at: newIndex)
    }
}


// MARK: - Header
//
private extension NoteListViewController {

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
        isViewingTrash ? trashListMenu : noteListMenu
    }

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRowView()
        rowView.style = .list
        return rowView
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        /// Why do we `need` a debounce here:
        ///
        /// # Scenario #1: Empty Trash
        ///     1.  Empty Trash ends up in a `save()` NSManagedObjectContext invocation
        ///     2.  This results in a call to our FRC's `onDidChangeContent` callback
        ///     3.  Refreshing the presented note in the editor also invokes `save()`, to persist any uncommitted changes
        ///     4.  This causes a CoreData exception, because of the re-entrant `save()` OP
        ///
        /// # Scenario #2: Delete Note / List with `.count > 2` notes
        ///     1.  Note deletion ends up in a `save()` NSManagedObjectContext invocation
        ///     2.  This results in `performBatchChanges`
        ///     3.  Whenever the previously selected index is gone, NSTableView will pick up `-1` as the new selected row
        ///     4.  `restoreSelectionBeforeChanges` will, then, select the first row as a fallback
        ///     5.  Same as scenario #1, this ends up refreshing the Editor, and invoking `save()`
        ///     6.  Because of the re-entrant `save()` OP, this scenario will also produce an exception
        ///
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
private extension NoteListViewController {

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

    func startListeningToNotifications() {
        let nc = NotificationCenter.default

        // Notifications: Window
        nc.addObserver(self, selector: #selector(windowDidResize), name: NSWindow.didResizeNotification, object: nil)

        // Notifications: ClipView
        nc.addObserver(self, selector: #selector(clipViewDidScroll), name: NSView.boundsDidChangeNotification, object: clipView)

        // Notifications: Tags
        nc.addObserver(self, selector: #selector(didBeginViewingTag), name: .TagListDidBeginViewingTag, object: nil)
        nc.addObserver(self, selector: #selector(didBeginViewingTrash), name: .TagListDidBeginViewingTrash, object: nil)

        // Notifications: Settings
        nc.addObserver(self, selector: #selector(displayModeDidChange), name: .NoteListDisplayModeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(sortModeDidChange), name: .NoteListSortModeDidChange, object: nil)
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
    func displayModeDidChange(_ note: Notification) {
        tableView.rowHeight = NoteTableCellView.rowHeight
        tableView.reloadAndPreserveSelection()
    }

    @objc
    func sortModeDidChange(_ note: Notification) {
        refreshEverything()
    }

    @objc
    func didBeginViewingTag(_ note: Notification) {
        SPTracker.trackTagRowPressed()
        refreshEverything()
    }

    @objc
    func didBeginViewingTrash(_ note: Notification) {
        SPTracker.trackListTrashPressed()
        refreshEverything()
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
    func deleteAction(_ sender: Any) {
        for note in selectedNotes {
            SPTracker.trackListNoteDeleted()
            note.deleted = true
        }

        simperium.save()
    }

    @IBAction
    func deleteFromTrashWasPressed(_ sender: Any) {
        guard let note = selectedNotes.first else {
            return
        }

        simperium.notesBucket.delete(note)
        simperium.save()

        SPTracker.trackListNoteDeletedForever()
    }

    @IBAction
    func newNoteWasPressed(_ sender: Any) {
        // TODO: Move the New Note Handler to a (New) NoteController!
        noteEditorViewController.newNoteWasPressed(sender)
    }

    @IBAction
    func pinWasPressed(_ sender: Any) {
        guard let note = selectedNotes.first, let pinnedItem = sender as? NSMenuItem else {
            return
        }

        note.pinned = pinnedItem.state == .off
        simperium.save()

        SPTracker.trackListNotePinningToggled()
    }

    @IBAction
    func restoreWasPressed(_ sender: Any) {
        guard let note = selectedNotes.first else {
            return
        }

        note.deleted = false
        simperium.save()

        SPTracker.trackListNoteRestored()
    }
}
