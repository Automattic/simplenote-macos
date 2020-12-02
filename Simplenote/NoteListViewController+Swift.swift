import Foundation
import SimplenoteSearch


// MARK: - Private Helpers
//
extension NoteListViewController {

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
        guard let title = SimplenoteAppDelegate.shared().tagListViewController.selectedRow?.title else {
            return
        }

        titleLabel.stringValue = title
    }

    /// Refreshes the receiver's style
    ///
    @objc
    func applyStyle() {
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

    private func refreshSemaphoreLeadingConstant() {
        guard let window = view.window, let semaphoreBounds = window.semaphoreBoundingRect else {
            return
        }

        let isLTR = window.windowTitlebarLayoutDirection == .leftToRight

        titleSemaphoreLeadingConstraint?.constant = padding + SplitItemMetrics.toolbarSemaphorePaddingX
    }
}


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
        let predicates = selectedTagPredicates + searchTextPredicates
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        setNotesPredicate(compound)
    }

    /// Returns a collection of NSPredicate(s) that will filter the Notes associated with the Selected Tag
    ///
    private var selectedTagPredicates: [NSPredicate] {
        guard let selectedTagRow = SimplenoteAppDelegate.shared().tagListViewController.selectedRow else {
            return []
        }

        let isTrashOnscreen = selectedTagRow == .trash
        var output = [
            NSPredicate.predicateForNotes(deleted: isTrashOnscreen)
        ]

        switch selectedTagRow {
        case .tag(let tag):
            output.append( NSPredicate.predicateForNotes(tag: tag.name) )
        case .untagged:
            output.append( NSPredicate.predicateForUntaggedNotes() )
        default:
            break
        }

        return output
    }

    /// Returns a NSPredicate that will filter the current Search Text (if any)
    ///
    private var searchTextPredicates: [NSPredicate] {
        guard let keyword = searchKeyword, !keyword.isEmpty else {
            return []
        }

        return [
            NSPredicate.predicateForNotes(searchText: keyword)
        ]
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


// MARK: - NSTableViewDelegate Helpers
//
extension NoteListViewController: NSTableViewDelegate {

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRowView()
        rowView.style = .list
        return rowView
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

        noteView.refreshAttributedStrings()

        return noteView
    }
}


// MARK: - EditorControllerNoteActionsDelegate
//
extension NoteListViewController: EditorControllerNoteActionsDelegate {

    public func editorController(_ controller: NoteEditorViewController, addedNoteWithSimperiumKey simperiumKey: String) {
        reloadSynchronously()
        selectRow(forNoteKey: simperiumKey)
    }

    public func editorController(_ controller: NoteEditorViewController, deletedNoteWithSimperiumKey simperiumKey: String) {
        // The note was just deleted, but our tableView wasn't reload yet:
        // We'll perform a synchronous reload, while keeping the same selected index!
        performPerservingSelectedIndex {
            self.reloadSynchronously()
        }
    }

    public func editorController(_ controller: NoteEditorViewController, pinnedNoteWithSimperiumKey simperiumKey: String) {
        arrayController.rearrangeObjects()
        selectRow(forNoteKey: simperiumKey)
    }

    public func editorController(_ controller: NoteEditorViewController, restoredNoteWithSimperiumKey simperiumKey: String) {
        arrayController.rearrangeObjects()
    }

    public func editorController(_ controller: NoteEditorViewController, updatedNoteWithSimperiumKey simperiumKey: String) {
        reloadRow(forNoteKey: simperiumKey)
    }
}


// MARK: - EditorControllerSearchDelegate
//
extension NoteListViewController: EditorControllerSearchDelegate {

    public func editorControllerDidBeginSearch(_ controller: NoteEditorViewController) {
        SPTracker.trackListNotesSearched()
    }

    public func editorController(_ controller: NoteEditorViewController, didSearchKeyword keyword: String) {
        searchKeyword = keyword
        refreshPredicate()
    }

    public func editorControllerDidEndSearch(_ controller: NoteEditorViewController) {
        searchKeyword = nil
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
        let isPinnedOff = selectedNotes().allSatisfy { $0.pinned == false }
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
        guard let note = selectedNotes().first else {
            return
        }

        NSPasteboard.general.copyInterlink(to: note)
        SPTracker.trackListCopiedInternalLink()
    }

    @IBAction
    func deleteFromTrashWasPressed(_ sender: Any) {
        guard let note = selectedNotes().first else {
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
        guard let note = selectedNotes().first, let pinnedItem = sender as? NSMenuItem else {
            return
        }

        note.pinned = pinnedItem.state == .off
        simperium.save()
        reloadDataAndPreserveSelection()

        SPTracker.trackListNotePinningToggled()
    }

    @IBAction
    func restoreWasPressed(_ sender: Any) {
        guard let note = selectedNotes().first else {
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
    func performPerservingSelectedIndex(block: () -> Void) {
        var previouslySelectedIndex = arrayController.selectionIndex
        block()

        if previouslySelectedIndex == tableView.numberOfRows {
            previouslySelectedIndex -= 1
        }

        arrayController.setSelectionIndex(previouslySelectedIndex)
    }
}
