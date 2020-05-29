import Foundation
import AppKit


// MARK: - TagsFieldDelegate
//
protocol TagsFieldDelegate: NSTokenFieldDelegate {
    func tokenField(_ tokenField: NSTokenField, didChange tokens: [String])
}


// MARK: - TagsField
//
@objcMembers
class TagsField: NSTokenField {

    /// Keeps the collection of Tokens **before** Edition begins
    ///
    private var tokensBeforeEdition: [String]?

    /// `Extended Delegate` Helper
    ///
    private weak var tagsFieldDelegate: TagsFieldDelegate? {
        delegate as? TagsFieldDelegate
    }

    ///
    var placeholderTextColor: NSColor = .simplenoteSecondaryTextColor {
        didSet {
            refreshPlaceholder()
        }
    }

    ///
    var placeholderFont: NSFont = .simplenoteSecondaryTextFont {
           didSet {
               refreshPlaceholder()
           }
       }

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
        tokensBeforeEdition = tokens
    }

    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)

        let newTokens = tokens

        // Immediately Notify when a Token was removed
        if let oldTokens = tokensBeforeEdition, oldTokens.count > newTokens.count {
            tagsFieldDelegate?.tokenField(self, didChange: newTokens)
        }

        tokensBeforeEdition = newTokens
    }

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)

        // Tokens can get created when the control loses focus, but none of the expected events fire.
        // Fire one manually instead.
        tagsFieldDelegate?.tokenField(self, didChange: tokens)
        tokensBeforeEdition = nil
    }
}


// MARK: - Private Methods
//
private extension TagsField {

    func refreshPlaceholder() {
        placeholderAttributedString = NSAttributedString(string: placeholderText, attributes: [
            .font: placeholderFont,
            .foregroundColor: placeholderTextColor
        ])
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
