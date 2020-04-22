import Foundation


// MARK: - TableRowView
//
@objcMembers
class TableRowView : NSTableRowView {

    /// Background Color to be applied whenever the Row is selected
    ///
    var selectedBackgroundColor: NSColor?


    // MARK: - Overridden

    override func drawSelection(in dirtyRect: NSRect) {
        guard selectionHighlightStyle != .none, let backgroundColor = selectedBackgroundColor else {
            return
        }

        backgroundColor.setFill()
        NSBezierPath(rect: bounds).fill()
    }
}
