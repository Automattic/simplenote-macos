import Foundation
import SimplenoteSearch
import Simperium_OSX


// MARK: - Initialization
//
extension SimplenoteAppDelegate {

    @objc
    func configureSimperium() {
        let simperium = Simperium(model: managedObjectModel, context: managedObjectContext, coordinator: persistentStoreCoordinator)
        simperium.delegate = self
        simperium.verboseLoggingEnabled = false
        simperium.authenticationWindowControllerClass = AuthWindowController.classForCoder()
        self.simperium = simperium
    }

    @objc
    func configureSimperiumAuth() {
        let authenticator = simperium.authenticator
        authenticator.providerString = SPCredentials.simperiumProviderString

        let config = SPAuthenticationConfiguration.sharedInstance()
        config.controlColor = .simplenoteBrandColor
    }

    @objc
    func configureSimperiumBuckets() {
        for bucket in simperium.allBuckets {
            bucket.notifyWhileIndexing = true
            bucket.delegate = self
        }
    }

    @objc
    func configureMainInterface() {
        let storyboard = NSStoryboard(name: .main, bundle: nil)

        mainWindowController = storyboard.instantiateWindowController(ofType: MainWindowController.self)
        splitViewController = storyboard.instantiateViewController(ofType: SplitViewController.self)
        breadcrumbsViewController = storyboard.instantiateViewController(ofType: BreadcrumbsViewController.self)
        tagListViewController = storyboard.instantiateViewController(ofType: TagListViewController.self)
        noteListViewController = storyboard.instantiateViewController(ofType: NoteListViewController.self)
        noteEditorViewController = storyboard.instantiateViewController(ofType: NoteEditorViewController.self)
        noteEditorViewController.metadataCache = noteEditorMetadataCache
    }

    @objc
    func configureSplitViewController() {
        let tagsSplitItem = NSSplitViewItem(sidebarWithViewController: tagListViewController)
        let listSplitItem = NSSplitViewItem(contentListWithViewController: noteListViewController)
        let editorSplitItem = NSSplitViewItem(viewController: noteEditorViewController)

        splitViewController.insertSplitViewItem(tagsSplitItem, kind: .tags)
        splitViewController.insertSplitViewItem(listSplitItem, kind: .notes)
        splitViewController.insertSplitViewItem(editorSplitItem, kind: .editor)
    }

    @objc
    func configureMainWindowController() {
        mainWindowController.contentViewController = splitViewController
        mainWindowController.simplenoteWindow.initialFirstResponder = noteEditorViewController.noteEditor
    }

    @objc
    func configureVerificationCoordinator() {
        verificationCoordinator = AccountVerificationCoordinator(parentViewController: splitViewController)
    }

    @objc
    func configureVersionsController() {
        versionsController = VersionsController(simperium: simperium)
    }

    @objc
    func configureNotesController() {
        noteListViewController.delegate = self
    }

    @objc
    func configureTagsController() {
        tagListViewController.delegate = self
    }

    @objc
    func configureEditorController() {
        noteEditorViewController.tagActionsDelegate = tagListViewController
        noteEditorViewController.noteActionsDelegate = noteListViewController
        noteEditorViewController.editorDelegate = self
    }

    @objc
    func configureEditorMetadataCache() {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileURL = URL(fileURLWithPath: documentsDirectory, isDirectory: true).appendingPathComponent(Constants.noteEditorMetadataCacheFilename)
        noteEditorMetadataCache = NoteEditorMetadataCache(storage: FileStorage(fileURL: fileURL))
    }

    @objc
    func configureAccountDeletionController() {
        accountDeletionController = AccountDeletionController()
    }

    @objc
    func refreshStatusController() {
        guard !Options.shared.statusBarHidden else {
            breadcrumbsViewController.view.removeFromSuperview()
            return
        }

        guard breadcrumbsViewController.view.superview == nil else {
            return
        }

        splitViewController.insertSplitViewStatusBar(breadcrumbsViewController)
    }

    @objc
    var window: Window {
        // TODO: Temporary workaround. Let's get rid of this? please? 🔥🔥🔥
        mainWindowController.window as! Window
    }
}


// MARK: - Public API
//
extension SimplenoteAppDelegate {

    /// Returns the Selected Tag Name. Empty string when none!
    ///
    @objc
    var selectedTagName: String {
        tagListViewController.selectedTagName()
    }

    /// Returns the TagListFilter that matches with the current TagsList selection
    ///
    var selectedTagFilter: TagListFilter {
        tagListViewController.selectedFilter
    }

    /// Displays the Note with the specified SimperiumKey
    ///
    func displayNote(simperiumKey: String) {
        ensureSelectedTagDisplaysNote(key: simperiumKey)
        selectNote(withKey: simperiumKey)
    }

