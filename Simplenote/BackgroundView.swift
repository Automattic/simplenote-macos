import Foundation


// MARK: - BackgroundView
//
@objcMembers
class BackgroundView: NSView {

    /// Bottom Border: Color
    ///
    var bottomBorderColor: NSColor? = .simplenoteDividerColor

    /// Bottom Border: Width
    ///
    var bottomBorderWidth = NSScreen.main?.pointToPixelRatio

    /// Fill Color
    ///
    var fillColor: NSColor?


    // MARK: - Overridden Methods

    override func draw(_ dirtyRect: NSRect) {
        if let fillColor = fillColor {
            fillColor.set()
            NSBezierPath(rect: dirtyRect).fill()
        }

        if let bottomBorderWidth = bottomBorderWidth, let bottomBorderColor = bottomBorderColor {
            let bottomRect = NSRect(x: .zero, y: .zero, width: dirtyRect.width, height: bottomBorderWidth)
            bottomBorderColor.set()
            NSBezierPath(rect: bottomRect).fill()
        }
    }
}
