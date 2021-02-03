import AppKit

// MARK: - SPTextView
//
class SPTextView: NSTextView {

    /// Is called when first responder status changes
    ///
    var onUpdateFirstResponder: (() -> Void)?

    /// Highlighted ranges
    ///
    var highlightedRanges: [NSRange] = [] {
        didSet {
            guard let textStorage = simplenoteStorage else {
                return
            }

            textStorage.beginEditing()

            for range in oldValue where range.upperBound <= textStorage.fullRange.upperBound {
                textStorage.removeAttribute(.backgroundColor, range: range)
            }

            for range in highlightedRanges {
                textStorage.addAttribute(.backgroundColor, value: NSColor.simplenoteEditorSearchHighlightColor, range: range)
            }

            textStorage.endEditingWithoutRestyling()
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
        set {
            super.typingAttributes = newValue
        }
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
            // Async to wait for the state to fully update
            DispatchQueue.main.async {
                self.onUpdateFirstResponder?()
            }
        }
        return value
    }

    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        if value {
            // Async to wait for the state to fully update
            DispatchQueue.main.async {
                self.onUpdateFirstResponder?()
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


// MARK: - Relative locations
//
extension SPTextView {
    /// Returns position relative to the total text container height.
    /// Position value is from 0 to 1
    ///
    func relativeLocationsForText(in ranges: [NSRange]) -> [CGFloat] {
        let textContainerHeight = textContainerHeightForSearchMap()
        guard textContainerHeight > CGFloat.leastNormalMagnitude else {
            return []
        }

        return ranges.map {
            var boundingRect = self.boundingRect(for: $0)
            boundingRect.origin.y -= textContainerOrigin.y
            return max(boundingRect.midY / textContainerHeight, CGFloat.leastNormalMagnitude)
        }
    }

    private func textContainerHeightForSearchMap() -> CGFloat {
        guard let layoutManager = layoutManager,
              let textContainer = textContainer,
              let scrollView = enclosingScrollView else {
            return 0.0
        }

        layoutManager.ensureLayout(for: textContainer)
        let textContainerHeight = layoutManager.usedRect(for: textContainer).size.height
        let textContainerMinHeight = scrollView.frame.size.height - scrollView.scrollerInsets.top
        return max(textContainerHeight, textContainerMinHeight)
    }
}
