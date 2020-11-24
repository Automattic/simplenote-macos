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

    /// Initializes a new dynamic NSColor instance, that will automatically react to Appearance changes
    /// Note: In `macOS <10.15` this API will always return the NSColor matching the `Current` Appearance
    ///
    static func dynamicColor(lightColor: NSColor, darkColor: NSColor) -> NSColor {
        guard #available(macOS 10.15, *) else {
            return SPUserInterface.isDark ? darkColor : lightColor
        }

        return NSColor(name: nil) {
            $0.isDark ? darkColor : lightColor
        }
    }

    /// Initializes a new dynamic NSColor instance that will automatically react to Appearance changes
    /// Note: In `macOS <10.15` this API will always return the NSColor matching the `Current` Appearance
    ///
    static func dynamicColor(lightStudio: ColorStudio, darkStudio: ColorStudio) -> NSColor {
        guard #available(macOS 10.15, *) else {
            return NSColor(studioColor: SPUserInterface.isDark ? darkStudio : lightStudio)
        }

        return NSColor(name: nil) {
            NSColor(studioColor: $0.isDark ? darkStudio : lightStudio)
        }
    }
}


// MARK: - Simplenote Colors!
//
extension NSColor {

    @objc
    static var simplenoteActionButtonTintColor: NSColor {
        dynamicColor(lightStudio: .spBlue50, darkStudio: .spBlue30)
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
    static var simplenoteSecondaryBackgroundColor: NSColor {
        .simplenoteControlBackgroundColor
    }

    @objc
    static var simplenoteSelectedBackgroundColor: NSColor {
        NSColor(studioColor: .spBlue50)
    }

    @objc
    static var simplenotePopoverBackgroundColor: NSColor {
        .simplenoteUnderPageBackgroundDarkColor
    }

    @objc
    static var simplenotePlaceholderTintColor: NSColor {
        dynamicColor(lightStudio: .gray5, darkStudio: .gray60)
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
        dynamicColor(lightStudio: .spBlue50, darkStudio: .spBlue30)
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

    @objc
    static var simplenoteBrandColor: NSColor {
        NSColor(studioColor: .spBlue50)
    }

    @objc
    static var simplenoteTokenBackgroundColor: NSColor {
        dynamicColor(lightColor: .simplenoteTokenBackgroundLightColor, darkColor: .simplenoteTokenBackgroundDarkColor)
    }

    @objc
    static var simplenoteTokenSelectedBackgroundColor: NSColor {
        dynamicColor(lightColor: .simplenoteTokenSelectedBackgroundLightColor, darkColor: .simplenoteTokenSelectedBackgroundDarkColor)
    }
}


// MARK: - Internal Colors
//
private extension NSColor {

    static var simplenoteUnderPageBackgroundColor: NSColor {
        dynamicColor(lightColor: .white, darkColor: .simplenoteUnderPageBackgroundDarkColor)
    }

    static var simplenoteControlBackgroundColor: NSColor {
        return dynamicColor(lightColor: .white, darkColor: .controlBackgroundColor)
    }

    static var simplenoteUnderPageBackgroundDarkColor: NSColor {
        if #available(OSX 10.14, *) {
            return .underPageBackgroundColor
        }

        return NSColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)
    }

    static var simplenoteControlBackgroundDarkColor: NSColor {
        NSColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
    }

    static var simplenoteSecondarySelectedBackgroundDarkColor: NSColor {
        NSColor(calibratedWhite: 1.0, alpha: 0.1)
    }

    static var simplenoteSecondarySelectedBackgroundLightColor: NSColor {
        NSColor(studioColor: .spBlue5)
    }

    static var simplenoteTokenBackgroundLightColor: NSColor {
        NSColor(calibratedWhite: 216.0 / 255.0, alpha: 1.0)
    }

    static var simplenoteTokenBackgroundDarkColor: NSColor {
        NSColor(calibratedWhite: 1.0, alpha: 0.22)
    }

    static var simplenoteTokenSelectedBackgroundLightColor: NSColor {
        NSColor(calibratedWhite: 176.0 / 255.0, alpha: 1.0)
    }

    static var simplenoteTokenSelectedBackgroundDarkColor: NSColor {
        NSColor(calibratedWhite: 1.0, alpha: 0.42)
    }
}
