import Foundation


// MARK: - NSColor + Theme API
//
extension NSColor {

    /// Initializes a new NSColor instance with a given ColorStudio value
    ///
    convenience init(studioColor: ColorStudio, alpha: CGFloat = AppKitConstants.alpha1_0) {
        self.init(hexString: studioColor.rawValue, alpha: alpha)
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
    static func dynamicColor(lightStudio: ColorStudio,
                             darkStudio: ColorStudio,
                             lightColorAlpha: CGFloat = AppKitConstants.alpha1_0,
                             darkColorAlpha: CGFloat = AppKitConstants.alpha1_0) -> NSColor {
        let colorProvider: (_ isDark: Bool) -> (value: ColorStudio, alpha: CGFloat) = { isDark in
            if isDark {
                return (darkStudio, darkColorAlpha)
            }
            return (lightStudio, lightColorAlpha)
        }

        guard #available(macOS 10.15, *) else {
            let targetColor = colorProvider(SPUserInterface.isDark)
            return NSColor(studioColor: targetColor.value, alpha: targetColor.alpha)
        }

        return NSColor(name: nil) {
            let targetColor = colorProvider($0.isDark)
            return NSColor(studioColor: targetColor.value, alpha: targetColor.alpha)
        }
    }
}


// MARK: - Simplenote Colors!
//
extension NSColor {

    @objc
    static var simplenoteAccessoryTintColor: NSColor {
        dynamicColor(lightStudio: .spBlue50, darkStudio: .spBlue30)
    }

    @objc
    static var simplenoteActionButtonTintColor: NSColor {
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
        dynamicColor(lightStudio: .spBlue5, darkStudio: .spBlue50, darkColorAlpha: AppKitConstants.alpha0_4)
    }

    @objc
    static var simplenoteSelectedInactiveBackgroundColor: NSColor {
        dynamicColor(lightStudio: .gray5, darkStudio: .white, darkColorAlpha: AppKitConstants.alpha0_1)
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
        NSColor(studioColor: .spBlue50)
    }

    @objc
    static var simplenoteSecondarySelectedInactiveBackgroundColor: NSColor {
        dynamicColor(lightStudio: .black, darkStudio: .white, lightColorAlpha: AppKitConstants.alpha0_1, darkColorAlpha: AppKitConstants.alpha0_1)
    }

    @objc
    static var simplenoteDividerColor: NSColor {
        dynamicColor(lightStudio: .gray5, darkStudio: .black)
    }

    @objc
    static var simplenoteSecondaryDividerColor: NSColor {
        dynamicColor(lightColor: simplenoteSecondaryDividerLightColor, darkColor: simplenoteSecondaryDividerDarkColor)
    }

    @objc
    static var simplenoteSidebarDividerColor: NSColor {
        dynamicColor(lightColor: simplenoteSidebarDividerLightColor, darkColor: .black)
    }

    @objc
    static var simplenoteLinkColor: NSColor {
        dynamicColor(lightStudio: .spBlue50, darkStudio: .spBlue30)
    }

    @objc
    static var simplenoteTextColor: NSColor {
        dynamicColor(lightStudio: .gray90, darkStudio: .gray5)
    }

    @objc
    static var simplenoteSecondaryTextColor: NSColor {
        dynamicColor(lightStudio: .gray50, darkStudio: .gray30)
    }

