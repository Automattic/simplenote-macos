//
//  Storage.swift
//  Notepad
//
//  Created by Rudd Fawcett on 10/14/16.
//  Copyright © 2016 Rudd Fawcett. All rights reserved.
//

import AppKit

extension Storage {

    /// Replaces edited characters within a certain range with a new string.
    ///
    /// - parameter range: The range to replace.
    /// - parameter str:   The new string to replace the range with.
    ///
    open override func replaceCharacters(in range: NSRange, with str: String) {
        self.beginEditing()

        var performedActions: NSTextStorageEditActions = [.editedCharacters]
        if fixAttributesBeforeReplacingCharacters(in: range) {
            performedActions.insert(.editedAttributes)
        }

        backingStore.replaceCharacters(in: range, with: str)

        let change = str.utf16.count - range.length
        self.edited(performedActions, range: range, changeInLength: change)
        self.endEditing()
    }

    open override func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
        self.beginEditing()

        backingStore.replaceCharacters(in: range, with: attrString)

        let change = attrString.length - range.length
        self.edited([.editedCharacters, .editedAttributes], range: range, changeInLength: change)
        self.endEditing()
    }

    open override func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
        self.beginEditing()
        backingStore.addAttribute(name, value: value, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    open override func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
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
    open override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        self.beginEditing()
        backingStore.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    /// Applies styles to a range on the backingString.
    ///
    /// - parameter range: The range in which to apply styles.
    ///
    @objc
    func applyStyles(_ range: NSRange) {
        backingStore.addAttributes(theme.bodyStyle.attributes, range: range)

        let string = self.string
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

    /// RE-Applies the Styles to the whole BackingStore
    ///
    @objc
    func resetStyles() {
        beginEditing()

        // Reset the Style Keys: Do this for specific attributes. Otherwise we risk loosing the NSTextAttachment attribute!
        let range = backingStore.fullRange
        let attributeKeys: [NSAttributedString.Key] = [.font, .foregroundColor, .paragraphStyle]

        backingStore.removeAttributes(attributeKeys, range: range)

        // After actually calling `endEditing` a `processEditing` loop will be triggered, and the sytles will be re-applied.
        // No need to explicitly call `process` (!)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}


// MARK: - Typing Attributes
//
extension Storage {

    @objc
    var typingAttributes: [NSAttributedString.Key: Any] {
        backingStore.length == .zero ? theme.headlineStyle.attributes : theme.bodyStyle.attributes
    }
}


// MARK: - Helpers
//
private extension Storage {

    /// Drops the Link Attribute whenever we're about to replace the (full) range. This method should only be tied up to plain String replacements (non attributed), otherwise
    /// it's not really needed
    ///
    /// Ref. https://github.com/Automattic/simplenote-macos/issues/448
    ///
    func fixAttributesBeforeReplacingCharacters(in range: NSRange) -> Bool {
        guard range.length > 0 && range == backingStore.fullRange else {
            return false
        }

        backingStore.removeAttribute(.link, range: range)

        return true
    }
}
