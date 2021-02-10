import Foundation
import AppKit


// MARK: - SearchField
//
class SearchField: NSSearchField {

    /// Accessory
    ///
    var searchButtonImage = NSImage(named: .search)
    var searchButtonTintColor = NSColor.simplenoteSecondaryTextColor


    // MARK: - Overridden

    override func drawFocusRingMask() {
        // NO-OP: We'll always draw our Highlighted State
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshSearchButtonStyle()
    }
}


// MARK: - Private Methods
//
private extension SearchField {

    func refreshSearchButtonStyle() {
        guard let searchFieldCell = self.cell as? SearchFieldCell, let searchButtonCell = searchFieldCell.searchButtonCell else {
            return
        }

        let image = searchButtonImage?.tinted(with: searchButtonTintColor)
        searchButtonCell.image = image
        searchButtonCell.imageScaling = .scaleProportionallyUpOrDown
        searchButtonCell.alternateImage = image
    }
}


// MARK: - SearchFieldCell
//
class SearchFieldCell: NSSearchFieldCell {

    /// Background / Dividers
    ///
    var innerBackgroundColor    = NSColor(calibratedWhite: 1.0, alpha: 0.05)
    var regularDividerColor     = NSColor.simplenoteSecondaryDividerColor
    var highlightDividerColor   = NSColor.simplenoteBrandColor

    /// Search Button metrics
    ///
    var searchButtonFrame       = Metrics.searchIconFrame


    // MARK: - Geometry

    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        verticallyCenteredTitleFrame(for: rect)
    }

    override func searchButtonRect(forBounds rect: NSRect) -> NSRect {
        var frame = searchButtonFrame
        frame.origin.y = floor((rect.height - frame.height) * 0.5)
        return frame
    }


    // MARK: - Overridden Methods

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawSimplenoteBackground(cellFrame: cellFrame, isHighlighted: controlView.isFirstResponder)
        super.draw(withFrame: cellFrame, in: controlView)
    }

    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let frame = verticallyCenteredTitleFrame(for: rect)
        super.edit(withFrame: frame, in: controlView, editor: textObj, delegate: delegate, event: event)
    }

    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let frame = verticallyCenteredTitleFrame(for: rect)
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

    func verticallyCenteredTitleFrame(for rect: NSRect) -> NSRect {
        let lineHeight              = textLineHeight
        var adjustedFrame           = rect
        adjustedFrame.origin.x      = Metrics.textPadding.left
        adjustedFrame.origin.y      = floor((adjustedFrame.height - lineHeight) * 0.5)
        adjustedFrame.size.height   = lineHeight
        adjustedFrame.size.width    -= Metrics.textPadding.left + Metrics.textPadding.right

        return adjustedFrame
    }

    var textLineHeight: CGFloat {
        guard let font = self.font else {
            return Metrics.defaultLineHeight
        }

        return ceil(font.ascender - font.descender)
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let defaultLineHeight    = CGFloat(16)
    static let borderRadius         = CGFloat(5)
    static let borderWidth          = CGFloat(2)
    static let searchIconFrame      = NSRect(x: 9, y: .zero, width: 16, height: 16)
    static let textPadding          = NSEdgeInsets(top: .zero, left: 32, bottom: .zero, right: 40)
}


//     1.  Review Colors
//     2.  Clicking over the SearchBar causes the FistResponder status to be lost
//     3.  Dark / Light
//
