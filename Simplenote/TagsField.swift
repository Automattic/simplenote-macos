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
        }
    }


    // MARK: - Initializers

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupDefaultParameters()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaultParameters()
    }
}


// MARK: - Overridden API(s)
//
extension TagsField {

    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        numberOfTokensBeforeEdition = numberOfTokens
    }

    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)

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

        // Tokens can get created when the control loses focus, but none of the expected events fire.
        // Fire one manually instead.
        tagsFieldDelegate?.tokenField(self, didChange: tokens)
    }
}


// MARK: - Private Methods
//
private extension TagsField {

    var simplenotePlaceholderAttributedString: NSAttributedString? {
        guard drawsPlaceholder else {
            return nil
        }

        return NSAttributedString(string: placeholderText, attributes: [
            .font: placeholderFont,
            .foregroundColor: placeholderTextColor
        ])
    }

    func refreshPlaceholder() {
        placeholderAttributedString = simplenotePlaceholderAttributedString
    }

    func setupDefaultParameters() {
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
