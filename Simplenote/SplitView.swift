import Foundation


// MARK: - SplitView
//
class SplitView: NSSplitView {

    /// Default Divider Thickness: 1pt
    ///
    private let defaultDividerThickness = CGFloat(1)


    /// Divider Color
    ///
    var simplenoteDividerColor: NSColor = .simplenoteDividerColor {
        didSet {
            guard simplenoteDividerColor != oldValue else {
                return
            }

            /// Forcing Redraw:
            /// Believe me. Standard API(s) to trigger redraw aren't forcing the Dividers to re-render. That includes the following:
            ///
            /// - `layerContentsRedrawPolicy = .onSetNeedsDisplay`
            /// - `needsDisplay = true`
            /// - `needsLayout = true`
            ///
            /// macOS Catalina doesn't require any special treatment, because of the new Dynamic NSColor API.
            ///
            if #available(macOS 10.15, *) {
                return
            }

            if #available(macOS 10.14, *) {
                performMojaveRedrawHack()
                return
            }
        }
    }

    // MARK: - Overridden Methods

    override var dividerThickness: CGFloat {
        defaultDividerThickness
    }

    override var dividerColor: NSColor {
        return simplenoteDividerColor
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
