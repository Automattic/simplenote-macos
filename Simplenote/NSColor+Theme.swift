import Foundation


// MARK: - NSColor + Theme API
//
extension NSColor {

    /// Initializes a new NSColor instance with a given ColorStudio value
    ///
    convenience init(studioColor: ColorStudio) {
        self.init(hexString: studioColor.rawValue)
    }
}


// MARK: - Dynamic Colors
//
extension NSColor {

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


// MARK: - Simplenote Colors!
//
extension NSColor {

    @objc
    static var simplenoteActionButtonTintColor: NSColor {
        dynamicColor(lightStudio: .blue50, darkStudio: .blue30)
    }

    @objc
    static var simplenoteSecondaryActionButtonTintColor: NSColor {
        dynamicColor(lightStudio: .gray50, darkStudio: .gray30)
    }

    @objc
    static var simplenoteBackgroundColor: NSColor {
        .simplenoteUnderPageBackgroundColor
    }

    @objc
    static var simplenoteSelectedBackgroundColor: NSColor {
        NSColor(studioColor: .blue50)
    }

    @objc
    static var simplenoteSecondarySelectedBackgroundColor: NSColor {
        dynamicColor(lightColor: .simplenoteSecondarySelectedBackgroundLightColor, darkColor: .simplenoteSecondarySelectedBackgroundDarkColor)
    }

    @objc
    static var simplenoteDividerColor: NSColor {
        dynamicColor(lightStudio: .gray10, darkStudio: .black)
    }

    @objc
    static var simplenoteLinkColor: NSColor {
        dynamicColor(lightStudio: .blue50, darkStudio: .blue30)
    }

    @objc
    static var simplenoteTextColor: NSColor {
        dynamicColor(lightStudio: .gray80, darkStudio: .white)
    }

    @objc
    static var simplenoteSecondaryTextColor: NSColor {
        dynamicColor(lightStudio: .gray60, darkStudio: .gray20)
    }

    @objc
    static var simplenoteSelectedTextColor: NSColor {
        .white
    }
}


// MARK: - Internal Colors
//
private extension NSColor {

    // TODO: Review
    static var simplenoteUnderPageBackgroundColor: NSColor {
        if #available(OSX 10.14, *) {
            return dynamicColor(lightColor: .white, darkColor: .underPageBackgroundColor)
        }

        return dynamicColor(lightColor: .white, darkColor: .simplenoteUnderPageBackgroundDarkColor)
    }

    // TODO: Review
    static var simplenoteUnderPageBackgroundDarkColor: NSColor {
        NSColor(red: 41.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)
    }

    // TODO: Review
    static var simplenoteSecondarySelectedBackgroundDarkColor: NSColor {
        NSColor(red: 54.0 / 255.0, green: 54.0 / 255.0, blue: 54.0 / 255.0, alpha: 0.4)
    }

    // TODO: Review
    static var simplenoteSecondarySelectedBackgroundLightColor: NSColor {
        NSColor(red: 197.0 / 255.0, green: 217.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    }
}
