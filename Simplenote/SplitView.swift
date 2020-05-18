import Foundation


// MARK: - SplitView
//
class SplitView: NSSplitView {

    /// Default Divider Thickness: To be applied whenever NSScreen.main is inaccessible
    ///
    private let defaultDividerThickness = CGFloat(1)

    /// Default Divider Color
    ///
    private let defaultDividerColor = NSColor.simplenoteDividerColor

    /// Divider Color
    ///
    var simplenoteDividerColor: NSColor? {
        didSet {
            needsDisplay = true
        }
    }


    // MARK: - Overridden Methods

    override var dividerThickness: CGFloat {
        NSScreen.main?.pointToPixelRatio ?? defaultDividerThickness
    }

    override var dividerColor: NSColor {
        simplenoteDividerColor ?? defaultDividerColor
    }

    override func drawDivider(in rect: NSRect) {
        dividerColor.set()
        NSBezierPath(rect: rect).fill()
    }
}
