import Foundation


// MARK: - TextFieldDelegate: Our custom protocol.
//         Why: Because `shouldBeginEditing`'s API requires a non null NSText instance, which we really can't acquire
//         within `acceptsFirstResponder`.
//
protocol TextFieldDelegate: NSTextFieldDelegate {
    func controlAcceptsFirstResponder(_ control: NSControl) -> Bool
}


// MARK: - TextField
//
class TextField: NSTextField {

    /// Indicates if the receiver is Editing
    ///
    var isEditing: Bool {
        currentEditor() != nil
    }

    /// Indicates if the receiver is in Selected State
    ///
    var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else {
                return
            }

            refreshTextColor()
        }
    }

    /// Color to be applied over regular text
    ///
    var textRegularColor: NSColor? {
        didSet {
            refreshTextColor()
        }
    }

    /// Color to be applied whenever the `isSelected` flag is true (and `isEditing` is false)
    ///
    var textSelectionColor: NSColor? {
        didSet {
            refreshTextColor()
        }
    }

    /// Color to be applied whenever the TextField is being edited
    ///
    var textEditionColor: NSColor? {
        didSet {
            refreshTextColor()
        }
    }


    // MARK: - Overridden

    override var acceptsFirstResponder: Bool {
        innerDelegate?.controlAcceptsFirstResponder(self) ?? false
    }

    override func becomeFirstResponder() -> Bool {
        guard super.becomeFirstResponder() else {
            return false
        }

        refreshTextColor()
        return true
    }

    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        refreshTextColor()
    }
}


// MARK: - Private
//
private extension TextField {

    var activeTextColor: NSColor? {
        if isEditing {
            return textEditionColor
        }

        return isSelected ? textSelectionColor : textRegularColor
    }

    var innerDelegate: TextFieldDelegate? {
        delegate as? TextFieldDelegate
    }

    func refreshTextColor() {
        textColor = activeTextColor
    }
}
