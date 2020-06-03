import Foundation


// MARK: - TagsFieldCell
//
class TagsFieldCell: NSTokenFieldCell {

    /// Helper TokenFieldCell: We'll rely on this private instance to "calculate" New Tokens
    ///
    private let internalTokenFieldCell = NSTokenFieldCell()

    /// Tokenizing CharacterSet: Propagate changes over to the internal helper
    ///
    override var tokenizingCharacterSet: CharacterSet! {
        didSet {
            internalTokenFieldCell.tokenizingCharacterSet = tokenizingCharacterSet
        }
    }

    /// Attributed String: We'll be replacing AAPL's private TextAttachment implementation with our custom instance, for rendering purposes
    ///
    override var attributedStringValue: NSAttributedString {
        get {
            let output = super.attributedStringValue
            replaceAttachmentCells(in: output)
            return output
        }
        set {
            // NSTokenFieldCell's default `setAttributeStringValue` is unable to deal with custom NSTextAttachments
            objectValue = extractTokens(from: newValue)
        }
    }

    /// Listen to TextStorage Changes: Replace NSTextAttachment(s) on the fly
    ///
    override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
        let editor = super.setUpFieldEditorAttributes(textObj)
        ensureTextStorageIsInitialized(in: editor)
        return editor
    }

    /// Drops the TextStorage Link
    ///
    override func endEditing(_ textObj: NSText) {
        ensureTextStorageIsDeinitialized(in: textObj)
        super.endEditing(textObj)
    }
}


// MARK: - Private API(s)
//
private extension TagsFieldCell {

    /// Extracts the Tokens contained within a NSAttributedString (as String Values)
    ///
    func extractTokens(from attrString: NSAttributedString) -> [String] {
        var tokens = [String]()

        attrString.enumerateAttribute(.attachment, in: attrString.fullRange, options: []) { (payload, range, _) in
            if let attach = payload as? NSTextAttachment, let cell = attach.attachmentCell as? NSTextAttachmentCell {
                tokens.append(cell.stringValue)
                return
            }

            /// `NSAttributedString.enumerateAttribute` loops thru `segments`, including ranges in which there is no actual attachment (just text!)
            if let parsed = self.parseTokens(in: attrString, at: range) {
                tokens += parsed
                return
            }
        }

        return tokens
    }

    /// Attempts to parse new Tokens (by means of an internal NSTokenFieldCell Instance) contained in a given AttributedString
    ///
    func parseTokens(in attrString: NSAttributedString, at range: NSRange) -> [String]? {
        internalTokenFieldCell.attributedStringValue = attrString.attributedSubstring(from: range)
        return internalTokenFieldCell.objectValue as? [String]
    }

    /// Replaces all of the NSTextAttachmentCell(s) with our own implementation
    ///
    func replaceAttachmentCells(in attrString: NSAttributedString) {
        attrString.enumerateAttachments(of: NSTextAttachment.self) { (attach, range) in
            guard let attachCell = attach.attachmentCell as? NSCell, !(attachCell is TagAttachmentCell) else {
                return
            }

            let tagCell = TagAttachmentCell()
            tagCell.stringValue = attachCell.stringValue

            // Why?: Setting the Cell's Font fixes a million layout issues.
            tagCell.font = self.font
            attach.attachmentCell = tagCell
        }
    }

    /// Listening to TextStorage Changes
    ///
    func ensureTextStorageIsInitialized(in editor: NSText) {
        guard let textView = editor as? NSTextView, let storage = textView.layoutManager?.textStorage else {
            return
        }

        storage.delegate = self
    }

    /// Deinitializing TextStorage Hook!
    ///
    func ensureTextStorageIsDeinitialized(in editor: NSText) {
        guard let textView = editor as? NSTextView, let storage = textView.layoutManager?.textStorage else {
            return
        }

        storage.delegate = nil
    }
}


// MARK: - NSTextStorageDelegate Conformance
//
extension TagsFieldCell: NSTextStorageDelegate {

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        replaceAttachmentCells(in: textStorage)
    }
}
