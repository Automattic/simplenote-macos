//
//  Theme.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//  Modified for Simplenote usage


import AppKit

class Theme {

    /// Default Font Size
    ///
    private let defaultFontSize = CGFloat(15)

    /// Headline Font Multiplier
    ///
    private let firstLineFontMultiplier = CGFloat(1.25)

    /// The body style
    ///
    let bodyStyle: Style

    /// Regular Styles: Active regardless of the Markdown state
    ///
    private let regularStyles: [Style]

    /// Markdown Styles: Active only when Markdown is enabled
    ///
    private let markdownStyles: [Style]

    /// All of the (other) Theme Styles)
    ///
    var styles: [Style] {
        return markdownEnabled ? markdownStyles : regularStyles
    }

    /// Indicates if the Markdown Styles should be enabled (or not!)
    ///
    var markdownEnabled = false
    

    /// Designated Initializer
    ///
    init() {
        guard let theme = VSThemeManager.shared().theme() else {
            fatalError("Fatal error while trying to load active Theme")
        }

        var fontSize = CGFloat(UserDefaults.standard.integer(forKey: "kFontSizePreferencesKey"))
        if fontSize == 0 {
            fontSize = defaultFontSize
        }
        
        // Styles: Body
        let bodyFont = NSFont.systemFont(ofSize: fontSize)
        let bodyAttributes: [NSAttributedString.Key: AnyObject] = [
            .foregroundColor: theme.color(forKey: "textColor"),
            .font: bodyFont
        ]

        // Styles: First Line
        let firstLineAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: NSFont.systemFont(ofSize: fontSize * firstLineFontMultiplier)
        ]

        // Styles: Heading
        let headingAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: NSFont.boldSystemFont(ofSize: fontSize)
        ]

        // Styles: Bold
        let boldAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: NSFont.boldSystemFont(ofSize: fontSize)
        ]

        // Styles: Code
        let codeFont = NSFont(name: "Courier", size: fontSize) ?? bodyFont
        let codeAttributes: [NSAttributedString.Key : AnyObject] = [
            .foregroundColor: theme.color(forKey: "secondaryTextColor"),
            .font: codeFont
        ]

        // Styles: Italics
        let defaultFont = NSFont.systemFont(ofSize: fontSize)
        let italicFont = NSFontManager.shared.convert(defaultFont, toHaveTrait: .italicFontMask)
        
        let italicAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: italicFont
        ]

        // Styles: Quoted
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 20.0;
        paragraphStyle.firstLineHeadIndent = 20.0;
        paragraphStyle.tailIndent = -20.0;
        
        let quoteAttributes: [NSAttributedString.Key: AnyObject] = [
            .font: italicFont,
            .foregroundColor: theme.color(forKey: "secondaryTextColor"),
            .paragraphStyle: paragraphStyle
        ]

        // Links and Images
        let urlAttributes: [NSAttributedString.Key : AnyObject] = [
            .foregroundColor: theme.color(forKey: "tintColor")
        ]

        // Styles!
        bodyStyle = Style(element: .body, attributes: bodyAttributes)

        regularStyles = [
            Style(element: .firstLine, attributes: firstLineAttributes)
        ]

        markdownStyles = [
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
