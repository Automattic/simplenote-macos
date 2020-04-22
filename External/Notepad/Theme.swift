//
//  Theme.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//  Modified for Simplenote usage


import AppKit


// MARK: - Theme
//
class Theme {

    /// Default Font Size
    ///
    private static let defaultFontSize = CGFloat(15)

    /// Headline Font Multiplier
    ///
    private static let firstLineFontMultiplier = CGFloat(1.25)

    /// The body style
    ///
    let bodyStyle: Style

    /// All of the (other) Theme Styles
    ///
    let styles: [Style]

    /// Indicates if the Markdown Styles should be enabled (or not!)
    ///
    let markdownEnabled: Bool
    

    /// Designated Initializer
    ///
    init(markdownEnabled: Bool) {
        self.bodyStyle = Theme.bodyStyle
        self.styles = markdownEnabled ? Theme.markdownStyles : Theme.regularStyles
        self.markdownEnabled = markdownEnabled
    }
}


// MARK: - Styles
//
private extension Theme {

    static var bodyStyle: Style {
        return Style(element: .body, attributes: bodyAttributes)
    }

    static var regularStyles: [Style] {
        return [
            Style(element: .firstLine, attributes: firstLineAttributes)
        ]
    }

    static var markdownStyles: [Style] {
        return [
            Style(element: .h1, attributes: headingAttributes),
            Style(element: .h2, attributes: headingAttributes),
            Style(element: .firstLine, attributes: firstLineAttributes),
            Style(element: .bold, attributes: boldAttributes),
            Style(element: .inlineCode, attributes: codeAttributes),
            Style(element: .italic, attributes: italicAttributes),
            Style(element: .quote, attributes: quoteAttributes),
            Style(element: .url, attributes: urlAttributes),
            Style(element: .image, attributes: urlAttributes),
        ]
    }
}


// MARK: - Private Methods
//
private extension Theme {

    private static var theme: VSTheme {
        return VSThemeManager.shared().theme()
    }

    private static var fontSize: CGFloat {
        var fontSize = CGFloat(UserDefaults.standard.integer(forKey: "kFontSizePreferencesKey"))
        if fontSize == 0 {
            fontSize = defaultFontSize
        }

        return fontSize
    }

    private static var italicFont: NSFont {
        let defaultFont = NSFont.systemFont(ofSize: fontSize)
        return NSFontManager.shared.convert(defaultFont, toHaveTrait: .italicFontMask)
    }
}


// MARK: - Attributes
//
private extension Theme {

    static var bodyAttributes: [NSAttributedString.Key: AnyObject] {
        return [
            .foregroundColor: theme.color(forKey: "textColor"),
            .font: NSFont.systemFont(ofSize: fontSize)
        ]
    }

    static var firstLineAttributes: [NSAttributedString.Key: AnyObject] {
        return [
            .font: NSFont.systemFont(ofSize: fontSize * firstLineFontMultiplier)
        ]
    }

    static var headingAttributes: [NSAttributedString.Key: AnyObject] {
        return [
            .font: NSFont.boldSystemFont(ofSize: fontSize)
        ]
    }

    static var boldAttributes: [NSAttributedString.Key: AnyObject] {
        return [
            .font: NSFont.boldSystemFont(ofSize: fontSize)
        ]
    }

    static var codeAttributes: [NSAttributedString.Key: AnyObject] {
        let codeFont = NSFont(name: "Courier", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)

        return [
            .foregroundColor: theme.color(forKey: "secondaryTextColor"),
            .font: codeFont
        ]
    }

    static var italicAttributes: [NSAttributedString.Key: AnyObject] {
        return [
            .font: italicFont
        ]
    }

    static var quoteAttributes: [NSAttributedString.Key: AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 20.0
        paragraphStyle.firstLineHeadIndent = 20.0
        paragraphStyle.tailIndent = -20.0

        return [
            .font: italicFont,
            .foregroundColor: theme.color(forKey: "secondaryTextColor"),
            .paragraphStyle: paragraphStyle
        ]
    }

    static var urlAttributes: [NSAttributedString.Key: AnyObject] {
        return [
            .foregroundColor: theme.color(forKey: "tintColor")
        ]
    }
}
