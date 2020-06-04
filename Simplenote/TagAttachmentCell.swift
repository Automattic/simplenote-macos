import Foundation


// MARK: - TagAttachmentCell
//
class TagAttachmentCell: NSTextAttachmentCell {

    var nsStringValue: NSString {
        stringValue as NSString
    }

    override func cellSize() -> NSSize {
        let textSize    = nsStringValue.size(withAttributes: Drawing.attributes)
        let width       = textSize.width.rounded(.up) + Drawing.textInsets.left + Drawing.textInsets.right + Drawing.spacing
        let height      = textSize.height.rounded(.up) + Drawing.textInsets.top + Drawing.textInsets.bottom

        return NSSize(width: width, height: height)
    }

    override func cellBaselineOffset() -> NSPoint {
        guard let font = font else {
            return .zero
        }

        let offsetY = font.descender.rounded(.down) - Drawing.textInsets.bottom
        return NSPoint(x: .zero, y: offsetY)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        drawBackground(in: cellFrame)
        drawText(in: cellFrame)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int, layoutManager: NSLayoutManager) {
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
        updated.size.width -= Drawing.spacing

        let bgColor = backgroundColor(selected: selected)
        bgColor.setFill()

        NSBezierPath(roundedRect: updated, xRadius: Drawing.radius, yRadius: Drawing.radius).fill()
    }

    func drawText(in frame: NSRect) {
        let updated = frame.insetBy(dx: Drawing.textInsets.left, dy: Drawing.textInsets.top)
        nsStringValue.draw(in: updated, withAttributes: Drawing.attributes)
    }

    func backgroundColor(selected: Bool) -> NSColor {
        selected ? .simplenoteSelectedBackgroundColor : .simplenoteTokenBackgroundColor
    }
}


// MARK: - Drawing Constants
//
private enum Drawing {
    static var attributes: [NSAttributedString.Key: Any] = [
        .font:              NSFont.simplenoteSecondaryTextFont,
        .foregroundColor:   NSColor.simplenoteTextColor
    ]
    static let radius       = CGFloat(13)
    static let spacing      = CGFloat(8)
    static let textInsets   = NSEdgeInsets(top: 4, left: 12, bottom: 6, right: 12)
}
