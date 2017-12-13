//
//  Theme.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public struct Theme {
    /// The body style for the Notepad editor.
    public fileprivate(set) var body: Style = Style()
    /// The background color of the Notepad.
    public fileprivate(set) var backgroundColor: UniversalColor = UniversalColor.white
    /// The tint color (AKA cursor color) of the Notepad.
    public fileprivate(set) var tintColor: UniversalColor = UniversalColor.blue

    /// All of the other styles for the Notepad editor.
    var styles: [Style] = []
    

    /// Build a theme from a JSON theme file.
    ///
    /// - parameter name: The name of the JSON theme file.
    ///
    /// - returns: The Theme.
    public init(_ name: String) {
        let bundle = Bundle(for: object_getClass(self)!)
        
        let themeName = "one-dark"
        
        let path: String
        
        if let path1 = bundle.path(forResource: "Notepad.framework/themes/\(name)", ofType: "json") {
            
            path = path1
        }
        else if let path2 = bundle.path(forResource: "Notepad.framework/\(name)", ofType: "json") {
            
            path = path2
        }
        else if let path3 = bundle.path(forResource: "one-dark-custom", ofType: "json") {

            path = path3
        }
        else {
            
            print("[Notepad] Unable to load your theme file.")
            
            return
        }
        
        if let data = convertFile(path) {
            configure(data)
        }
    }
    
    public init(themePath: String) {
        if let data = convertFile(themePath) {
            configure(data)
        }
    }

    /// Configures all of the styles for the Theme.
    ///
    /// - parameter data: The dictionary data form the parsed JSON file.
    mutating func configure(_ data: [String: AnyObject]) {
        if let editorStyles = data["editor"] as? [String: AnyObject] {
            configureEditor(editorStyles)
        }

        if var allStyles = data["styles"] as? [String: AnyObject] {
            if let bodyStyles = allStyles["body"] as? [String: AnyObject] {
                if let parsedBodyStyles = parse(bodyStyles) {
                    body = Style(element: .body, attributes: parsedBodyStyles)
                }
            }
            else { // Create a default body font so other styles can inherit from it.
                let attributes = [
                    NSAttributedStringKey.foregroundColor: UniversalColor.black,
                    NSAttributedStringKey.font: UniversalFont.systemFont(ofSize: 15)
                ]
                body = Style(element: .body, attributes: attributes)
            }

            allStyles.removeValue(forKey: "body")
            for (element, attributes) in allStyles {
                if let parsedStyles = parse(attributes as! [String : AnyObject]) {
                    if let regexString = attributes["regex"] as? String {
                        let regex = regexString.toRegex()
                        styles.append(Style(regex: regex, attributes: parsedStyles))
                    }
                    else {
                        styles.append(Style(element: Element.unknown.from(string: element), attributes: parsedStyles))
                    }
                }
            }
        }
    }

    /// Sets the background color, tint color, etc. of the Notepad editor.
    ///
    /// - parameter attributes: The attributes to parse for the editor.
    mutating func configureEditor(_ attributes: [String: AnyObject]) {
        if let bgColor = attributes["backgroundColor"] {
            let value = bgColor as! String
            backgroundColor = UniversalColor(hexString: value)
        }

        if let tint = attributes["tintColor"] {
            let value = tint as! String
            tintColor = UniversalColor(hexString: value)
        }
    }

    /// Parses attributes from shorthand JSON to real attributed string key constants.
    ///
    /// - parameter attributes: The attributes to parse.
    ///
    /// - returns: The converted attribute/key constant pairings.
    func parse(_ attributes: [String: AnyObject]) -> [NSAttributedStringKey: AnyObject]? {
        var final: [NSAttributedStringKey: AnyObject] = [:]

        if let color = attributes["color"] {
            let value = color as! String
            final[NSAttributedStringKey.foregroundColor] = UniversalColor(hexString: value)
        }

        if let font = attributes["font"] {
            let fontName = font as! String
            var fontSize: CGFloat = 15.0

            if let size = attributes["size"] {
                fontSize = size as! CGFloat
            }
            else {
                let bodyFont: UniversalFont = body.attributes[NSAttributedStringKey.font] as! UniversalFont
                fontSize = bodyFont.pointSize
            }

            if fontName == "System" {
                final[NSAttributedStringKey.font] = UniversalFont.systemFont(ofSize: fontSize)
            } else if fontName == "SystemBold" {
                final[NSAttributedStringKey.font] = UniversalFont.boldSystemFont(ofSize: fontSize)
            } else {
                final[NSAttributedStringKey.font] = UniversalFont(name: fontName, size: fontSize)
            }
        }
        else {
            // Just change font size (based on body font) if no font is specified for item.
            if let size = attributes["size"] {
                let bodyFont: UniversalFont = body.attributes[NSAttributedStringKey.font] as! UniversalFont
                let fontSize = size as! CGFloat

                final[NSAttributedStringKey.font] = UniversalFont(name: bodyFont.fontName, size: fontSize)
            }
        }

        return final
    }

    /// Converts a file from JSON to a [String: AnyObject] dictionary.
    ///
    /// - parameter path: The path to the JSON file.
    ///
    /// - returns: The new dictionary.
    func convertFile(_ path: String) -> [String: AnyObject]? {
        do {
            let json = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            if let data = json.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch let error as NSError {
                    print(error)
                }
            }
        } catch let error as NSError {
            print(error)
        }

        return nil
    }
}
