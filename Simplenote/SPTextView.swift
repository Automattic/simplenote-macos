import AppKit

// MARK: - SPTextView
//
class SPTextView: NSTextView {

    /// Is called when text view resigns being first responder
    ///
    var onResignFirstResponder: (() -> Void)?

    /// Highlighted ranges
    ///
    var highlightedRanges: [NSRange] = [] {
        didSet {
            guard let textStorage = textStorage else {
                return
            }

            for range in oldValue where range.upperBound <= textStorage.fullRange.upperBound {
                textStorage.removeAttribute(.backgroundColor, range: range)
            }

            for range in highlightedRanges {
                textStorage.setAttributes([
                    .backgroundColor: NSColor.simplenoteEditorSearchHighlightColor
                ], range: range)
            }
        }
    }

    override var string: String {
        willSet {
            // Reset highlights before new string is set
            highlightedRanges = []
        }
    }

    override var typingAttributes: [NSAttributedString.Key : Any] {
        get {
            simplenoteStorage?.typingAttributes ?? super.typingAttributes
        }
        set { }
    }

    private var simplenoteStorage: Storage? {
        return textStorage as? Storage
    }

    override func mouseDown(with event: NSEvent) {
        if checkForChecklistClick(with: event) {
            return
        }
        super.mouseDown(with: event)
    }

    override func copy(_ sender: Any?) {
        guard selectedRange().location != NSNotFound else {
            return
        }

        let selectedAttributedString = attributedString().attributedSubstring(from: selectedRange())
        let markdownString = NSAttributedStringToMarkdownConverter.convert(string: selectedAttributedString)

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(markdownString, forType: .string)
    }

    override func paste(_ sender: Any?) {
        super.paste(sender)
        processLinksInDocumentAsynchronously()
    }

    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()
        if value {
            highlightedRanges = []
        }
        return value
    }

    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        if value {
            // Async to wait for the state to fully update
            DispatchQueue.main.async {
                self.onResignFirstResponder?()
            }
        }
        return value
    }

    private func checkForChecklistClick(with event: NSEvent) -> Bool {
        guard let textContainer = textContainer,
              let layoutManager = layoutManager,
              let textStorage = textStorage else {
            return false
        }

        // Location of the tap in text-container coordinates
        var viewPoint = convert(event.locationInWindow, from: nil)
        viewPoint.x -= textContainerInset.width
        viewPoint.y -= textContainerInset.height

        // Find the character that's been tapped on
        let characterIndex = layoutManager.characterIndex(for: viewPoint,
                                                          in: textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)

        guard characterIndex < textStorage.length else {
            return false
        }

        var range = NSRange()
        guard let attachment = attributedString().attribute(.attachment, at: characterIndex, effectiveRange: &range) as? SPTextAttachment else {
            return false
        }

        // A checkbox was tapped!
        attachment.isChecked = !attachment.isChecked
        let note = Notification(name: NSText.didChangeNotification, object: nil)
        delegate?.textDidChange?(note)
        needsLayout = true
        layoutManager.invalidateDisplay(forCharacterRange: range)

        return true
    }
}
