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
        guard let identifier = menuItem.identifier else {
            return true
        }

        switch identifier {
        case .emptyTrashItemIdentifier:
            return validateTrashMenuItem(menuItem)
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

    func validateTrashMenuItem(_ item: NSMenuItem) -> Bool {
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
