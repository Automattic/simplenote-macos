import Foundation


// MARK: - SplitView
//
class SplitView: NSSplitView {

    /// Divider Thickness to be applied, whenever NSScreen.main is inaccessible
    ///
    private let defaultDividerThickness = CGFloat(1)

    /// Divider Color
    ///
    var simplenoteDividerColor: NSColor? {
        didSet {
            setNeedsDisplay(bounds)
        }
    }


    // MARK: - Overridden Methods

    override var dividerThickness: CGFloat {
        NSScreen.main?.pointToPixelRatio ?? defaultDividerThickness
    }

    override func drawDivider(in rect: NSRect) {
        guard let dividerColor = simplenoteDividerColor else {
            return
        }

        dividerColor.setFill()
        NSBezierPath(rect: rect).fill()
    }
}
