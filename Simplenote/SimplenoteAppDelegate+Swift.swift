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
        Options.shared.themeName = option.themeName
        VSThemeManager.shared().swapTheme(option.themeName)
    }
}


// MARK: - Theme Menu
//
extension SimplenoteAppDelegate {

    func displaySystemThemeOptionIfNeeded() {
        guard #available(macOS 10.14, *) else {
            return
        }

        themeMenu.item(withTag: ThemeOption.system.rawValue)?.isHidden = false
    }

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

        displaySystemThemeOptionIfNeeded()
        refreshThemeMenu()
    }
}
