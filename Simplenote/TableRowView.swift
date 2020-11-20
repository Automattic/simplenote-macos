import Foundation


// MARK: - TableRowView
//
@objcMembers
class TableRowView : NSTableRowView {

    /// Background Color to be applied whenever the Row is selected
    ///
    var selectedBackgroundColor: NSColor?

    /// Selection's Corner Radius
    ///
    var selectionCornerRadius: CGFloat = Settings.defaultCornerRadius {
        didSet {
            needsDisplay = true
        }
    }

    /// Selection's Inner Selection Insets
    ///
    var selectionInsets: TableRowInset = .sidebar {
        didSet {
            needsDisplay = true
        }
    }



    // MARK: - Overridden

    override func drawSelection(in dirtyRect: NSRect) {
        guard selectionHighlightStyle != .none, let backgroundColor = selectedBackgroundColor else {
            return
        }

        let insets = selectionInsets.vector
        let targetRect = bounds.insetBy(dx: insets.dx, dy: insets.dy)
        backgroundColor.setFill()
        NSBezierPath(roundedRect: targetRect, xRadius: selectionCornerRadius, yRadius: selectionCornerRadius).fill()
    }
}



private enum Settings {
    static let defaultCornerRadius = CGFloat(6)
}


enum TableRowInset {
    case sidebar
    case list
}

extension TableRowInset {
    var vector: CGVector {
        switch self {
        case .sidebar:
            return CGVector(dx: 14, dy: .zero)
        case .list:
            return CGVector(dx: 12, dy: .zero)
        }
    }
}
