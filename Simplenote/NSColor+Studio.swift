import Foundation


// MARK: - NSColor + ColorStudio API
//
extension NSColor {

    /// Initializes a new NSColor instance with a given ColorStudio value
    ///
    convenience init(studioColor: ColorStudio) {
        self.init(hexString: studioColor.rawValue)
    }

    /// Initializes a new dynamic NSColor instance that will automatically react to Appearance changes
    /// Note: In `macOS <10.15` this API will always return the NSColor matching the `Current` Appearance
    ///
    static func dynamicColor(lightStudio: ColorStudio, darkStudio: ColorStudio) -> NSColor {
        guard #available(macOS 10.15, *) else {
            let targetColor = SPUserInterface.isDark ? darkStudio : lightStudio
            return NSColor(studioColor: targetColor)
        }

        return NSColor(name: nil, dynamicProvider: { appearance in
            let studioColor = appearance.isDark ? darkStudio : lightStudio
            return NSColor(studioColor: studioColor)
        })
    }

    /// Initializes a new dynamic NSColor instance, that will automatically react to Appearance changes
    /// Note: In `macOS <10.15` this API will always return the NSColor matching the `Current` Appearance
    ///
    static func dynamicColor(lightColor: NSColor, darkColor: NSColor) -> NSColor {
        guard #available(macOS 10.15, *) else {
            return SPUserInterface.isDark ? darkColor : lightColor
        }

        return NSColor(name: nil, dynamicProvider: { appearance in
            return appearance.isDark ? darkColor : lightColor
        })
    }
}


// MARK: - Simplenote colors!
//
extension NSColor {

    @objc
    static var simplenoteEmptyStateTextColor: NSColor {
        dynamicColor(lightStudio: .gray5, darkStudio: .darkGray3)
    }

    @objc
    static var simplenoteSearchBarTextColor: NSColor {
        dynamicColor(lightStudio: .black, darkStudio: .white)
    }

    @objc
    static var simplenoteTagListRegularTextColor: NSColor {
        dynamicColor(lightStudio: .gray80, darkStudio: .white)
    }

    @objc
    static var simplenoteTagListSelectedTextColor: NSColor {
        .white
    }

    @objc
    static var simplenoteTagListEditingTextColor: NSColor {
        dynamicColor(lightStudio: .gray80, darkStudio: .white)
    }






    @objc
    static var simplenoteActionButtonTintColor: NSColor {
        dynamicColor(lightStudio: .blue50, darkStudio: .blue30)
    }

    @objc
    static var simplenoteSelectedBackgroundColor: NSColor {
        NSColor(studioColor: .blue50)
    }

    @objc
    static var textListColor: NSColor {
        // TODO: Replace with ColorStudio
        return VSThemeManager.shared().theme().color(forKey: "secondaryTextColor")
    }
}
