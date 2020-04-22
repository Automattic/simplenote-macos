import Foundation


// MARK: - Simplenote Colors
//
extension NSColor {

    /// Returns the color to be applied over Lists
    ///
    @objc
    static var textListColor: NSColor {
        // TODO: Drop VSTheme in favor of ColorStudio ASAP. @jlp Mar.23.2020
        return VSThemeManager.shared().theme().color(forKey: "secondaryTextColor")
    }
}
