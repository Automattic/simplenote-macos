import Foundation

// MARK: - BackgroundView
//
@objcMembers
class BackgroundView: NSView {

    /// Border Width fallback value (In case the main Screen couldn't be accessed)
    ///
    private static let defaultBorderWidth = CGFloat(1)

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
    var borderWidth: CGFloat = defaultBorderWidth {
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

    /// When enabled, this NSView instance will forward Drag events over to the window
    ///
    var forwardsWindowDragEvents = false

    // MARK: - Overridden Methods

    override func draw(_ dirtyRect: NSRect) {
        if let fillColor = fillColor {
            fillColor.set()
            NSBezierPath(rect: dirtyRect).fill()
        }

        if drawsBottomBorder, let borderColor = borderColor {
            let bottomRect = NSRect(x: .zero, y: .zero, width: dirtyRect.width, height: borderWidth)
            borderColor.set()
            NSBezierPath(rect: bottomRect).fill()
        }

        if drawsTopBorder, let borderColor = borderColor {
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

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        /// 😯 This is really happening.
        guard forwardsWindowDragEvents else {
            return
        }

        window?.performDrag(with: event)
    }
}
