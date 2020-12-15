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


    // MARK: - Overridden

    override func drawSelection(in dirtyRect: NSRect) {
        guard selectionHighlightStyle != .none else {
            return
        }

        let insets = style.insets
        let targetRect = bounds.insetBy(dx: insets.dx, dy: insets.dy)
        style.selectionColor.setFill()
        NSBezierPath(roundedRect: targetRect, xRadius: style.cornerRadius, yRadius: style.cornerRadius).fill()
    }

    override func drawSeparator(in dirtyRect: NSRect) {
        if isSelected || isNextRowSelected {
            return
        }

        guard let separatorColor = style.separatorColor else {
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

    var selectionColor: NSColor {
        switch self {
        case .fullWidth:
            return .simplenoteSelectedBackgroundColor
        case .sidebar:
            return .simplenoteSecondarySelectedBackgroundColor
        case .list:
            return .simplenoteSelectedBackgroundColor
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
        switch self {
        case .list:
            return Metrics.sidebarSeparatorInsets
        default:
            return NSEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: .zero)
        }
    }
}


// MARK: - Constants
//
private enum Metrics {
    static let defaultSeparatorWidth    = CGFloat(1)
    static let legacyCornerRadius       = CGFloat.zero
    static let roundedCornerRadius      = CGFloat(6)
    static let fullWidthInsets          = CGVector.zero
    static let listInsets               = CGVector(dx: 12, dy: .zero)
    static let sidebarInsets            = CGVector(dx: 14, dy: .zero)
    static let sidebarSeparatorInsets   = NSEdgeInsets(top: .zero, left: 36, bottom: .zero, right: 28)
}
