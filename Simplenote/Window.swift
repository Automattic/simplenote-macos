import Foundation
import AppKit


// MARK: - Simplenote Window
//
class Window: NSWindow {

    deinit {
        stopListeningToNotifications()
    }

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        startListeningToNotifications()
        refreshStyle()
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
        guard #available(macOS 10.14, *) else {
            return
        }

        if SPUserInterface.isSystemThemeSelected {
            appearance = nil
            return
        }

        appearance = NSAppearance.simplenoteAppearance
    }
}
