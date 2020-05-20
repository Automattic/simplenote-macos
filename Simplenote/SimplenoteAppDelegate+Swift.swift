import Foundation


// MARK: - Initialization
//
extension SimplenoteAppDelegate {

    @objc
    func configureSplitView() {
        precondition(tagListViewController != nil)
        precondition(noteListViewController != nil)
        precondition(noteEditorViewController != nil)

        // NOTE:
        // This initialization is in a midway stage. We're essentially "stealing" the ViewController(s) views,
        // which are already in the hierarchy defined by MainMenu.nib, and placing them in a fresh SplitViewController.
        //
        // Our endgame is to initialize the three viewController via code, and split / simplify the main nib.
        //
        //  >>> To be revisited >>> REALLY >>> SOON >>>
        //
        let tagsSplitItem = NSSplitViewItem(sidebarWithViewController: tagListViewController)
        let listSplitItem = NSSplitViewItem(contentListWithViewController: noteListViewController)
        let editorSplitItem = NSSplitViewItem(viewController: noteEditorViewController)

        let splitViewController = SplitViewController()
        splitViewController.insertSplitViewItem(tagsSplitItem, kind: .tags)
        splitViewController.insertSplitViewItem(listSplitItem, kind: .notes)
        splitViewController.insertSplitViewItem(editorSplitItem, kind: .editor)
        self.splitViewController = splitViewController
    }

    @objc
    func configureWindow() {
        precondition(window != nil)
        precondition(splitViewController != nil)

        window.contentViewController = splitViewController
        window.initialFirstResponder = noteEditorViewController.noteEditor
    }
}


// MARK: - Actions!
//
extension SimplenoteAppDelegate {

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
        return numDeletedNotes() > .zero
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
