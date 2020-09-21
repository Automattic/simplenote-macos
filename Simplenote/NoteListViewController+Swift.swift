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
    }

    /// Setup: Progress Indicator
    ///
    @objc
    func setupProgressIndicator() {
        progressIndicator.wantsLayer = true
        progressIndicator.alphaValue = AppKitConstants.alpha0_5
        progressIndicator.isHidden = true
    }

    /// Setup: SearchBar
    ///
    @objc
    func setupSearchBar() {
        searchField.centersPlaceholder = false
    }

    /// Setup: Top Divider
    ///
    @objc
    func setupTopDivider() {
        topDividerView.drawsBottomBorder = true
    }

    /// Ensures only the actions that are valid can be performed
    ///
    @objc
    func refreshEnabledActions() {
        addNoteButton.isEnabled = !viewingTrash
    }

    /// Refreshes the receiver's style
    ///
    @objc
    func applyStyle() {
        backgroundView.fillColor = .simplenoteSecondaryBackgroundColor
        topDividerView.borderColor = .simplenoteDividerColor
        addNoteButton.tintImage(color: .simplenoteActionButtonTintColor)
        searchField.textColor = .simplenoteTextColor
        searchField.placeholderAttributedString = searchFieldPlaceholderString
        statusField.textColor = .simplenoteSecondaryTextColor
        reloadDataAndPreserveSelection()

        // Legacy Support: High Sierra
        if #available(macOS 10.14, *) {
            return
        }

        searchField.appearance = .simplenoteAppearance
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
        let searchText = searchField.stringValue
        guard !searchText.isEmpty else {
            return []
        }

        return [
            NSPredicate.predicateForNotes(searchText: searchText)
        ]
    }
}


// MARK: - Autolayout FTW
//
extension NoteListViewController {

    open override func updateViewConstraints() {
        if mustUpdateSearchViewConstraint {
            updateSearchViewTopConstraint()
        }

        super.updateViewConstraints()
    }

    var mustUpdateSearchViewConstraint: Bool {
        // Why check `.isActive`?:
        // Because we're in a midway refactor. The NoteList.view is, initially, embedded elsewhere.
        // TODO: Simplify this check, the second MainMenu.xib is cleaned up!
        searchViewTopConstraint == nil || searchViewTopConstraint?.isActive == false
    }

    func updateSearchViewTopConstraint() {
        guard let layoutGuide = searchView.window?.contentLayoutGuide as? NSLayoutGuide else {
            return
        }

        searchViewTopConstraint = searchView.topAnchor.constraint(equalTo: layoutGuide.topAnchor)
        searchViewTopConstraint?.isActive = true
    }
}


// MARK: - Helpers
//
private extension NoteListViewController {

    var searchFieldPlaceholderString: NSAttributedString {
        let text = NSLocalizedString("Search", comment: "Search Field Placeholder")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.simplenoteSecondaryTextColor,
            .font: NSFont.simplenoteSecondaryTextFont
        ]

        return NSAttributedString(string: text, attributes: attributes)
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
        searchField.cancelSearch()
        searchField.resignFirstResponder()

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


// MARK: - MenuItem(s) Validation
//
extension NoteListViewController: NSMenuItemValidation {

    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let identifier = menuItem.identifier else {
            return true
        }

        switch identifier {
        case .listDisplayCondensedMenuItem:
            return validateDisplayCondensedMenuItem(menuItem)
        case .listDisplayComfyMenuItem:
            return validateDisplayComfyMenuItem(menuItem)
        case .listSortAlphaMenuItem:
            return validateSortAlphaMenuItem(menuItem)
        case .listSortUpdatedMenuItem:
            return validateSortUpdatedMenuItem(menuItem)
        default:
            return true
        }
    }

    func validateDisplayCondensedMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.notesListCondensed ? .on : .off
        return true
    }

    func validateDisplayComfyMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.notesListCondensed ? .off : .on
        return true
    }

    func validateSortAlphaMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.alphabeticallySortNotes ? .on : .off
        return true
    }

    func validateSortUpdatedMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.alphabeticallySortNotes ? .off : .on
        return true
    }
}


// MARK: - Actions
//
extension NoteListViewController {

    @IBAction
    func displayModeWasPressed(_ sender: Any) {
        guard let item = sender as? NSMenuItem else {
            return
        }

        let isCondensedOn = item.identifier == NSUserInterfaceItemIdentifier.listDisplayCondensedMenuItem
        Options.shared.notesListCondensed = isCondensedOn
        SPTracker.trackSettingsListCondensedEnabled(isCondensedOn)
    }

    @IBAction
    func sortModeWasPressed(_ sender: Any) {
        guard let item = sender as? NSMenuItem else {
            return
        }

        let isAlphaOn = item.identifier == NSUserInterfaceItemIdentifier.listSortAlphaMenuItem
        Options.shared.alphabeticallySortNotes = isAlphaOn
        SPTracker.trackSettingsAlphabeticalSortEnabled(isAlphaOn)
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
