import Foundation
import AppKit


// MARK: - TagsFieldDelegate
//
protocol TagsFieldDelegate: NSTokenFieldDelegate {

    /// This API will be executed whenever a new token is Added / Removed
    func tokenField(_ tokenField: NSTokenField, didChange tokens: [String])
}


// MARK: - TagsField
//
@objcMembers
class TagsField: NSTokenField {

    /// Number of Tokens **before** Edition
    ///
    private var numberOfTokensBeforeEdition = Int.zero

    /// Returns the number of Tokens in the receiver: We'll need to count the acutal TextAttachment instances
    ///
    /// - Note: When there's an Editor set, the source of truth is the LayoutManager's AttributedString
    ///
    private var numberOfTokens: Int {
        guard let textView = currentEditor() as? NSTextView, let layoutManager = textView.layoutManager else {
            return attributedStringValue.numberOfAttachments
        }

        return layoutManager.attributedString().numberOfAttachments
    }

    /// `Extended Delegate` Helper
    ///
    private weak var tagsFieldDelegate: TagsFieldDelegate? {
        delegate as? TagsFieldDelegate
    }

    /// indicates if the Placeholder String should be rendered
    ///
    var drawsPlaceholder = true {
        didSet {
            refreshPlaceholder()
        }
    }

    /// Placeholder's Foreground Color
    ///
    var placeholderTextColor: NSColor = .simplenoteSecondaryTextColor {
        didSet {
            refreshPlaceholder()
        }
    }

    /// Placeholder's Font
    ///
    var placeholderFont: NSFont = .simplenoteSecondaryTextFont {
        didSet {
            refreshPlaceholder()
        }
    }

    /// Placeholder Text:
    ///
    /// - Note: We use a different ivar than `placeholderString`, since we wanna keep the Placeholder String around when
    ///         rendering of such is disabled.
    ///
    var placeholderText = String() {
        didSet {
            refreshPlaceholder()
        }
    }

    /// List of Tags to be rendered
    ///
    var tokens: [String] {
        get {
            let output = objectValue as? [String]
            return output ?? []
        }
        set {
            objectValue = newValue
            needsDisplay = true
            invalidateIntrinsicContentSize()
        }
    }


    // MARK: - Initializers

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTokenizationSettings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTokenizationSettings()
    }
}


// MARK: - Text Edition Overridden API
//
extension TagsField {

    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        numberOfTokensBeforeEdition = numberOfTokens
    }

    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)

        /// Scroll: Increase the scrollable area + follow with the cursor!
        ///
        invalidateIntrinsicContentSize()
        ensureCaretIsOnscreen()

        /// During edition, `Non Terminated Tokens` will show up in the `objectValue` array.
        /// We need the actual number of `Closed Tokens`, and we'll simply count how many TextAttachments we've got.
        /// Capisci?
        ///
        let currentNumberOfTokens = numberOfTokens

        if numberOfTokensBeforeEdition != currentNumberOfTokens  {
            tagsFieldDelegate?.tokenField(self, didChange: tokens)
        }

        numberOfTokensBeforeEdition = currentNumberOfTokens
    }

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)

        // Always recalculate intrinsicContentSize.
        // There might be no tokens committed yet (and the height at this point **might** not fit the new attachments.
        invalidateIntrinsicContentSize()

        // Tokens can get created when the control loses focus, but none of the expected events fire.
        // Fire one manually instead.
        tagsFieldDelegate?.tokenField(self, didChange: tokens)
    }
}


// MARK: - Scroll / Autolayout Support
//
extension TagsField {

    override var intrinsicContentSize: NSSize {
        guard let scrollView = enclosingScrollView, let cellSize = cell?.cellSize else {
            return super.intrinsicContentSize
        }

        // Notes:
        //  1.  Always assume the container's full width
        //  2.  Leave a bit of empty space on the right hand side, enough to fill a Placeholder!
        //  3.  Whenever we've got a Field Editor AND it's empty, always return the Placeholder String Height.
        //      **Why:**
        //          A.  We need this field to be vertically centered.
        //          B.  When in edition mode, the `cellSize` will always match the Attachment Height.
        //              Even if the new token wasn't committed (and isn't "Bubbled Up" in the editor)
        //
        let placeholderSize = simplenotePlaceholderAttributedString.size()
        let calculatedWidth = cellSize.width.rounded(.up) + placeholderSize.width
        let newWidth        = max(calculatedWidth, scrollView.bounds.width)
        let newHeight       = isEditorActiveAndEmpty ? placeholderSize.height : cellSize.height.rounded(.up)

        return CGSize(width: newWidth, height: newHeight)
    }

    var isEditorActiveAndEmpty: Bool {
        let textView = currentEditor() as? NSTextView
        return textView?.attributedString().numberOfAttachments == .zero
    }
}


