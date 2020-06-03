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

    /// Field Editor Initialization: We'll replace the NSTextStorage instance with a customized implementation
    ///
    override func setUpFieldEditorAttributes(_ textObj: NSText) -> NSText {
        let editor = super.setUpFieldEditorAttributes(textObj)
        ensureTextStorageIsInitialized(in: editor)
        return editor
    }
}


// MARK: - Private API(s)
//
private extension TagsFieldCell {

    /// Extracts the Tokens contained within a NSAttributedString (as String Values)
    ///
    func extractTokens(from attrString: NSAttributedString) -> [String] {
        var tokens = [String]()

        attrString.enumerateAttribute(.attachment, in: attrString.fullRange, options: []) { (payload, range, nil) in
            if let attach = payload as? NSTextAttachment, let cell = attach.attachmentCell as? NSTextAttachmentCell {
                tokens.append(cell.stringValue)
                return
            }

            /// `NSAttributedString.enumerateAttribute` loops thru `segments`, including ranges in which there is no actual attachment.
            /// We'll rely on a private TokenFieldCell instance to actually produce a valid token
            ///
            let attrString = attrString.attributedSubstring(from: range)
            internalTokenFieldCell.attributedStringValue = attrString

            if let parsed = internalTokenFieldCell.objectValue as? [String], let tag = parsed.first {
                tokens.append(tag)
                return
            }

            /// Fallback: No Attachment, and no tokens!
            ///
            tokens.append(attrString.string)
        }

        return tokens
    }


    /// Replaces all of the NSTextAttachmentCell(s) with our own implementation
    ///
    func replaceAttachmentCells(in attrString: NSAttributedString) {
        attrString.enumerateAttachments(of: NSTextAttachment.self) { (attach, range) in
            guard let attachCell = attach.attachmentCell as? NSCell, !(attachCell is TagAttachmentCell) else {
                return
            }

            let tagCell = TagAttachmentCell()
            tagCell.attributedStringValue = attachCell.attributedStringValue
            attach.attachmentCell = tagCell
        }
    }

    /// Initializes the Field Editor: We'll need a custom TextStorage, in order to inject our own NSCell(s)
    ///
    func ensureTextStorageIsInitialized(in editor: NSText) {
        guard let textView = editor as? NSTextView, let lm = textView.layoutManager, let storage = lm.textStorage else {
            return
        }

        if storage is TagsTextStorage {
            return
        }

        let newTextStorage = TagsTextStorage(attributedString: storage)
        newTextStorage.onAttachmentUpsert = { [weak self] attrString in
            self?.replaceAttachmentCells(in: attrString)
        }

        lm.replaceTextStorage(newTextStorage)
    }
}
