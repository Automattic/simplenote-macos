import Foundation
import AppKit


// MARK: - InterlinkWindowController
//
class InterlinkWindowController: NSWindowController {

    /// Token required for `Mouse Event` Listening purposes
    ///
    private var eventListenerToken: Any?

    /// Returns the InterlinkViewController Instance
    ///
    private var interlinkViewController: InterlinkViewController? {
        contentViewController as? InterlinkViewController
    }


    // MARK: - Overridden Methods

    override func windowDidLoad() {
        super.windowDidLoad()
        setupRoundedCorners()
        setupWindowAnimation()
    }

    override func close() {
        super.close()
        stopListeningToDismissEvents()
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
        startListeningToDismissEvents(for: interlinkWindow)
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

    /// Refreshes the Autocomplete Interlinks
    ///
    func displayInterlinks(for keyword: String) {
        interlinkViewController?.displayInterlinks(for: keyword)
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

    func setupWindowAnimation() {
        window?.animationBehavior = .utilityWindow
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


// MARK: - Dismissal Events
//
private extension InterlinkWindowController {

    /// Let's automatically dismiss whenever:
    /// - The user clicks / scrolls in another window that's not the Interlinking Window
    /// - The Main Window looses its key status
    ///
    func startListeningToDismissEvents(for window: NSWindow) {
        eventListenerToken = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel]) { [weak self] event in
            if event.window != window {
                self?.close()
            }

            return event
        }

            self?.close()
        }
    }

    /// Drops the Dismissal Event Listeners
    ///
    func stopListeningToDismissEvents() {
        if let token = eventListenerToken {
            NSEvent.removeMonitor(token)
        }

        eventListenerToken = nil
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let windowInsets = NSEdgeInsets(top: 12, left: .zero, bottom: .zero, right: 12)
}
