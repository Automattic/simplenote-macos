import Foundation
import AppKit

// MARK: - Button
//
class Button: NSButton {

    /// Insets
    ///
    var textInsets: NSEdgeInsets = Metrics.defaultInsets {
        didSet {
            needsLayout = true
        }
    }

    // MARK: - Overridden Methods

    override var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        size.width += textInsets.left + textInsets.right
        size.height += textInsets.top + textInsets.bottom
        return size
    }
}

// MARK: - ButtonCell
//
class ButtonCell: NSButtonCell {

    /// Button's Corner Radius
    ///
    var cornerRadius = CGFloat(5)
    var drawsBezel = false

    /// Colors
    ///
    var textColor: NSColor?
    var regularBackgroundColor: NSColor?
    var highlightedBackgroundColor: NSColor?

    // MARK: - Overridden Methods

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawBackground(in: cellFrame)
        drawTitle(in: cellFrame)
    }

    private func drawBackground(in cellFrame: NSRect) {
        let buttonColor = isHighlighted ? highlightedBackgroundColor : regularBackgroundColor
        let backgroundPath = NSBezierPath(roundedRect: cellFrame, xRadius: cornerRadius, yRadius: cornerRadius)
        buttonColor?.set()
        backgroundPath.fill()
    }

    private func drawTitle(in cellFrame: NSRect) {
        // Paragraph: Horizontally Centered
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Frame: Vertically Centered!
        let size = attributedTitle.size()
        var titleFrame = cellFrame
        titleFrame.origin.y = floor((cellFrame.height - size.height) * 0.5)

        // Attributes
        let titleFont = font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let titleColor = textColor ?? .white
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: titleColor,
            .font: titleFont
        ])

        attributedTitle.draw(in: titleFrame)
    }
}

// MARK: - Metrics
//
private enum Metrics {
    static let defaultInsets = NSEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
}
