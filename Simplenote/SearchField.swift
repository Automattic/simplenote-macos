import Foundation
import AppKit


// MARK: - SearchField
//
class SearchField: NSTextField {

    override func drawFocusRingMask() {
        // NO-OP: We'll always draw our Highlighted State
    }
}


// MARK: - SearchFieldCell
//
class SearchFieldCell: NSTextFieldCell {

    /// Search Icon!
    ///
    private let searchIconImage = NSImage(named: .search)

    /// Background
    ///
    var innerBackgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.05)

    /// Divider
    ///
    var regularDividerColor = NSColor.simplenoteSecondaryDividerColor
    var highlightDividerColor = NSColor.simplenoteBrandColor

    /// Accessory
    ///
    var accessoryTintColor = NSColor.simplenoteSecondaryTextColor


    // MARK: - Geometry

    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        return verticallyAdjustedFrame(for: rect)
    }

    // MARK: - Overridden Methods

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawSimplenoteBackground(cellFrame: cellFrame, isHighlighted: controlView.isFirstResponder)
        drawSimplenoteAccessory(cellFrame: cellFrame)

        super.drawInterior(withFrame: cellFrame, in: controlView)
    }

    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let frame = verticallyAdjustedFrame(for: rect)
        super.edit(withFrame: frame, in: controlView, editor: textObj, delegate: delegate, event: event)
    }

    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let frame = verticallyAdjustedFrame(for: rect)
        super.select(withFrame: frame, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
}


// MARK: - Private API(s)
//
private extension SearchFieldCell {

    func drawSimplenoteBackground(cellFrame: NSRect, isHighlighted: Bool) {
        let bezier = NSBezierPath(roundedRect: cellFrame, xRadius: Metrics.borderRadius, yRadius: Metrics.borderRadius)
        bezier.lineWidth = Metrics.borderWidth

        innerBackgroundColor.setFill()
        bezier.addClip()
        bezier.fill()

        let borderColor = isHighlighted ? highlightDividerColor : regularDividerColor
        borderColor.setStroke()
        bezier.stroke()
    }

    func drawSimplenoteAccessory(cellFrame: NSRect) {
        guard let icon = searchIconImage?.tinted(with: accessoryTintColor) else {
            return
        }

        var frame = Metrics.searchIconFrame
        frame.origin.y = floor((cellFrame.height - frame.height) * 0.5)
        icon.draw(in: frame)
    }

    func verticallyAdjustedFrame(for rect: NSRect) -> NSRect {
        let minimumHeight           = self.cellSize(forBounds: rect).height
        var adjustedFrame           = rect
        adjustedFrame.origin.x      += Metrics.textPadding.left
        adjustedFrame.origin.y      += floor((adjustedFrame.height - minimumHeight) * 0.5)
        adjustedFrame.size.height   = minimumHeight
        adjustedFrame.size.width    -= Metrics.textPadding.left + Metrics.textPadding.right

        return adjustedFrame
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let borderRadius     = CGFloat(5)
    static let borderWidth      = CGFloat(2)
    static let searchIconFrame  = NSRect(x: 9, y: .zero, width: 16, height: 16)
    static let textPadding      = NSEdgeInsets(top: .zero, left: 32, bottom: .zero, right: 15)
}
