import Foundation


// MARK: - Tags View
//
@objcMembers
class TagsView: NSView {

    /// TokenField: Displays the current Note's Tags
    ///
    @IBOutlet private(set) var tokenField: SPTokenField!

    /// Indicates if the
    ///
    var enabled = true {
        didSet {
            refreshPlaceholder()
        }
    }


    // MARK: - Overridden

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTokenField()
    }
}


// MARK: - Public API(s)
//
extension TagsView {

    func refreshStyle() {
        tokenField.textColor = .simplenoteTextColor
        tokenField.backgroundColor = .simplenoteBackgroundColor
    }
}


// MARK: - Interface Initialization
//
private extension TagsView {

    var placeholderAttributedString: NSAttributedString {
        return NSAttributedString(string: Settings.placeholderText, attributes: [
            .font: Settings.font,
            .foregroundColor: Settings.placeholderColor
        ])
    }

    func refreshPlaceholder() {
        tokenField.placeholderAttributedString = enabled ? placeholderAttributedString : nil
    }

    func setupTokenField() {
        tokenField.font = Settings.font
        tokenField.focusRingType = .none
        tokenField.completionDelay = Settings.tokenizationCompletionDelay
        tokenField.tokenizingCharacterSet = Settings.tokenizationCharacterSet
    }
}


// MARK: - Settings
//
private enum Settings {
    static let font                         = NSFont.systemFont(ofSize: 13)
    static let placeholderColor             = NSColor.simplenoteSecondaryTextColor
    static let placeholderText              = NSLocalizedString("Add tag...", comment: "Placeholder text in the Tags View")
    static let tokenizationCompletionDelay  = TimeInterval(0.1)
    static let tokenizationCharacterSet     = CharacterSet(charactersIn: ";, ").union(.whitespacesAndNewlines)
}
