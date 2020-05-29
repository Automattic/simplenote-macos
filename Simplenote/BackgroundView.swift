import Foundation


// MARK: - BackgroundView
//
@objcMembers
class BackgroundView: NSView {

    /// Bottom Border: Color
    ///
    var borderColor: NSColor? = .simplenoteDividerColor {
        didSet {
            needsDisplay = true
        }
    }

    /// Bottom Border: Width
    ///
    var borderWidth = NSScreen.main?.pointToPixelRatio {
       didSet {
           needsDisplay = true
       }
   }

    var drawsBottomBorder = false {
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

        if drawsBottomBorder, let borderWidth = borderWidth, let borderColor = borderColor {
            let bottomRect = NSRect(x: .zero, y: .zero, width: dirtyRect.width, height: borderWidth)
            borderColor.set()
            NSBezierPath(rect: bottomRect).fill()
        }
    }
}