    /// Ensures the Notes List / Tags list are visible
    ///
    func ensureNotesListIsVisible() {
        splitViewController.refreshSplitViewItem(ofKind: .notes, collapsed: false)
    }
}


// MARK: - Actions!
//
extension SimplenoteAppDelegate {

    @IBAction
    func newNoteWasPressed(_ sender: Any) {
        noteEditorViewController.newNoteWasPressed(sender)
        SPTracker.trackShortcutCreateNote()
    }

    @IBAction
    func printWasPressed(_ sender: Any) {
        noteEditorViewController.printAction(sender)
    }

    @IBAction
    func deleteWasPressed(_ sender: Any) {
        noteEditorViewController.deleteAction(sender)
    }

    @IBAction
    func emptyTrashWasPressed(_ sender: Any) {
        tagListViewController.emptyTrashWasPressed(sender)
    }

    @IBAction
    func lineLengthWasPressed(_ sender: Any) {
        guard let item = sender as? NSMenuItem else {
            return
        }

        let isFullOn = item.identifier == NSUserInterfaceItemIdentifier.lineFullMenuItem
        Options.shared.editorFullWidth = isFullOn
    }

    @IBAction
    func notesDisplayModeWasPressed(_ sender: Any) {
        guard let item = sender as? NSMenuItem else {
            return
        }

        let isCondensedOn = item.identifier == NSUserInterfaceItemIdentifier.noteDisplayCondensedMenuItem
        Options.shared.notesListCondensed = isCondensedOn
        SPTracker.trackSettingsListCondensedEnabled(isCondensedOn)
    }

    @IBAction
    func notesSortModeWasPressed(_ sender: Any) {
        guard let item = sender as? NSMenuItem, let identifier = item.identifier, let newMode = SortMode(noteListInterfaceID: identifier) else {
            return
        }

        Options.shared.notesListSortMode = newMode
        SPTracker.trackSettingsNoteListSortMode(newMode.description)
    }

    @IBAction
    func searchWasPressed(_ sender: Any) {
        noteListViewController.beginSearch()
        SPTracker.trackShortcutSearch()
    }

    @IBAction
    func tagsSortModeWasPressed(_ sender: Any) {
        let options = Options.shared
        options.alphabeticallySortTags = !options.alphabeticallySortTags
    }

    @IBAction
    func themeWasPressed(_ sender: Any) {
        guard let item = sender as? NSMenuItem, item.state != .on else {
            return
        }

        guard let option = ThemeOption(rawValue: item.tag) else {
            return
        }

        Options.shared.themeName = option.themeName
    }

    func cycleSidebarAction() {
        splitViewController.cycleSidebarAction()
    }

    @objc
    func focusOnTheNoteList() {
        noteListViewController.focus()
    }

    @objc
    func focusOnTheEditor() {
        noteEditorViewController.focus()
    }

    @objc
    func focusOnTheTags() {
        tagListViewController.focus()
    }

    @IBAction
    func toggleMarkdownPreviewAction(_ sender: Any) {
        noteEditorViewController.toggleMarkdownView(sender)
        SPTracker.trackShortcutToggleMarkdownPreview()
    }

    @IBAction
    func toggleStatusBarAction(_ sender: Any) {
        Options.shared.statusBarHidden.toggle()
        refreshStatusController()

        SPTracker.trackSettingsStatusBarDisplayMode(hidden: Options.shared.statusBarHidden)
    }
}


// MARK: - URL Handlers
//
extension SimplenoteAppDelegate {

    /// Ensures that the Note with the specified Key is displayed by the Notes List
    ///
    func ensureSelectedTagDisplaysNote(key: String) {
        if noteListViewController.displaysNote(with: key) {
            return
        }

        selectAllNotesTag()
    }

    /// Opens the Note associated with a given URL instance, when possible
    ///
    @objc
    func handleOpenNote(url: URL) -> Bool {
        guard let simperiumKey = url.interlinkSimperiumKey else {
            return false
        }

        displayNote(simperiumKey: simperiumKey)
        return true
    }

    // MARK: - Magic Link authentication
    //
    @objc
    func handleMagicAuth(url: URL) -> Bool {
        if simperium.user?.authenticated() == true {
            return false
        }

        return MagicLinkAuthenticator(authenticator: simperium.authenticator).handle(url: url)
    }
}


// MARK: - SPBucketDelegate
//
extension SimplenoteAppDelegate: SPBucketDelegate {

    public func bucketWillStartIndexing(_ bucket: SPBucket!) {
        switch bucket {
        case simperium.notesBucket:
            noteListViewController.setWaitingForIndex(true)

        default:
            break
        }
    }

