//
//  Storage.swift
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

@objc public class Storage: NSTextStorage {
    /// The Theme for the Notepad.
    public var theme: Theme? {
        didSet {
            let wholeRange = NSRange(location: 0, length: (self.string as NSString).length)

            self.beginEditing()
            // Clear out the attributes on the backing NSTextStorage
            self.backingStore.setAttributes([:], range: wholeRange)
            self.applyStyles(wholeRange)
            self.edited(.editedAttributes, range: wholeRange, changeInLength: 0)
            self.endEditing()
        }
    }

    /// The underlying text storage implementation.
    var backingStore = NSTextStorage()
    
    var markdownEnabled = false

    override public var string: String {
        get {
            return backingStore.string
        }
    }

    override public init() {
        super.init()
    }
    
    @objc public class func newInstance() -> Storage {
        let storage = Storage()
        storage.theme = Theme(markdownEnabled: false)
        return storage
    }
    
    override public init(attributedString attrStr: NSAttributedString) {
        super.init(attributedString:attrStr)
        backingStore.setAttributedString(attrStr)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required public init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        super.init(pasteboardPropertyList: propertyList, ofType: type)
    }
    
    /// Finds attributes within a given range on a String.
    ///
    /// - parameter location: How far into the String to look.
    /// - parameter range:    The range to find attributes for.
    ///
    /// - returns: The attributes on a String within a certain range.
    override public func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }

    /// Replaces edited characters within a certain range with a new string.
    ///
    /// - parameter range: The range to replace.
    /// - parameter str:   The new string to replace the range with.
    override public func replaceCharacters(in range: NSRange, with str: String) {
        self.beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        let change = str.utf16.count - range.length
        self.edited(.editedCharacters, range: range, changeInLength: change)
        self.endEditing()
    }
    
    override public func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
        self.beginEditing()
        backingStore.replaceCharacters(in: range, with: attrString)
        let change = attrString.length - range.length
        self.edited(.editedCharacters, range: range, changeInLength: change)
        self.endEditing()
    }
    
    override public func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
        self.beginEditing()
        backingStore.addAttribute(name, value: value, range: range)
        self.endEditing()
    }
    
    override public func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
        self.beginEditing()
        backingStore.removeAttribute(name, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    /// Sets the attributes on a string for a particular range.
    ///
    /// - parameter attrs: The attributes to add to the string for the range.
    /// - parameter range: The range in which to add attributes.
    override public func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        self.beginEditing()
        backingStore.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    /// Processes any edits made to the text in the editor.
    override public func processEditing() {
        let backingString = backingStore.string
        let nsRange = backingString.range(from: NSMakeRange(NSMaxRange(editedRange), 0))!
        let indexRange = backingString.lineRange(for: nsRange)
        let extendedRange: NSRange = NSUnionRange(editedRange, NSRange(indexRange, in: backingString))

        applyStyles(extendedRange)
        super.processEditing()
    }

    /// Applies styles to a range on the backingString.
    ///
    /// - parameter range: The range in which to apply styles.
    func applyStyles(_ range: NSRange) {
        guard let theme = self.theme else { return }

        let backingString = backingStore.string
        backingStore.addAttributes(theme.body.attributes, range: range)

        for (style) in theme.styles {
            style.regex.enumerateMatches(in: backingString, options: .withoutAnchoringBounds, range: range, using: { (match, flags, stop) in
                guard let match = match else { return }
                backingStore.addAttributes(style.attributes, range: match.range(at: 0))
            })
        }
    }
    
    @objc public func applyStyle(markdownEnabled: Bool) {
        self.theme = Theme(markdownEnabled: markdownEnabled)
    }
}
