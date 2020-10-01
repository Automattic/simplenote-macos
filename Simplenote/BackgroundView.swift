import Foundation


// MARK: - BackgroundView
//
@objcMembers
class BackgroundView: NSView {

    /// Bottom Border: Color
    ///
    var borderColor: NSColor? = .simplenoteDividerColor {
        didSet {
            guard borderColor != oldValue else {
                return
            }

            needsDisplay = true
        }
    }

    /// Bottom Border: Width
    ///
    var borderWidth = NSScreen.main?.pointToPixelRatio {
        didSet {
            guard borderWidth != oldValue else {
                return
            }

            needsDisplay = true
        }
    }

    /// Indicates if the top border should be rendered
    ///
    @IBInspectable
    var drawsTopBorder: Bool = false {
        didSet {
            guard drawsTopBorder != oldValue else {
                return
            }

            needsDisplay = true
        }
    }

    /// Indicates if the bottom border should be rendered
    ///
    @IBInspectable
    var drawsBottomBorder: Bool = false {
        didSet {
            guard drawsBottomBorder != oldValue else {
                return
            }

            needsDisplay = true
        }
    }

    /// Fill Color
    ///
    var fillColor: NSColor? {
        didSet {
            guard fillColor != oldValue else {
                return
            }

            needsDisplay = true
        }
    }

    /// Mouse Cursor that should be applied when the mouse hovers over
    ///
    var cursor: NSCursor?


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

        if drawsTopBorder, let borderWidth = borderWidth, let borderColor = borderColor {
            let bottomRect = NSRect(x: .zero, y: dirtyRect.height - borderWidth, width: dirtyRect.width, height: borderWidth)
            borderColor.set()
            NSBezierPath(rect: bottomRect).fill()
        }
    }

    override func resetCursorRects() {
        super.resetCursorRects()

        if let cursor = cursor {
            addCursorRect(bounds, cursor: cursor)
        }
    }
}
