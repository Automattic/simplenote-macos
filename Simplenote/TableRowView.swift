import Foundation


// MARK: - TableCellView: In AppKit several details (such as the cell's selection state) are handled via TableRowViews.
//                        We'll rely on this mechanism to forward the selection state
//
protocol TableCellView: class {
    var isSelected: Bool { get set }
}


// MARK: - TableRowView
//
@objcMembers
class TableRowView : NSTableRowView {

    /// Background Color to be applied whenever the Row is selected
    ///
    var selectedBackgroundColor: NSColor?


    /// We're overriding `isSelected` so that we can forward any seleciton events to the associated TableCellView
    ///
    override var isSelected: Bool {
        didSet {
            cellView?.isSelected = isSelected
        }
    }

    /// Returns the associated `TableCellView`, if any
    ///
    private var cellView: TableCellView? {
        for case let targetView as TableCellView in subviews {
            return targetView
        }

        return nil
    }


    // MARK: - Overridden

    override func drawSelection(in dirtyRect: NSRect) {
        guard selectionHighlightStyle != .none, let backgroundColor = selectedBackgroundColor else {
            return
        }

        backgroundColor.setFill()
        NSBezierPath(rect: bounds).fill()
    }
}
