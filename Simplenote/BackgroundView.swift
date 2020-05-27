import Foundation


// MARK: - BackgroundView
//
@objcMembers
class BackgroundView: NSView {

    /// Bottom Border: Color
    ///
    var bottomBorderColor: NSColor? = .simplenoteDividerColor {
        didSet {
            needsDisplay = true
        }
    }

    /// Bottom Border: Width
    ///
    var bottomBorderWidth = NSScreen.main?.pointToPixelRatio {
       didSet {
           needsDisplay = true
       }
   }

    /// Fill Color
    ///
    var fillColor: NSColor? {
       didSet {
           needsDisplay = true
       }
   }


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
