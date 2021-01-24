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
    private static let defaultFontSize = CGFloat(14)

    /// Body Line Height Multiplier
    ///
    private static let bodyLineHeightMultiplier = CGFloat(1.43)

    /// Headline Font Multiplier
    ///
    private static let headlingFontMultiplier = CGFloat(1.7)

    /// Headling Spacing
    ///
    private static let headlineSpacing = CGFloat.zero

    /// Main Styles
    ///
    let headlineStyle: Style
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
        self.headlineStyle = Theme.headlineStyle
        self.bodyStyle = Theme.bodyStyle
        self.styles = markdownEnabled ? Theme.markdownStyles : Theme.regularStyles
        self.markdownEnabled = markdownEnabled
    }
}


// MARK: - Styles
//
private extension Theme {

    static var headlineStyle: Style {
        return Style(element: .firstLine, attributes: headlineAttributes)
    }

    static var bodyStyle: Style {
        return Style(element: .body, attributes: bodyAttributes)
    }

    static var regularStyles: [Style] {
        return [
            headlineStyle
        ]
    }

    static var markdownStyles: [Style] {
        return [
            Style(element: .h1, attributes: headingAttributes),
            Style(element: .h2, attributes: headingAttributes),
            headlineStyle,
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
            .foregroundColor:   NSColor.simplenoteEditorTextColor,
            .font:              NSFont.systemFont(ofSize: fontSize),
            .paragraphStyle:    bodyParagraphStyle
        ]
    }

    static var headlineAttributes: [NSAttributedString.Key: AnyObject] {
        return [
            .font:              NSFont.boldSystemFont(ofSize: ceil(fontSize * headlingFontMultiplier)),
            .paragraphStyle:    headlineParagraphStyle
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
            .foregroundColor: NSColor.simplenoteSecondaryTextColor,
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
            .foregroundColor: NSColor.simplenoteSecondaryTextColor,
            .paragraphStyle: paragraphStyle
        ]
    }

    static var urlAttributes: [NSAttributedString.Key: AnyObject] {
        return [
            .foregroundColor: NSColor.simplenoteLinkColor
        ]
    }
}


// MARK: - Paragraph styles
//
private extension Theme {

    static var bodyParagraphStyle: NSParagraphStyle {
        let textHeight = fontSize
        let multipliedLineHeight = floor(textHeight * bodyLineHeightMultiplier)
        let spacing = floor((multipliedLineHeight - textHeight) * 0.5)

        // We're aiming at rendering the text, in relation to the TextView's caret.
        // For that reason, we'll adjust both, lineSpacing (bottom spacing) and lineHeight (top spacing).
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = spacing + textHeight
        paragraph.maximumLineHeight = spacing + textHeight
        paragraph.lineSpacing = spacing

        return paragraph
    }

    static var headlineParagraphStyle: NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.paragraphSpacing = headlineSpacing
        return paragraph
    }
}
