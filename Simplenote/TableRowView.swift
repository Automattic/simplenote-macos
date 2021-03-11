import Foundation


// MARK: - TableRowView
//
@objcMembers
class TableRowView : NSTableRowView {

    /// Selection's Inner Selection Insets
    ///
    var style: TableRowStyle = .fullWidth {
        didSet {
            needsDisplay = true
        }
    }

    /// If true table view or view controller is a first responder
    ///
    var isActive: Bool = true {
        didSet {
            needsDisplay = true
        }
    }

    /// Setting `isNextRowSelected` should trigger a redraw!
    ///
    override var isNextRowSelected: Bool {
        didSet {
            needsDisplay = true
        }
    }


    // MARK: - Overridden

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawSimplenoteSeparator(in: dirtyRect)
    }

    override func drawSelection(in dirtyRect: NSRect) {
        guard selectionHighlightStyle != .none else {
            return
        }

        let insets = style.insets
        let targetRect = bounds.insetBy(dx: insets.dx, dy: insets.dy)
        style.selectionColor(isActive: isActive).setFill()
        NSBezierPath(roundedRect: targetRect, byRoundingCorners: roundedCorners, radius: style.cornerRadius).fill()
    }

    private var roundedCorners: RectCorner {
        var output = RectCorner()
        if !isPreviousRowSelected {
            output.formUnion([.topLeft, .topRight])
        }

        if !isNextRowSelected {
            output.formUnion([.bottomLeft, .bottomRight])
        }

        return output
    }

    override func drawSeparator(in dirtyRect: NSRect) {
        // NO-OP: Even overriding this API yields a weird effect!
    }


    // MARK: - Drawing

    func drawSimplenoteSeparator(in rect: NSRect) {
        guard let separatorColor = style.separatorColor, mustDrawSeparator else {
            return
        }

        let insets = style.separatorInsets
        let path = NSBezierPath()

        path.move(to: NSMakePoint(.zero + insets.left, bounds.maxY))
        path.line(to: NSMakePoint(bounds.maxX - insets.right, bounds.maxY))
        path.lineWidth = NSScreen.main?.backingScaleFactor ?? Metrics.defaultSeparatorWidth

        separatorColor.set()
        path.stroke()
    }

    private var mustDrawSeparator: Bool {
        !isSelected && !isNextRowSelected
    }
}



// MARK: - Defines a TableRowView Presentation Style
//
enum TableRowStyle {

    /// Sidebar: Tags List
    ///
    case sidebar

    /// List: Notes List
    ///
    case list

    /// Full Width: Legacy // Interlinking // Metrics
    ///
    case fullWidth
}

extension TableRowStyle {

    var cornerRadius: CGFloat {
        guard #available(macOS 11, *) else {
            return Metrics.legacyCornerRadius
        }

        switch self {
        case .fullWidth:
            return Metrics.legacyCornerRadius
        default:
            return Metrics.roundedCornerRadius
        }
    }

    var insets: CGVector {
        guard #available(macOS 11, *) else {
            return Metrics.fullWidthInsets
        }

        switch self {
        case .fullWidth:
            return Metrics.fullWidthInsets
        case .list:
            return Metrics.listInsets
        case .sidebar:
            return Metrics.sidebarInsets
        }
    }

    func selectionColor(isActive: Bool) -> NSColor {
        switch self {
        case .fullWidth:
            return .simplenoteSelectedBackgroundColor
        case .sidebar:
            return isActive ? .simplenoteSecondarySelectedBackgroundColor : .simplenoteSecondarySelectedInactiveBackgroundColor
        case .list:
            return isActive ? .simplenoteSelectedBackgroundColor : .simplenoteSelectedInactiveBackgroundColor
        }
    }

    var separatorColor: NSColor? {
        switch self {
        case .list:
            return .simplenoteSecondaryDividerColor
        default:
            return nil
        }
    }

    var separatorInsets: NSEdgeInsets {
        guard self == .list else {
            return .zero
        }

        guard #available(macOS 11, *) else {
            return Metrics.sidebarLegacySeparatorInsets
        }

        return Metrics.sidebarSeparatorInsets
    }
}


// MARK: - Constants
//
private enum Metrics {
    static let defaultSeparatorWidth        = CGFloat(1)
    static let legacyCornerRadius           = CGFloat.zero
    static let roundedCornerRadius          = CGFloat(6)
    static let fullWidthInsets              = CGVector.zero
    static let listInsets                   = CGVector(dx: 12, dy: .zero)
    static let sidebarInsets                = CGVector(dx: 14, dy: .zero)
    static let sidebarSeparatorInsets       = NSEdgeInsets(top: .zero, left: 36, bottom: .zero, right: 28)
    static let sidebarLegacySeparatorInsets = NSEdgeInsets(top: .zero, left: 29, bottom: .zero, right: 21)
}
