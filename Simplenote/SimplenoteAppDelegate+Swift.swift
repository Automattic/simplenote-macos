import Foundation


// MARK: - Initialization
//
extension SimplenoteAppDelegate {

    @objc
    func configureSplitView() {
        let storyboard = NSStoryboard(name: .main, bundle: nil)

        let splitViewController = storyboard.instantiateViewController(ofType: SplitViewController.self)
        let tagListViewController = storyboard.instantiateViewController(ofType: TagListViewController.self)
        let notesViewController = storyboard.instantiateViewController(ofType: NoteListViewController.self)
        let editorViewController = storyboard.instantiateViewController(ofType: NoteEditorViewController.self)

        let tagsSplitItem = NSSplitViewItem(sidebarWithViewController: tagListViewController)
        let listSplitItem = NSSplitViewItem(contentListWithViewController: notesViewController)
        let editorSplitItem = NSSplitViewItem(viewController: editorViewController)

        splitViewController.insertSplitViewItem(tagsSplitItem, kind: .tags)
        splitViewController.insertSplitViewItem(listSplitItem, kind: .notes)
        splitViewController.insertSplitViewItem(editorSplitItem, kind: .editor)

        self.splitViewController = splitViewController
        self.tagListViewController = tagListViewController
        self.noteListViewController = notesViewController
        self.noteEditorViewController = editorViewController
    }

    @objc
    func configureWindow() {
        window.contentViewController = splitViewController
        window.initialFirstResponder = noteEditorViewController.noteEditor
        window.setFrameAutosaveName(.mainWindow)
    }

    @objc
    func configureVersionsController() {
        versionsController = VersionsController(simperium: simperium)
    }

    @objc
    func configureEditorController() {
        noteEditorViewController.tagActionsDelegate = tagListViewController
        noteEditorViewController.noteActionsDelegate = noteListViewController
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
}


// MARK: - Actions!
//
extension SimplenoteAppDelegate {

    @IBAction
    func emptyTrashWasPressed(_ sender: Any) {
        tagListViewController.emptyTrashAction(sender: sender)
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
        guard let item = sender as? NSMenuItem else {
            return
        }

        let isAlphaOn = item.identifier == NSUserInterfaceItemIdentifier.noteSortAlphaMenuItem
        Options.shared.alphabeticallySortNotes = isAlphaOn
        SPTracker.trackSettingsAlphabeticalSortEnabled(isAlphaOn)
    }

    @IBAction
    func searchWasPressed(_ sender: Any) {
        noteListViewController.searchAction(sender)
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


// MARK: - MenuItem(s) Validation
//
extension SimplenoteAppDelegate: NSMenuItemValidation {

    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let identifier = menuItem.identifier else {
            return true
        }

        switch identifier {
        case .lineFullMenuItem:
            return validateEditorWidthFullMenuItem(menuItem)
        case .lineNarrowMenuItem:
            return validateEditorWidthNarrowMenuItem(menuItem)
        case .emptyTrashMenuItem:
            return validateEmptyTrashMenuItem(menuItem)
        case .exportMenuItem:
            return validateExportMenuItem(menuItem)
        case .focusMenuItem:
            return validateFocusMenuItem(menuItem)
        case .noteDisplayCondensedMenuItem:
            return validateNotesDisplayCondensedMenuItem(menuItem)
        case .noteDisplayComfyMenuItem:
            return validateNotesDisplayComfyMenuItem(menuItem)
        case .noteSortAlphaMenuItem:
            return validateNotesSortAlphaMenuItem(menuItem)
        case .noteSortUpdatedMenuItem:
            return validateNotesSortUpdatedMenuItem(menuItem)
        case .tagSortMenuItem:
            return validateTagSortMenuItem(menuItem)
        case .themeDarkMenuItem, .themeLightMenuItem, .themeSystemMenuItem:
            return validateThemeMenuItem(menuItem)
        default:
            return true
        }
    }

    func validateEditorWidthFullMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.editorFullWidth ? .on : .off
        return true
    }

    func validateEditorWidthNarrowMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.editorFullWidth ? .off : .on
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
        let inFocusModeEnabled = splitViewController.isFocusModeEnabled
        item.state = inFocusModeEnabled ? .on : .off

        return inFocusModeEnabled || noteEditorViewController.isDisplayingNote
    }

    func validateNotesDisplayCondensedMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.notesListCondensed ? .on : .off
        return true
    }

    func validateNotesDisplayComfyMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.notesListCondensed ? .off : .on
        return true
    }

    func validateNotesSortAlphaMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.alphabeticallySortNotes ? .on : .off
        return true
    }

    func validateNotesSortUpdatedMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = Options.shared.alphabeticallySortNotes ? .off : .on
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

        // System Appearance must only be available in Mojave
        return option != .system ? true : NSApplication.runningOnMojaveOrLater
    }
}
