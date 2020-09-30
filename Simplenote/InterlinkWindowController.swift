import Foundation
import AppKit


// MARK: - InterlinkWindowController
//
class InterlinkWindowController: NSWindowController {

    /// Returns the InterlinkViewController Instance
    ///
    var interlinkViewController: InterlinkViewController? {
        contentViewController as? InterlinkViewController
    }

    // MARK: - Overridden Methods

    override func windowDidLoad() {
        super.windowDidLoad()
        setupWindowStyle()
    }
}


// MARK: - Public API
//
extension InterlinkWindowController {

    /// Attaches the receiver's window to a given Parent Window
    ///
    func attach(to parentWindow: NSWindow?) {
        guard let parentWindow = parentWindow, let interlinkWindow = window else {
            assertionFailure()
            return
        }

        guard interlinkWindow.parent == nil else {
            return
        }

        parentWindow.addChildWindow(interlinkWindow, ordered: .above)
    }

    /// Adjusts the receiver's Window Location relative to the specified frame. We'll make sure it doesn't get clipped horizontally or vertically
    ///
    func positionWindow(relativeTo positioningRect: NSRect) {
        guard let window = window else {
            assertionFailure()
            return
        }

        let frameOrigin = calculateWindowOrigin(windowSize: window.frame.size, positioningRect: positioningRect)
        window.setFrameOrigin(frameOrigin)
    }
}


// MARK: - Private API(s)
//
private extension InterlinkWindowController {

    func setupWindowStyle() {
        window?.animationBehavior = .utilityWindow

        // In macOS +10.15 the main ViewController will display rounded corners!
        if #available(macOS 10.15, *) {
            window?.backgroundColor = .clear
            window?.isOpaque = false
        }
    }

    func calculateWindowOrigin(windowSize: CGSize, positioningRect: CGRect) -> CGPoint {
        let screenWidth = NSScreen.main?.visibleFrame.width ?? .infinity
        var output = positioningRect.origin

        // Adjust Origin.X: Compensate for horizontal overflow
        let overflowX = screenWidth - output.x - windowSize.width
        if overflowX < .zero {
            output.x += overflowX - Metrics.windowInsets.right
        }

        // Adjust Origin.Y: Avoid falling below the screen
        let positionBelowY = output.y - windowSize.height - Metrics.windowInsets.top
        let positionAboveY = output.y + positioningRect.height + Metrics.windowInsets.top

        output.y = round(positionBelowY > .zero ? positionBelowY : positionAboveY)

        output.y = round(output.y)
        output.x = round(output.x)

        return output
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let windowInsets = NSEdgeInsets(top: 12, left: .zero, bottom: .zero, right: 12)
}
