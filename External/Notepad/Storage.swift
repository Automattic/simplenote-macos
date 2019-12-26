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

    /// Indicates if the SelectionRange is biased (and the UI layer should, instead, consume `overrideSelectionRange`), or not
    /// See `perserveRealEditedRange` for details.
    ///
    @objc
    private(set) var shouldOverrideSelectionRange = false

    /// Contains the "Real" Edited Range.
    /// See `perserveRealEditedRange` for details.
    ///
    @objc
    private(set) var overrideSelectionRange = NSRange()

    /// The Theme for the Notepad
    ///
    private var theme: Theme = Theme(markdownEnabled: false) {
        didSet {
            let wholeRange = NSRange(location: 0, length: backingStore.length)

            self.beginEditing()
            self.backingStore.setAttributes([:], range: wholeRange)
            self.applyStyles(wholeRange)
            self.edited(.editedAttributes, range: wholeRange, changeInLength: 0)
            self.endEditing()
        }
    }

    /// Backing String (Cache) reference
    ///
    private var backingString = String()

    /// The underlying text storage implementation.
    ///
    private let backingStore = NSMutableAttributedString()

    /// Indicates if Markdown is enabled
    ///
    private var markdownEnabled = false

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
        let string = backingString
        let nsRange = string.range(from: NSMakeRange(NSMaxRange(editedRange), 0))!
        let indexRange = string.lineRange(for: nsRange)
        let extendedRange = NSUnionRange(editedRange, NSRange(indexRange, in: string))

        /// In macOS 10.15 (Catalina), editing documents that contain Emojis end up disappearing . We restore them by reapplying our font to the full edited range.
        /// *But* in macOS Catalina, *UNLESS* we signal we've `.editedAttributes` with the fully edited range, the UI ends up broken.
        ///
        /// Now, the side effect of doing so, is that the `selectedRange` ends up being kicked to the end of the document (because, alledgedly, we've edited the full string).
        ///
        /// This is a major hack that allows us to:
        ///
        ///     A. Apply a given font to the entire BackingStore
        ///     B. Signal that we've edited the font (so that emojis are properly rendered)
        ///     C. Preserve the *actual* selectedRange (rather than kicking the cursor to the end of the string).
        ///
        ///  Ref. https://github.com/Automattic/simplenote-macos/pull/396
        ///
        if #available(macOS 10.15, *) {
            shouldOverrideSelectionRange = true
            overrideSelectionRange = NSRange(location: editedRange.location + editedRange.length, length: 0)
        }

        applyStyles(extendedRange)
        super.processEditing()

        shouldOverrideSelectionRange = false
    }

    /// Applies styles to a range on the backingString.
    ///
    /// - parameter range: The range in which to apply styles.
    ///
    private func applyStyles(_ range: NSRange) {
        let string = backingString
        backingStore.addAttributes(theme.body.attributes, range: range)

        for style in theme.styles {
            style.regex.enumerateMatches(in: string, options: .withoutAnchoringBounds, range: range) { (match, flags, stop) in
                guard let range = match?.range(at: 0) else {
                    return
                }

                backingStore.addAttributes(style.attributes, range: range)
            }
        }

        // Note: We *must* signal the whole range has been edited
        //  -   This covers the `theme.body.attributes`
        //  -   Any ranges affected during the theme.styles enumeration is expected, also, to be covered
        edited(.editedAttributes, range: range, changeInLength: 0)
    }

    @objc
    func applyStyle(markdownEnabled: Bool) {
        self.theme = Theme(markdownEnabled: markdownEnabled)
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
