import Foundation


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
        // Whenever a given NSMenuItem doesn't have an Identifier set, we'll check if the containing NSMenu has one
        guard let identifier = menuItem.identifier ?? menuItem.menu?.identifier else {
            return true
        }

        switch identifier {
        case .emptyTrashItemIdentifier:
            return validateEmptyTrashMenuItem(menuItem)
        case .exportItemIdentifier:
            return validateExportMenuItem(menuItem)
        case .focusItemIdentifier:
            return validateFocusMenuItem(menuItem)
        case .themeMenuIdentifier:
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
        item.state = splitViewController.isNotesListCollapsed ? .on : .off
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