// MARK: - NSTextViewDelegate
//
extension TagsField: NSTextViewDelegate {

    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        /// keyPress: `ESC`>> `resignFirstResponder`!
        ///
        if commandSelector == #selector(cancelOperation(_:)) {
            window?.makeFirstResponder(nil)
            return true
        }

        /// keyPress: `Arrow(s)`, `Delete`,  `*`
        /// We don't really know *who* or exactly when will eventually handle this command. Eventually, let's make sure the horizontal scroll offset is accurate.
        ///
        DispatchQueue.main.async {
            self.ensureCaretIsOnscreen()
        }

        return false
    }

    func textView(_ textView: NSTextView, clickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
        guard let tagCell = cell as? TagAttachmentCell else {
            return
        }

        ensureTextIsFullyTokenized(editorString: textView.attributedString().string)
        selectAttachment(in: textView, stringValue: tagCell.stringValue)
    }

    func textView(_ textView: NSTextView, doubleClickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
        guard let tagCell = cell as? TagAttachmentCell else {
            return
        }

        ensureTextIsFullyTokenized(editorString: textView.attributedString().string)
        editAttachment(in: textView, stringValue: tagCell.stringValue)
    }
}


// MARK: - Cursor Helpers
//
private extension TagsField {

    func ensureCaretIsOnscreen() {
        guard let newVisibleRect = proposedVisibleRectForEdition else {
            return
        }

        scrollToVisible(newVisibleRect)
    }

    var proposedVisibleRectForEdition: NSRect? {
        guard let textView = currentEditor() as? NSTextView, let lm = textView.layoutManager, let container = textView.textContainer else {
            return nil
        }

        /// Determine the Editor's cursor location
        ///
        var output = lm.boundingRect(forGlyphRange: textView.selectedRange(), in: container)

        let placeholderWidth = simplenotePlaceholderAttributedString.size().width

        /// Adjust the Viewport: always accommodate to support `placeholder.width`'s on both sides
        ///
        output.origin.x = max(output.origin.x - placeholderWidth, .zero)
        output.size.width = placeholderWidth * 2

        return output
    }
}


// MARK: - Mouse Support
//
private extension TagsField {

    /// Replaces the related NSTextAttachment with the specified `attachmentCell.stringValue`, and places the cursor at its beginning
    ///
    func editAttachment(in textView: NSTextView, stringValue: String) {
        guard let range = textView.attributedString().rangeOfFirstAttachment(stringValue: stringValue) else {
            return
        }

        textView.replaceCharacters(in: range, with: stringValue)
        invalidateIntrinsicContentSize()

        let newSelectedLocation = NSRange(location: range.location + stringValue.count, length: .zero)
        textView.setSelectedRange(newSelectedLocation)
    }

    /// Selects the NSTextAttachment with the specified `attachmentCell.stringValue`
    ///
    func selectAttachment(in textView: NSTextView, stringValue: String) {
        guard let range = textView.attributedString().rangeOfFirstAttachment(stringValue: stringValue) else {
            return
        }

        textView.setSelectedRange(range)
    }

    /// This API ensures all the Editor Text is fully tokenized. Whenever there's untokenized text, we'll forcefully reprocess tokens
    ///
    func ensureTextIsFullyTokenized(editorString: String) {
        guard mustTokenizeText(editorString: editorString) else {
            return
        }

        reprocessTokens()
    }

    /// Indicates if we should reprocess Tokens.
    /// - Note: returns true whenever the specified String contains text, other than TextAttachment characters
    ///
    func mustTokenizeText(editorString: String) -> Bool {
        let attachmentsCharacterSet = CharacterSet(arrayLiteral: .textAttachment)
        return editorString.trimmingCharacters(in: attachmentsCharacterSet).isEmpty == false
    }

    /// Forcess Re-Tokenization: Converts all of the strings into NSTextAttachments. This affects the active NSTextView instance.
    /// - Note: As a failsafe measure, we're making sure the tokens are Unique!
    ///
    func reprocessTokens() {
        let newTokens = tokens.caseInsensitiveUnique
        tokens = newTokens
    }
}


// MARK: - Placeholder Support
//
private extension TagsField {

    var simplenotePlaceholderAttributedString: NSAttributedString {
        NSAttributedString(string: placeholderText, attributes: [
            .font: placeholderFont,
            .foregroundColor: placeholderTextColor
        ])
    }

    func refreshPlaceholder() {
        placeholderAttributedString = drawsPlaceholder ? simplenotePlaceholderAttributedString : nil
    }

    func setupTokenizationSettings() {
        completionDelay = TokenizationSettings.completionDelay
        tokenizingCharacterSet = TokenizationSettings.characterSet
    }
}


// MARK: - Settings
//
private enum TokenizationSettings {
    static let completionDelay  = TimeInterval(0.1)
    static let characterSet     = CharacterSet(charactersIn: ";, ").union(.whitespacesAndNewlines)
}
