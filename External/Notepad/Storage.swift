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

@objc
class Storage: NSTextStorage {

    /// Simplenote's Active Theme
    ///
    private let theme = Theme()

    /// Backing String (Cache) reference
    ///
    private var backingString = String()

    /// The underlying text storage implementation.
    ///
    private let backingStore = NSMutableAttributedString()

    /// Returns the BackingString
    ///
    override var string: String {
        return backingString
    }


    /// Designated Initializer
    ///
    override init() {
        super.init()
    }

    override init(attributedString attrStr: NSAttributedString) {
        super.init(attributedString:attrStr)
        backingStore.setAttributedString(attrStr)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        super.init(pasteboardPropertyList: propertyList, ofType: type)
    }

    /// Finds attributes within a given range on a String.
    ///
    /// - parameter location: How far into the String to look.
    /// - parameter range:    The range to find attributes for.
    ///
    /// - returns: The attributes on a String within a certain range.
    ///
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }

    /// Replaces edited characters within a certain range with a new string.
    ///
    /// - parameter range: The range to replace.
    /// - parameter str:   The new string to replace the range with.
    ///
    override func replaceCharacters(in range: NSRange, with str: String) {
        self.beginEditing()

        backingStore.replaceCharacters(in: range, with: str)
        replaceBackingStringSubrange(range, with: str)

        let change = str.utf16.count - range.length
        self.edited(.editedCharacters, range: range, changeInLength: change)
        self.endEditing()
    }

    override func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
        self.beginEditing()

        backingStore.replaceCharacters(in: range, with: attrString)
        replaceBackingStringSubrange(range, with: attrString.string)

        let change = attrString.length - range.length
        self.edited([.editedCharacters, .editedAttributes], range: range, changeInLength: change)
        self.endEditing()
    }

    override func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
        self.beginEditing()
        backingStore.addAttribute(name, value: value, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    override func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
        self.beginEditing()
        backingStore.removeAttribute(name, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    /// Sets the attributes on a string for a particular range.
    ///
    /// - parameter attrs: The attributes to add to the string for the range.
    /// - parameter range: The range in which to add attributes.
    ///
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        self.beginEditing()
        backingStore.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    /// Processes any edits made to the text in the editor.
    ///
    override func processEditing() {
        let foundationBackingString = backingString as NSString
        let lineRange = foundationBackingString.lineRange(for: NSRange(location: NSMaxRange(editedRange), length: 0))
        let extendedRange = NSUnionRange(editedRange, lineRange)

        applyStyles(extendedRange)
        super.processEditing()
    }

    /// Applies styles to a range on the backingString.
    ///
    /// - parameter range: The range in which to apply styles.
    ///
    private func applyStyles(_ range: NSRange) {
        let string = backingString
        backingStore.addAttributes(theme.bodyStyle.attributes, range: range)

        for style in theme.styles {
            style.regex.enumerateMatches(in: string, options: .withoutAnchoringBounds, range: range) { (match, flags, stop) in
                guard let range = match?.range(at: 0) else {
                    return
                }

                backingStore.addAttributes(style.attributes, range: range)
            }
        }

        // NOTE:
        //  -   We're literally adding the `body.attributes` to the whole range (which might be *way longer* than the
        //      actual edited range, see `processEditing()).`
        //  -   Since we're doing so, *not* signaling `edited(.editedAttributes, range: range)` was causing characters
        //      to go AWOL
        //  -   Signaling `edited(.attributes,...)` was messing with the selectedRange, and we ended up implementing a
        //      supermassive hack. Ref. https://github.com/Automattic/simplenote-macos/pull/396/files
        //  -   Simply calling `fixAttributes` prevents characters from going awol. For that reason, we're nuking the
        //      selectedRange override. YAY!
        //
        backingStore.fixAttributes(in: range)
    }

    /// Refreshes the receiver's Attributes
    ///
    @objc
    func refreshStyle(markdownEnabled: Bool) {
        guard theme.markdownEnabled != markdownEnabled else {
            return
        }

        beginEditing()

        // Toggle
        theme.markdownEnabled = markdownEnabled

        // Reset the full styles
        let range = backingStore.rangeOfEntireString
        backingStore.setAttributes([:], range: range)

        // After actually calling `endEditing` a `processEditing` loop will be triggered, and the sytles will be refreshed.
        // No need to explicitly call `process`.
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}


// MARK: - Helpers
//
private extension Storage {

    func replaceBackingStringSubrange(_ range: NSRange, with string: String) {
        let utf16String = backingString.utf16
        let startIndex = utf16String.index(utf16String.startIndex, offsetBy: range.location)
        let endIndex = utf16String.index(startIndex, offsetBy: range.length)
        backingString.replaceSubrange(startIndex..<endIndex, with: string)
    }
}
