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
    func clickedEmptyTrashItem(_ sender: Any) {
        tagListViewController.emptyTrashAction(sender: sender)
    }

    @IBAction
    func clickedTagsSortModeItem(_ sender: Any) {
        let options = Options.shared
        options.alphabeticallySortTags = !options.alphabeticallySortTags
    }

    @IBAction
    func clickedThemeItem(_ sender: Any) {
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
        case .emptyTrashMenuItem:
            return validateEmptyTrashMenuItem(menuItem)
        case .exportMenuItem:
            return validateExportMenuItem(menuItem)
        case .focusMenuItem:
            return validateFocusMenuItem(menuItem)
        case .tagSortMenuItem:
            return validateTagSortMenuItem(menuItem)
        case .themeDarkMenuItem, .themeLightMenuItem, .themeSystemMenuItem:
            return validateThemeMenuItem(menuItem)
        default:
            return true
        }
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
