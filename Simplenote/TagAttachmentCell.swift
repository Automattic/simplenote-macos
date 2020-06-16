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

    /// Listen to Click Events:
    /// - Note: Alternative involves overwriting `clickedOn` | `doubleClickedOn` in TagsField, but when doing so,
    ///         the cursor shows up for a split second before the attachment is properly highlighted.
    ///
    override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView?, atCharacterIndex charIndex: Int, untilMouseUp flag: Bool) -> Bool {
        guard let textView = controlView as? NSTextView else {
            return false
        }

        let newRange = NSRange(location: charIndex, length: 1)

        // Click: Select
        guard textView.isCharacterSelected(at: charIndex) else {
            textView.setSelectedRange(newRange)
            return true
        }

        // Double Click: Switch to edition
        textView.replaceCharacters(in: newRange, with: stringValue)
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
        updated.size.height -= Metrics.bgInsets.top

        let bgColor = backgroundColor(selected: selected)
        bgColor.setFill()

        NSBezierPath(roundedRect: updated, xRadius: Metrics.radius, yRadius: Metrics.radius).fill()
    }

    func drawText(in frame: NSRect) {
        var updated = frame
        updated.origin.x += Metrics.textInsets.left + Metrics.bgInsets.left
        updated.origin.y += Metrics.textInsets.top + Metrics.bgInsets.top

        updated.size.width -= Metrics.textInsets.left + Metrics.textInsets.right
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
            .font:              NSFont.simplenoteSecondaryTextFont,
            .foregroundColor:   NSColor.simplenoteTextColor
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
