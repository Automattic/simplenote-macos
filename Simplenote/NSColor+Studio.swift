import Foundation


// MARK: - Simplenote colors!
//
extension NSColor {

    @objc
    static var textListColor: NSColor {
        // TODO: Drop VSTheme in favor of ColorStudio ASAP. @jlp Mar.23.2020
        return VSThemeManager.shared().theme().color(forKey: "secondaryTextColor")
    }
}
