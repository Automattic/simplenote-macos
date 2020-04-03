import Foundation


// MARK: - NSColor + ColorStudio API
//
extension NSColor {

    /// Initializes a new NSColor instance with a given ColorStudio value
    ///
    convenience init(studioColor: ColorStudio) {
        self.init(hexString: studioColor.rawValue)
    }

    /// Initializes a new NSColor instance with a given ColorStudio Dark / Light set.
    /// Note: in `macOS <10.14` this method will always return a NSColor matching the `Current` Interface mode
    ///
    convenience init(lightColor: ColorStudio, darkColor: ColorStudio) {
        guard #available(macOS 10.15, *) else {
            let targetColor = SPUserInterface.isDark ? darkColor : lightColor
            self.init(studioColor: targetColor)
            return
        }

        self.init(name: nil, dynamicProvider: { appearance in
            let studioColor = appearance.isDark ? darkColor : lightColor
            return NSColor(studioColor: studioColor)
        })
    }
}


// MARK: - Simplenote colors!
//
extension NSColor {

    @objc
    static var simplenoteBlue30Color: NSColor {
        NSColor(studioColor: .blue30)
    }

    @objc
    static var colorForCellSelection: NSColor {
        NSColor(calibratedRed: 165.0/255.0, green: 190.0/255.0, blue: 234.0/255.0, alpha: 1.0)
    }

    @objc
    static var textListColor: NSColor {
        // TODO: Drop VSTheme in favor of ColorStudio ASAP. @jlp Mar.23.2020
        return VSThemeManager.shared().theme().color(forKey: "secondaryTextColor")
    }
}