    public func bucketDidFinishIndexing(_ bucket: SPBucket!) {
        switch bucket {
        case simperium.notesBucket:
            noteListViewController.setWaitingForIndex(false)

        case simperium.accountBucket:
            let payload = bucket.object(forKey: SPCredentials.simperiumEmailVerificationObjectKey) as? [AnyHashable: Any]
            verificationCoordinator.refreshState(verification: payload)

        default:
            break
        }
    }
}


// MARK: - MenuItem(s) Validation
//
extension SimplenoteAppDelegate: NSMenuItemValidation {

    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let identifier = menuItem.identifier else {
            return true
        }

        switch identifier {
        case .lineFullMenuItem, .lineNarrowMenuItem:
            return validateLineLengthMenuItem(menuItem)

        case .emptyTrashMenuItem:
            return validateEmptyTrashMenuItem(menuItem)

        case .exportMenuItem:
            return validateExportMenuItem(menuItem)

        case .focusMenuItem:
            return validateFocusMenuItem(menuItem)

        case .sidebarMenuItem:
            return validateSidebarMenuItem(menuItem)

        case .statusBarMenuItem:
            return validateStatusBarMenuItem(menuItem)

        case .noteDisplayCondensedMenuItem, .noteDisplayComfyMenuItem:
            return validateNotesDisplayMenuItem(menuItem)

        case .noteSortAlphaAscMenuItem, .noteSortAlphaDescMenuItem,
             .noteSortCreateNewestMenuItem, .noteSortCreateOldestMenuItem,
             .noteSortModifyNewestMenuItem, .noteSortModifyOldestMenuItem:

            return validateNotesSortModeMenuItem(menuItem)

        case .systemNewNoteMenuItem:
            return validateSystemNewNoteMenuItem(menuItem)

        case .systemPrintMenuItem:
            return validateSystemPrintMenuItem(menuItem)

        case .systemTrashMenuItem:
            return validateSystemTrashMenuItem(menuItem)

        case .tagSortMenuItem:
            return validateTagSortMenuItem(menuItem)

        case .themeDarkMenuItem, .themeLightMenuItem, .themeSystemMenuItem:
            return validateThemeMenuItem(menuItem)

        case .toggleMarkdownPreview:
            return validateToogleMarkdownPreviewItem(menuItem)

        default:
            return true
        }
    }

    func validateLineLengthMenuItem(_ item: NSMenuItem) -> Bool {
        let isFullItem = item.identifier == .lineFullMenuItem
        let isFullEnabled = Options.shared.editorFullWidth

        item.state = isFullItem == isFullEnabled ? .on : .off

        return true
    }

    func validateEmptyTrashMenuItem(_ item: NSMenuItem) -> Bool {
        return simperium.numberOfDeletedNotes > .zero
    }

    func validateExportMenuItem(_ item: NSMenuItem) -> Bool {
        item.isHidden = !exportUnlocked
        return true
    }

    func validateFocusMenuItem(_ item: NSMenuItem) -> Bool {
        let isFocusModeEnabled = splitViewController.isFocusModeEnabled
        item.state = isFocusModeEnabled ? .on : .off

        return isFocusModeEnabled || noteEditorViewController.isDisplayingNote
    }

    func validateSidebarMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = splitViewController.isTagsCollapsed
                        ? NSLocalizedString("Show Sidebar", comment: "macOS MenuItem that causes the Tag List to be presented")
                        : NSLocalizedString("Hide Sidebar", comment: "macOS MenuItem that causes the Tag List to be hidden")
        return true
    }

    func validateStatusBarMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = Options.shared.statusBarHidden
                        ? NSLocalizedString("Show Status Bar", comment: "macOS MenuItem that causes the Status Bar to be visible")
                        : NSLocalizedString("Hide Status Bar", comment: "macOS MenuItem that causes the Status Bar to be hidden")
        return true
    }

    func validateNotesDisplayMenuItem(_ item: NSMenuItem) -> Bool {
        let isCondensedItem = item.identifier == .noteDisplayCondensedMenuItem
        let isCondensedEnabled = Options.shared.notesListCondensed

        item.state = isCondensedItem == isCondensedEnabled ? .on : .off

        return true
    }

    func validateNotesSortModeMenuItem(_ item: NSMenuItem) -> Bool {
        let isSelected = Options.shared.notesListSortMode.noteListInterfaceID == item.identifier
        item.state = isSelected ? .on : .off
        return true
    }

    func validateTagSortMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.alphabeticallySortTags ? .on : .off
        return true
    }

    func validateThemeMenuItem(_ item: NSMenuItem) -> Bool {
        guard let option = ThemeOption(rawValue: item.tag) else {
            return false
        }

        item.state = SPUserInterface.activeThemeOption == option ? .on : .off
        return true
    }

    func validateSystemNewNoteMenuItem(_ item: NSMenuItem) -> Bool {
        noteEditorViewController.validateSystemNewNoteMenuItem(item)
    }

    func validateSystemPrintMenuItem(_ item: NSMenuItem) -> Bool {
        noteEditorViewController.validateSystemPrintMenuItem(item)
    }

    func validateSystemTrashMenuItem(_ item: NSMenuItem) -> Bool {
        noteEditorViewController.validateSystemTrashMenuItem(item)
    }

    func validateToogleMarkdownPreviewItem(_ item: NSMenuItem) -> Bool {
        noteEditorViewController.validateToogleMarkdownPreviewItem(item)
    }

    /// Updates `active` state of top view controllers based on the current first responder
    ///
    func updateActivePanel(with responder: NSResponder) {
        let viewControllers: [NSResponder] = [tagListViewController, noteListViewController, noteEditorViewController]
        var nextResponder: NSResponder? = responder

        while let currentResponder = nextResponder {
            if viewControllers.contains(currentResponder) {
                let isTagsFocused   = tagListViewController == currentResponder
                let isNotesFocused  = noteListViewController == currentResponder

                tagListViewController.isActive    = isTagsFocused
                noteListViewController.isActive   = isNotesFocused
                breadcrumbsViewController.responderWasUpdated(isTagsActive: isTagsFocused)
                break
            }

            nextResponder = currentResponder.nextResponder
        }
    }
}

