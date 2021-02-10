import Foundation
import AppKit


// MARK: - SearchField
//
class SearchField: NSSearchField {

    /// Style
    ///
    var style = SearchFieldStyle.default {
        didSet {
            styleWasUpdated()
        }
    }

    /// Metrics
    ///
    var metrics = SearchFieldMetrics.default {
        didSet {
            needsDisplay = true
        }
    }

    /// Placeholder
    ///
    var placeholder = String() {
        didSet {
            refreshPlaceholderStyle()
        }
    }


    // MARK: - Overridden

    override func drawFocusRingMask() {
        // NO-OP: We'll always draw our Highlighted State
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()
    }


    /// Resets the Style
    /// - Note: In Mojave / Catalina, this API has the beautiful side effect of going Dark Mode 😬
    ///
    func refreshStyle() {
        style = SearchFieldStyle.default
    }
}


// MARK: - Private Methods
//
private extension SearchField {

    func styleWasUpdated() {
        refreshTextStyle()
        refreshPlaceholderStyle()
        refreshSearchIconStyle()
    }

    func refreshTextStyle() {
        textColor = style.textColor
        font = style.textFont
    }

    func refreshPlaceholderStyle() {
        placeholderAttributedString = NSAttributedString(string: placeholder, attributes: [
            .font:              style.placeholderFont,
            .foregroundColor:   style.placeholderColor
        ])
    }

    func refreshSearchIconStyle() {
        guard let searchFieldCell = cell as? SearchFieldCell, let searchButtonCell = searchFieldCell.searchButtonCell else {
            return
        }

        let image = style.searchButtonImage.tinted(with: style.searchButtonTintColor)
        searchButtonCell.image = image
        searchButtonCell.imageScaling = .scaleProportionallyUpOrDown
        searchButtonCell.alternateImage = image
    }
}


// MARK: - SearchFieldCell
//
class SearchFieldCell: NSSearchFieldCell {

    // MARK: - Properties
    //         Rather than mirroring SearchField's properties, we'll just access the same reference, in the name of simplicity.

    var searchField: SearchField {
        controlView as! SearchField
    }

    var metrics: SearchFieldMetrics {
        searchField.metrics
    }

    var style: SearchFieldStyle {
        searchField.style
    }


    // MARK: - Geometry

    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        verticallyCenteredTitleFrame(for: rect)
    }

    override func searchButtonRect(forBounds rect: NSRect) -> NSRect {
        let originY = floor((rect.height - metrics.searchIconSize.height) * 0.5)
        let origin = NSPoint(x: metrics.searchIconPaddingX, y: originY)
        return NSRect(origin: origin, size: metrics.searchIconSize)
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
        let bezier = NSBezierPath(roundedRect: cellFrame, xRadius: metrics.borderRadius, yRadius: metrics.borderRadius)
        bezier.lineWidth = metrics.borderWidth


        style.innerBackgroundColor.setFill()
        bezier.addClip()
        bezier.fill()

        let borderColor = isHighlighted ? style.highlightBorderColor : style.borderColor
        borderColor.setStroke()
        bezier.stroke()
    }

    func verticallyCenteredTitleFrame(for rect: NSRect) -> NSRect {
        let defaultLineHeight       = CGFloat(16)
        let lineHeight              = font?.lineHeight ?? defaultLineHeight
        var adjustedFrame           = rect
        adjustedFrame.origin.x      = metrics.textPadding.left
        adjustedFrame.origin.y      = floor((adjustedFrame.height - lineHeight) * 0.5)
        adjustedFrame.size.height   = lineHeight
        adjustedFrame.size.width    -= metrics.textPadding.left + metrics.textPadding.right

        return adjustedFrame
    }
}


// MARK: - Metrics
//
struct SearchFieldMetrics {
    let borderRadius : CGFloat
    let borderWidth : CGFloat
    let searchIconSize : NSSize
    let searchIconPaddingX : CGFloat
    let textPadding : NSEdgeInsets
}


// MARK: - Style
//
struct SearchFieldStyle {
    let borderColor: NSColor
    let highlightBorderColor: NSColor
    let innerBackgroundColor: NSColor
    let placeholderFont: NSFont
    let placeholderColor: NSColor
    let textColor: NSColor
    let textFont: NSFont
    let searchButtonImage: NSImage
    let searchButtonTintColor: NSColor
}


// MARK: - Defaults
//
extension SearchFieldMetrics {
    static var `default`: SearchFieldMetrics {
        SearchFieldMetrics(borderRadius:        5,
                           borderWidth:         2,
                           searchIconSize:      NSSize(width: 16, height: 16),
                           searchIconPaddingX:  9,
                           textPadding:         NSEdgeInsets(top: .zero, left: 32, bottom: .zero, right: 40))
    }
}

extension SearchFieldStyle {
    static var `default`: SearchFieldStyle {
        SearchFieldStyle(borderColor:           .simplenoteSecondaryDividerColor,
                         highlightBorderColor:  .simplenoteAccessoryTintColor,
                         innerBackgroundColor:  .simplenoteSearchBarBackgroundColor,
                         placeholderFont:       .simplenoteSecondaryTextFont,
                         placeholderColor:      .simplenoteSecondaryTextColor,
                         textColor:             .simplenoteTextColor,
                         textFont:              .simplenoteSecondaryTextFont,
                         searchButtonImage:     NSImage(named: .search)!,
                         searchButtonTintColor: .simplenoteSecondaryTextColor)
    }
}

//  1.  Metrics / Negative Frames
//  2.  Clicking over the SearchBar causes the FistResponder status to be lost
