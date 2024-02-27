import Foundation

// MARK: - TagAttachmentCell
//
class TagAttachmentCell: NSTextAttachmentCell {

    /// Text Color
    ///
    var textColor: NSColor = .simplenoteTextColor

    /// Font
    ///
    var textFont: NSFont = .simplenoteSecondaryTextFont

    /// Returns the receiver's StringValue as a Foundation String
    ///
    private var nsStringValue: NSString {
        stringValue as NSString
    }

    override func cellSize() -> NSSize {
        let textSize    = nsStringValue.size(withAttributes: attributes)
        let width       = textSize.width.rounded(.up) + Metrics.textInsets.left + Metrics.textInsets.right + Metrics.bgInsets.left + Metrics.bgInsets.right
        let height      = textSize.height.rounded(.up) + Metrics.textInsets.top + Metrics.textInsets.bottom + Metrics.bgInsets.top + Metrics.bgInsets.bottom

        return NSSize(width: width, height: height)
    }

    override func cellBaselineOffset() -> NSPoint {
        guard let font = font else {
            return .zero
        }

        let offsetY = font.descender.rounded(.down) - Metrics.textInsets.bottom
        return NSPoint(x: .zero, y: offsetY)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        // Note: This API runs whenever we're in display mode
        drawBackground(in: cellFrame)
        drawText(in: cellFrame)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int) {
        // Note: This API is expected to run when we're editing Tags
        let textView = controlView as? NSTextView
        let selected = textView?.isCharacterSelected(at: charIndex) ?? false

        drawBackground(in: cellFrame, selected: selected)
        drawText(in: cellFrame)
    }
}

// MARK: - Mouse Handling
//
extension TagAttachmentCell {

    /// Mouse Events Override!
    ///
    /// The default behavior does end up calling `clickedOn` | `doubleClickedOn`, but when doing so, the cursor shows up at `location.x = 0`
    /// during mouseDown (before mouseUp).
    ///
    /// In our own implementation, we hit directly the textView's delegate methods (if possible), and avoid such UI glitch.
    ///
    override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView?, atCharacterIndex charIndex: Int, untilMouseUp flag: Bool) -> Bool {
        guard let textView = controlView as? NSTextView else {
            return false
        }

        if theEvent.clickCount == 1 {
            textView.delegate?.textView?(textView, clickedOn: self, in: cellFrame, at: charIndex)
        } else if theEvent.clickCount == 2 {
            textView.delegate?.textView?(textView, doubleClickedOn: self, in: cellFrame, at: charIndex)
        }

        return true
    }
}

// MARK: - Private API
//
private extension TagAttachmentCell {

    func drawBackground(in frame: NSRect, selected: Bool = false) {
        var updated = frame
        updated.origin.x += Metrics.bgInsets.left
        updated.origin.y += Metrics.bgInsets.top
        updated.size.width -= Metrics.bgInsets.left + Metrics.bgInsets.right
        updated.size.height -= Metrics.bgInsets.top + Metrics.bgInsets.bottom

        let bgColor = backgroundColor(selected: selected)
        bgColor.setFill()

        NSBezierPath(roundedRect: updated, xRadius: Metrics.radius, yRadius: Metrics.radius).fill()
    }

    func drawText(in frame: NSRect) {
        var updated = frame
        updated.origin.x += Metrics.textInsets.left + Metrics.bgInsets.left
        updated.origin.y += Metrics.textInsets.top + Metrics.bgInsets.top

        updated.size.width -= Metrics.textInsets.left + Metrics.textInsets.right + Metrics.bgInsets.left + Metrics.bgInsets.right
        updated.size.height -= Metrics.textInsets.top + Metrics.textInsets.bottom

        nsStringValue.draw(in: updated, withAttributes: attributes)
    }

    func backgroundColor(selected: Bool) -> NSColor {
        selected ? .simplenoteTokenSelectedBackgroundColor : .simplenoteTokenBackgroundColor
    }
}

// MARK: - Dynamic Properties
//
private extension TagAttachmentCell {

    var attributes: [NSAttributedString.Key: Any] {
        [
            .font: NSFont.simplenoteSecondaryTextFont,
            .foregroundColor: NSColor.simplenoteTextColor
        ]
    }
}

// MARK: - Drawing Metrics
//
private enum Metrics {
    static let radius       = CGFloat(11.5)
    static let textInsets   = NSEdgeInsets(top: 2, left: 10, bottom: 4, right: 10)
    static let bgInsets     = NSEdgeInsets(top: 2, left: 4, bottom: 0, right: 4)
}
