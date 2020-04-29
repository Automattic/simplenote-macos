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

        // TODO: VSTheme is **SO**... SOO absolutely gone >> SOON
        VSThemeManager.shared().swapTheme(option.themeName)
        Options.shared.themeName = option.themeName
    }
}


// MARK: - MenuItem(s) Validation
//
extension SimplenoteAppDelegate {

    @objc
    func isThemeMenuItem(_ item: NSMenuItem) -> Bool {
        guard let identifier = item.menu?.identifier else {
            return false
        }

        return identifier == .themeMenuIdentifier
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
