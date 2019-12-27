//
//  Extensions.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//

import Foundation

#if os(iOS)
    import struct UIKit.CGFloat
#elseif os(macOS)
    import struct AppKit.CGFloat
#endif


extension String {
    /// Converts a String to a NSRegularExpression.
    ///
    /// - returns: The NSRegularExpression.
    func toRegex() -> NSRegularExpression {
        var pattern: NSRegularExpression = NSRegularExpression()

        do {
            try pattern = NSRegularExpression(pattern: self, options: .anchorsMatchLines)
        } catch {
            print(error)
        }

        return pattern
    }

    /// Converts a NSRange to a Range<String.Index>.
    /// http://stackoverflow.com/a/30404532/6669540
    ///
    /// - parameter range: The NSRange.
    ///
    /// - returns: The equivalent Range<String.Index>.
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}
