//
//  Element.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//

import Foundation


/// A String type enum to keep track of the different elements we're tracking with regex.
public enum Element: String {
    case unknown = "x^"

    case h1 = "^(\\#[^\\#](.*))$"
    case h2 = "^(\\#{2}(.*))$"
    case h3 = "^(\\#{3}(.*))$"

    case body = ".*"

    case bold = "(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)\\2(?=\\S)(.*?\\S)\\2\\2(?!\\2)(?=[\\W_]|$)"
    case italic = "(^|[\\W_])(?:(?!\\1)|(?=^))(\\*|_)(?=\\S)((?:(?!\\2).)*?\\S)\\2(?!\\2)(?=[\\W_]|$)"
    case boldItalic = "(\\*\\*\\*\\w+(\\s\\w+)*\\*\\*\\*)"
    case code = "(`[^`]{1,}`)" // Allows for any character except ` to be in inline code.

    case url = "\\[([^\\]]+)\\]\\(([^\\)\"\\s]+)(?:\\s+\"(.*)\")?\\)"
    case image = "\\!\\[([^\\]]+)\\]\\(([^\\)\"\\s]+)(?:\\s+\"(.*)\")?\\)"

    /// Converts an enum value (type String) to a NSRegularExpression.
    ///
    /// - returns: The NSRegularExpression.
    func toRegex() -> NSRegularExpression {
        return self.rawValue.toRegex()
    }

    /// Returns an Element enum based upon a String.
    ///
    /// - parameter string: The String representation of the enum.
    ///
    /// - returns: The Element enum match.
    func from(string: String) -> Element {
        switch string {
        case "h1": return .h1
        case "h2": return .h2
        case "h3": return .h3
        case "body": return .body
        case "bold": return .bold
        case "italic": return .italic
        case "boldItalic": return .boldItalic
        case "code": return .code
        case "url": return .url
        case "image": return .image
        default: return .unknown
        }
    }
}
