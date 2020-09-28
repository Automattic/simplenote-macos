import Foundation
import AppKit


// MARK: - InterlinkWindowController
//
class InterlinkWindowController: NSWindowController {

    private var interlinkViewController: InterlinkViewController? {
        contentViewController as? InterlinkViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        setupRoundedCorners()
    }
}


// MARK: - Lookup API
//
extension InterlinkWindowController {

    ///
    ///
    func attach(to parentWindow: NSWindow?) {
        guard let window = window else {
            assertionFailure()
            return
        }

        parentWindow?.addChildWindow(window, ordered: .above)
    }

    /// Adjusts the receiver's Window Location relative to the specified frame. We'll make sure it doesn't get clipped horizontally or vertically
    ///
    func locateWindow(relativeTo positioningRect: NSRect) {
        guard let window = window else {
            assertionFailure()
            return
        }

        let frameOrigin = calculateWindowOrigin(windowSize: window.frame.size, positioningRect: positioningRect)
        window.setFrameOrigin(frameOrigin)
    }

    /// Refreshes the Autocomplete Interlinks
    ///
    func refreshInterlinks(for keyword: String) {
        // TODO: Wire Me!
    }
}


// MARK: - Private API(s)
//
private extension InterlinkWindowController {

    func setupRoundedCorners() {
        guard #available(macOS 10.15, *) else {
            return
        }

        window?.backgroundColor = .clear
        window?.isOpaque = false
    }

    func calculateWindowOrigin(windowSize: CGSize, positioningRect: CGRect) -> CGPoint {
        let screenWidth = NSScreen.main?.visibleFrame.width ?? .infinity
        var output = positioningRect.origin

        // Adjust Origin.Y: Avoid falling below the screen
        let positionBelowY = output.y - windowSize.height - Metrics.windowInsets.top
        let positionAboveY = output.y + positioningRect.height + Metrics.windowInsets.top

        output.y = positionBelowY > .zero ? positionBelowY : positionAboveY

        // Adjust Origin.X: Compensate for horizontal overflow
        let overflowX = screenWidth - output.x - windowSize.width
        if overflowX < .zero {
            output.x += overflowX - Metrics.windowInsets.right
        }

        return output
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let windowInsets = NSEdgeInsets(top: 12, left: .zero, bottom: .zero, right: 12)
}
