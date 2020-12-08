import Foundation
import AppKit


// MARK: - ParentWindowDelegate Protocol
//
protocol ParentWindowDelegate {

    /// Invoked for every Child Window, whenever we're about to send an event.
    /// - Note: Whenever this method returns `true`, the parent window will stop processing the associated event!
    ///
    func processParentWindowEvent(_ event: NSEvent) -> Bool
}


// MARK: - Simplenote Window
//
class Window: NSWindow {

    /// Allows us to adjust the Origin for the Semaphore Buttons (Close / Miniaturize / Zoom)
    ///
    var semaphoreButtonOriginY: CGFloat?

    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        startListeningToNotifications()
        refreshStyle()
    }

    // MARK: - Overridden API(s)

    override func sendEvent(_ event: NSEvent) {
        let children = childWindows ?? []
        for case let child as ParentWindowDelegate in children where child.processParentWindowEvent(event) {
            return
        }

        super.sendEvent(event)
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        guard let semaphoreOriginY = semaphoreButtonOriginY else {
            return
        }

        relocateSemaphoreButtons(originY: semaphoreOriginY)
    }
}


// MARK: - Initialization
//
private extension Window {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Notification Handlers
//
private extension Window {

    @objc
    func refreshStyle() {
        if SPUserInterface.isSystemThemeSelected {
            appearance = nil
            return
        }

        appearance = NSAppearance.simplenoteAppearance
    }
}


// MARK: - Sempahore
//
private extension Window {

    func relocateSemaphoreButtons(originY: CGFloat) {
        let buttons: [NSButton] = [.closeButton, .miniaturizeButton, .zoomButton].compactMap { type in
            standardWindowButton(type)
        }

        for button in buttons {
            button.frame.origin.y = originY
        }
    }
}
