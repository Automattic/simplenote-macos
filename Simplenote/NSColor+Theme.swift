import Foundation


// MARK: - NSColor + Theme API
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


// MARK: - Simplenote Colors!
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
    static var simplenoteSecondarySelectedBackgroundColor: NSColor {
        dynamicColor(lightColor: .mojaveBlue197, darkColor: .mojaveBlack85)
    }

    @objc
    static var simplenoteDividerColor: NSColor {
        dynamicColor(lightColor: NSColor(studioColor: .gray10), darkColor: .black)
    }

    @objc
    static var simplenoteControlBackgroundColor: NSColor {
        dynamicColor(lightColor: .white, darkColor: .mojaveBlack85)
    }

    @objc
    static var simplenoteSecondaryControlBackgroundColor: NSColor {
        dynamicColor(lightColor: .white, darkColor: .mojaveBlack)
    }


    @objc
    static var simplenotePopoverTextColor: NSColor {
        .white
    }

    @objc
    static var simplenoteTextColor: NSColor {
        dynamicColor(lightStudio: .gray80, darkStudio: .white)
    }

    /// Note Preview Body
    @objc
    static var simplenoteSecondaryTextColor: NSColor {
        dynamicColor(lightStudio: .gray60, darkStudio: .gray20)
    }



    @objc
    static var simplenoteSecondaryPlaceholderColor: NSColor {
        dynamicColor(lightStudio: .gray50, darkStudio: .gray20)
    }

    @objc
    static var simplenoteLinkColor: NSColor {
        NSColor(studioColor: .blue30)
    }




    @objc
    static var simplenoteTextListColor: NSColor {
        .simplenoteTextColor
    }

    class var mojaveBlack: NSColor {
        NSColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 1.0)
    }

    @objc
    class var mojaveBlack85: NSColor {
        NSColor(red: 54.0/255.0, green: 54.0/255.0, blue: 54.0/255.0, alpha: 0.4)
    }

    class var mojaveBlue197: NSColor {
        NSColor(calibratedRed: 197.0 / 255.0, green: 217.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    }
}
