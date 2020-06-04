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

        let offsetY = abs(font.descender).rounded(.up) + Drawing.textInsets.bottom
        return NSPoint(x: .zero, y: offsetY * -1)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        drawBezier(in: cellFrame, selected: false)
        drawText(in: cellFrame)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int, layoutManager: NSLayoutManager) {
        let selected = isSelected(in: controlView, charIndex: charIndex)

        drawBezier(in: cellFrame, selected: selected)
        drawText(in: cellFrame)
    }

    func isSelected(in controlView: NSView?, charIndex: Int) -> Bool {
        guard let textView = controlView as? NSTextView else {
            return false
        }

        for wrappedRange in textView.selectedRanges where NSLocationInRange(charIndex, wrappedRange.rangeValue) {
            return true
        }

        return false
    }
}


// MARK: - Private API
//
private extension TagAttachmentCell {

    func drawBezier(in frame: NSRect, selected: Bool) {
        var updated = frame
        updated.size.width -= Drawing.spacing

// TODO: FIX
        if selected {
            NSColor.red.setFill()
        } else {
            NSColor(calibratedWhite: 1.0, alpha: 0.22).setFill()
        }
        NSBezierPath(roundedRect: updated, xRadius: Drawing.radius, yRadius: Drawing.radius).fill()
    }

    func drawText(in frame: NSRect) {
        let updated = frame.insetBy(dx: Drawing.textInsets.left, dy: Drawing.textInsets.top)
        nsStringValue.draw(in: updated, withAttributes: Drawing.attributes)
    }
}


// MARK: - Drawing Constants
//
private enum Drawing {
    static let attributes: [NSAttributedString.Key: Any] = [
        .font:              NSFont.simplenoteSecondaryTextFont,
        .foregroundColor:   NSColor.simplenoteTextColor
    ]
    static let textInsets = NSEdgeInsets(top: 4, left: 12, bottom: 6, right: 12)
    static let spacing = CGFloat(8)
    static let radius = CGFloat(13)
}
