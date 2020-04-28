import Foundation


// MARK: - MARK: Actions!
//
extension SimplenoteAppDelegate {

    @IBAction
    func changeThemeAction(_ sender: Any) {
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


// MARK: - Theme Menu
//
extension SimplenoteAppDelegate {

    func refreshThemeMenu() {
        let selectedItemTag = SPUserInterface.activeThemeOption.rawValue

        for item in themeMenu.items {
            item.state = (item.tag == selectedItemTag) ? .on : .off
        }
    }
}


// MARK: - NSMenuDelegate
//
extension SimplenoteAppDelegate: NSMenuDelegate {

    public func menuWillOpen(_ menu: NSMenu) {
        guard menu == themeMenu else {
            return
        }

        refreshThemeMenu()
    }
}