    @objc
    static var simplenoteTertiaryTextColor: NSColor {
        dynamicColor(lightStudio: .gray20, darkStudio: .gray20)
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
    static var simplenoteEditorTextColor: NSColor {
        dynamicColor(lightStudio: .gray70, darkStudio: .gray5)
    }

    @objc
    static var simplenoteTokenBackgroundColor: NSColor {
        dynamicColor(lightColor: .simplenoteTokenBackgroundLightColor, darkColor: .simplenoteTokenBackgroundDarkColor)
    }

    @objc
    static var simplenoteTokenSelectedBackgroundColor: NSColor {
        dynamicColor(lightColor: .simplenoteTokenSelectedBackgroundLightColor, darkColor: .simplenoteTokenSelectedBackgroundDarkColor)
    }

    @objc
    static var simplenoteStatusBarBackgroundColor: NSColor {
        dynamicColor(lightStudio: .gray0, darkStudio: .darkGray2)
    }

    @objc
    static var simplenoteStatusBarTextColor: NSColor {
        NSColor(studioColor: .gray30)
    }

    @objc
    static var simplenoteStatusBarHighlightedTextColor: NSColor {
        dynamicColor(lightStudio: .gray90, darkStudio: .white)
    }

    @objc
    static var simplenoteAlertTextColor: NSColor {
        dynamicColor(lightStudio: .black, darkStudio: .white)
    }

    @objc
    static var simplenoteAlertPrimaryActionTextColor: NSColor {
        .white
    }

    @objc
    static var simplenoteAlertPrimaryActionBackgroundColor: NSColor {
        .simplenoteBrandColor
    }

    @objc
    static var simplenoteAlertPrimaryActionHighlightedBackgroundColor: NSColor {
        let blendFraction = CGFloat(0.1)
        let output = NSColor.simplenoteBrandColor.blended(withFraction: blendFraction, of: .simplenoteAlertTextColor)

        return output ?? .simplenoteBrandColor
    }

    static var simplenoteExcerptHighlightColor: NSColor {
        dynamicColor(lightStudio: .spBlue50, darkStudio: .spBlue30)
    }

    static var simplenoteSelectedExcerptHighlightColor: NSColor {
        dynamicColor(lightStudio: .spBlue50, darkStudio: .spBlue20)
    }

    static var simplenoteEditorSearchHighlightColor: NSColor {
        dynamicColor(lightStudio: .spBlue5, darkStudio: .spBlue50, darkColorAlpha: AppKitConstants.alpha0_5)
    }

    static var simplenoteSearchBarBackgroundColor: NSColor {
        dynamicColor(lightStudio: .gray5, darkStudio: .white, lightColorAlpha: AppKitConstants.alpha0_1, darkColorAlpha: AppKitConstants.alpha0_05)
    }

    @objc
    static var simplenoteSearchBarHighlightedBorderColor: NSColor {
        dynamicColor(lightStudio: .spBlue50, darkStudio: .spBlue30, lightColorAlpha: AppKitConstants.alpha0_4, darkColorAlpha: AppKitConstants.alpha0_4)
    }

    @objc
    static var simplenoteAlertControlBackgroundColor: NSColor {
        dynamicColor(lightStudio: .white, darkStudio: .red50)
    }

    @objc
    static var simplenoteAlertControlTextColor: NSColor {
        dynamicColor(lightStudio: .red50, darkStudio: .white, lightColorAlpha: AppKitConstants.alpha0_8, darkColorAlpha: AppKitConstants.alpha0_8)
    }

    @objc
    static var buttonShadowColor: NSColor {
        dynamicColor(lightStudio: .black, darkStudio: .white, lightColorAlpha: AppKitConstants.alpha0_3, darkColorAlpha: AppKitConstants.alpha0_5)
    }

    @objc
    static var simplenotePreferencesDividerColor: NSColor {
        dynamicColor(lightStudio: .black, darkStudio: .white, lightColorAlpha: AppKitConstants.alpha0_1, darkColorAlpha: AppKitConstants.alpha0_1)
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

    static var simplenoteSecondarySelectedBackgroundLightColor: NSColor {
        NSColor(calibratedWhite: 0.0, alpha: 0.1)
    }

    static var simplenoteSecondarySelectedBackgroundDarkColor: NSColor {
        NSColor(calibratedWhite: 1.0, alpha: 0.1)
    }

    static var simplenoteSecondaryDividerLightColor: NSColor {
        NSColor(studioColor: .gray5)
    }

    static var simplenoteSecondaryDividerDarkColor: NSColor {
        NSColor(calibratedWhite: 255.0, alpha: 0.1)
    }

    static var simplenoteSidebarDividerLightColor: NSColor {
        NSColor(calibratedWhite: 0.0, alpha: 0.1)
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
