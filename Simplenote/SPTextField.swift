import Foundation


// MARK: - SPTextFieldDelegate: Our custom protocol.
//         Why: Because `shouldBeginEditing`'s API requires a non null NSText instance, which we really can't acquire
//         within `acceptsFirstResponder`.
//
protocol SPTextFieldDelegate: NSTextFieldDelegate {
    func controlAcceptsFirstResponder(_ control: NSControl) -> Bool
}


// MARK: - SPTextField
//
class SPTextField: NSTextField {

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
        let textFieldDelegate = delegate as? SPTextFieldDelegate
        return textFieldDelegate?.controlAcceptsFirstResponder(self) ?? false
    }

    @discardableResult
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
private extension SPTextField {

    var activeTextColor: NSColor? {
        if isEditing {
            return textEditionColor
        }

        return isSelected ? textSelectionColor : textRegularColor
    }

    func refreshTextColor() {
        textColor = activeTextColor
    }
}