// MARK: - Editor Cache
//
extension SimplenoteAppDelegate {
    @objc
    func cleanupEditorMetadataCache() {
        let allKeys = simperium.allNotes.compactMap({ $0.deleted ? nil : $0.simperiumKey })
        noteEditorMetadataCache.cleanup(keeping: allKeys)
    }
}


// MARK: - TagListActionsDelegate Conformance
//
extension SimplenoteAppDelegate: TagsControllerDelegate {

    func tagsControllerDidUpdateFilter(_ controller: TagListViewController) {
        let filter = controller.selectedFilter

        breadcrumbsViewController.tagsControllerDidUpdateFilter(filter)
        noteEditorViewController.tagsControllerDidUpdateFilter(filter)
        noteListViewController.tagsControllerDidUpdateFilter(filter)
    }

    func tagsControllerDidRenameTag(_ controller: TagListViewController, oldName: String, newName: String) {
        noteListViewController.tagsControllerDidRenameTag(oldName: oldName, newName: newName)
        noteEditorViewController.tagsControllerDidRenameTag(oldName: oldName, newName: newName)
        breadcrumbsViewController.tagsControllerDidRenameTag(oldName: oldName, newName: newName)
    }

    func tagsControllerDidDeleteTag(_ controller: TagListViewController, name: String) {
        noteListViewController.tagsControllerDidDeleteTag(name: name)
        noteEditorViewController.tagsControllerDidDeleteTag(name: name)
    }
}


extension SimplenoteAppDelegate: NotesControllerDelegate {

    func notesController(_ controller: NoteListViewController, didSearch query: SearchQuery?) {
        breadcrumbsViewController.notesControllerDidSearch(text: query?.searchText)
        noteEditorViewController.refreshSearchResults(for: query)
    }

    func notesController(_ controller: NoteListViewController, didSelect note: Note) {
        breadcrumbsViewController.notesControllerDidSelectNote(note)
        noteEditorViewController.displayNote(note)
    }

    func notesController(_ controller: NoteListViewController, didSelect notes: [Note]) {
        breadcrumbsViewController.notesControllerDidSelectNotes(notes)
        noteEditorViewController.display(notes)
    }

    func notesControllerDidSelectZeroNotes(_ controller: NoteListViewController) {
        breadcrumbsViewController.notesControllerDidSelectZeroNotes()
        noteEditorViewController.displayNote(nil)
    }
}

extension SimplenoteAppDelegate: EditorControllerDelegate {

    func editorController(_ controller: NoteEditorViewController, updatedNoteContents note: Note) {
        breadcrumbsViewController.editorControllerUpdatedNote(note)
    }
}

// MARK: - Account Deletion
//
extension SimplenoteAppDelegate {
    @objc
    func authenticateSimperiumIfAccountDeletionRequested() {
        guard let deletionController = accountDeletionController else {
            return
        }

        if deletionController.mustReauthenticateSimperium {
            return
        }

        simperium.authenticateIfNecessary()
    }
}



// MARK: - Constants
//
private struct Constants {
    static let noteEditorMetadataCacheFilename = ".editor-metadata-cache"
}
