import Foundation
import AppKit


// MARK: - PopoverWindowController
//
class PopoverWindowController: NSWindowController {

    // MARK: - Overridden Methods

    init() {
        let window = PopoverWindow()
        super.init(window: window)
        setupWindowStyle(window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Public API
//
extension PopoverWindowController {

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

    /// Adjusts the receiver's Window Location relative to the specified frame (in screen cordinates). We'll make sure it doesn't get clipped horizontally or vertically
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
private extension PopoverWindowController {

    func setupWindowStyle(_ window: NSWindow) {
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask = [.borderless]
        window.animationBehavior = .utilityWindow

        // In macOS +10.15 the main ViewController will display rounded corners!
        if #available(macOS 10.15, *) {
            window.backgroundColor = .clear
            window.isOpaque = false
        }
    }

    func calculateWindowOrigin(windowSize: CGSize, positioningRect: CGRect) -> CGPoint {
        var output = positioningRect.origin

        // Adjust Origin.X: Compensate for horizontal overflow
        if let screenWidth = NSScreen.main?.visibleFrame.width, screenWidth < output.x + windowSize.width {
            let overflowX = screenWidth - output.x - windowSize.width
            output.x += overflowX - Metrics.windowInsets.right
        }

        output.x = round(output.x)

        // Adjust Origin.Y: Avoid falling below the screen
        let positionBelowY = output.y - windowSize.height - Metrics.windowInsets.top
        let positionAboveY = output.y + positioningRect.height + Metrics.windowInsets.top

        output.y = round(positionBelowY > .zero ? positionBelowY : positionAboveY)

        return output
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let windowInsets = NSEdgeInsets(top: 12, left: .zero, bottom: .zero, right: 12)
}
