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
extension SimplenoteAppDelegate {

    @objc
    func isEmptyTrashMenuItem(_ item: NSMenuItem) -> Bool {
        return item.identifier == NSUserInterfaceItemIdentifier.emptyTrashItemIdentifier
    }

    @objc
    func isFocusMenuItem(_ item: NSMenuItem) -> Bool {
        return item.identifier == NSUserInterfaceItemIdentifier.focusItemIdentifier
    }

    @objc
    func isThemeMenuItem(_ item: NSMenuItem) -> Bool {
        return item.menu?.identifier == NSUserInterfaceItemIdentifier.themeMenuIdentifier
    }

    @objc
    func isExportMenuItem(_ item: NSMenuItem) -> Bool {
        return item.identifier == NSUserInterfaceItemIdentifier.exportItemIdentifier
    }

    @objc
    func validateExportMenuItem(_ item: NSMenuItem) -> Bool {
        item.isHidden = !exportUnlocked
        return true
    }

    @objc
    func validateFocusMenuItem(_ item: NSMenuItem) -> Bool {
        item.state = noteListViewController.view.isHidden ? .on : .off
        return true
    }

    @objc
    func validateThemeMenuItem(_ item: NSMenuItem) -> Bool {
        guard let option = ThemeOption(rawValue: item.tag) else {
            return false
        }

        item.state = SPUserInterface.activeThemeOption == option ? .on : .off

        // System Appearance must only be available in Mojave
        return option != .system ? true : NSApplication.runningOnMojaveOrLater
    }
}
