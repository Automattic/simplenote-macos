import Foundation


// MARK: - SplitView
//
class SplitView: NSSplitView {

    /// Default Divider Thickness: 1pt
    ///
    private let defaultDividerThickness = CGFloat(1)

    // MARK: - Overridden Methods

    override var dividerThickness: CGFloat {
        defaultDividerThickness
    }

    override var dividerColor: NSColor {
        return .simplenoteDividerColor
    }
}


// MARK: - Forced Redraw Hacks. Please Nuke!
//
private extension SplitView {

    /// Hack:
    /// Forces the entire window to re-render, by switching the appearance back and forth.
    ///
    func performMojaveRedrawHack() {
        guard let window = window else {
            return
        }

        let oldAppearance = window.appearance
        window.appearance = nil
        window.appearance = oldAppearance
    }
}
