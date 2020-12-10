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
}



// MARK: - Defines a TableRowView Presentation Style
//
enum TableRowStyle {
    case sidebar
    case list
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
}


// MARK: - Constants
//
private enum Metrics {
    static let legacyCornerRadius   = CGFloat.zero
    static let roundedCornerRadius  = CGFloat(6)
    static let fullWidthInsets      = CGVector.zero
    static let listInsets           = CGVector(dx: 12, dy: .zero)
    static let sidebarInsets        = CGVector(dx: 14, dy: .zero)
}
