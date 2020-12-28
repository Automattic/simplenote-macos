import Foundation


// MARK: - Initialization
//
extension SimplenoteAppDelegate {

    @objc
    func configureSimperium() {
        guard let simperium = Simperium(model: managedObjectModel, context: managedObjectContext, coordinator: persistentStoreCoordinator),
              let config = SPAuthenticationConfiguration.sharedInstance()
        else {
            fatalError()
        }

        simperium.delegate = self
        simperium.presentsLoginByDefault = true
        simperium.verboseLoggingEnabled = false
        simperium.authenticationWindowControllerClass = LoginWindowController.classForCoder()

        simperium.authenticator.providerString = SPCredentials.simperiumProviderString

        config.logoImageName = .simplenoteLogoLogin
        config.controlColor = .simplenoteBrandColor
        config.forgotPasswordURL = SPCredentials.simperiumForgotPasswordURL
        config.resetPasswordURL = SPCredentials.simperiumResetPasswordURL

        self.simperium = simperium
    }

    @objc
    func configureMainInterface() {
        let storyboard = NSStoryboard(name: .main, bundle: nil)

        let mainWindowController = storyboard.instantiateWindowController(ofType: MainWindowController.self)
        let splitViewController = mainWindowController.contentViewController as! SplitViewController
        let tagListViewController = storyboard.instantiateViewController(ofType: TagListViewController.self)
        let notesViewController = storyboard.instantiateViewController(ofType: NoteListViewController.self)
        let editorViewController = storyboard.instantiateViewController(ofType: NoteEditorViewController.self)

        let tagsSplitItem = NSSplitViewItem(sidebarWithViewController: tagListViewController)
        let listSplitItem = NSSplitViewItem(contentListWithViewController: notesViewController)
        let editorSplitItem = NSSplitViewItem(viewController: editorViewController)

        splitViewController.insertSplitViewItem(tagsSplitItem, kind: .tags)
        splitViewController.insertSplitViewItem(listSplitItem, kind: .notes)
        splitViewController.insertSplitViewItem(editorSplitItem, kind: .editor)

        self.mainWindowController = mainWindowController
        self.splitViewController = splitViewController
        self.tagListViewController = tagListViewController
        self.noteListViewController = notesViewController
        self.noteEditorViewController = editorViewController
    }

    @objc
    func configureInitialResponder() {
        window.initialFirstResponder = noteEditorViewController.noteEditor
    }

    @objc
    func configureVersionsController() {
        versionsController = VersionsController(simperium: simperium)
    }

    @objc
    func configureEditorController() {
        noteEditorViewController.tagActionsDelegate = tagListViewController
        noteEditorViewController.noteActionsDelegate = noteListViewController
        noteEditorViewController.searchDelegate = noteListViewController
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
        noteEditorViewController.beginSearch()
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
}


// MARK: - URL Handlers
//
extension SimplenoteAppDelegate {

    /// Ensures that the Note with the specified Key is displayed by the Notes List
    ///
    func ensureSelectedTagDisplaysNote(key: String) {
        if noteListViewController.displaysNote(forKey: key) {
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
}
