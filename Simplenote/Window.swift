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

    /// Semaphore Buttons: Quick access reference to the Close / Minimize / Zoom buttons
    ///
    private lazy var buttons: [NSButton] = [.closeButton, .miniaturizeButton, .zoomButton].compactMap { type in
        standardWindowButton(type)
    }

    /// Allows us to adjust the Origin for the Semaphore Buttons (Close / Miniaturize / Zoom)
    ///
    var semaphoreButtonOriginY: CGFloat?

    /// Horizontal Padding to be applied over all of the Semaphore Buttons
    ///
    var semaphoreButtonPaddingX: CGFloat?


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

    override func mouseUp(with event: NSEvent) {
        processDoubleClickOnTitlebarIfNeeded(with: event)
        super.mouseUp(with: event)
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        relocateSemaphoreButtonsIfNeeded()
    }

    override func selectNextKeyView(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(NoteListViewController.switchToTrailingPanel), to: nil, from: sender)
    }

    override func selectPreviousKeyView(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(NoteListViewController.switchToLeadingPanel), to: nil, from: sender)
    }

    override func makeFirstResponder(_ responder: NSResponder?) -> Bool {
        let result = super.makeFirstResponder(responder)
        if result, let responder = responder {
            SimplenoteAppDelegate.shared().updateActivePanel(with: responder)
        }
        return result
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

    func relocateSemaphoreButtonsIfNeeded() {
        guard let semaphorePaddingX = semaphoreButtonPaddingX, let semaphoreOriginY = semaphoreButtonOriginY else {
            return
        }

        relocateSemaphoreButtons(semaphorePaddingX: semaphorePaddingX, semaphoreOriginY: semaphoreOriginY)
        refreshSemaphoreTrackingAreas()
    }

    func relocateSemaphoreButtons(semaphorePaddingX: CGFloat, semaphoreOriginY: CGFloat) {
        let directionalMultiplier: CGFloat = isRTL ? -1 : 1

        for button in buttons {
            var origin = button.frame.origin
            guard origin.y != semaphoreOriginY else {
                continue
            }

            /// Why:
            ///  1.  We can't adjust the NSTitlebarView height
            ///  2.  Yes. The default superview may clip the Semaphore Button, if the position falls outside its bounds
            ///  3.  And yes. This is yet another hack.
            ///
            if button.superview != contentView {
                button.removeFromSuperview()
                contentView?.addSubview(button, positioned: .above, relativeTo: nil)
            }

            origin.y = semaphoreOriginY
            origin.x += semaphorePaddingX * directionalMultiplier
            button.frame.origin = origin
        }
    }

    func refreshSemaphoreTrackingAreas() {
        guard let themeView = contentView?.superview else {
            return
        }

        // HACK HACK
        // Ref. https://github.com/indragiek/INAppStoreWindow/blob/master/INAppStoreWindow/INAppStoreWindow.m#L1324
        // Ref. https://zhenchao.li/2018-07-04-positioning-traffic-lights-of-your-cocoa-app/
        //
        themeView.viewWillStartLiveResize()
        themeView.viewDidEndLiveResize()
    }
}


// MARK: - Titlebar / DoubleClick Workaround
//
private extension Window {

    /// Whenever a NSWindow instance has the `.fullSizeContentView` mask, the system will simply no longer automatically process
    /// double click events on the Titlebar Area.
    ///
    /// Ref. #1: https://github.com/Automattic/simplenote-macos/issues/773
    /// Ref. #2: https://stackoverflow.com/questions/52150960/double-click-on-transparent-nswindow-title-does-not-maximize-the-window/61712229#61712229
    ///
    func processDoubleClickOnTitlebarIfNeeded(with event: NSEvent) {
        guard styleMask.contains(.fullSizeContentView),
              event.clickCount >= 2,
              titlebarRect.contains(event.locationInWindow)
        else {
            return
        }

        // Let's all calm down, and allow double click over the First Responder
        if effectiveFirstResponder(contains: event.locationInWindow) {
            return
        }

        // Plus let's ignore double clicks over Subviews that can become first responders
        if contentView?.hitTest(event.locationInWindow)?.acceptsFirstResponder == true {
            return
        }

        self.performZoom(nil)
    }

    /// In AppKit the Window's Field Editor handles Input, "on behalf" of the First Responder
    ///
    /// In the particular case of NSSearchField, the `firstResponder` (Field Editor) will only match the bounds of the TextField Area,
    /// ignoring the Loupe + enclosing rectangle.
    ///
    /// By accessing the `Effective First Responder` we can ignore double clicks over areas such as the Loupe.
    ///
    func effectiveFirstResponder(contains point: CGPoint) -> Bool {
        guard let fieldEditor = firstResponder as? NSText,
           let effectiveFirstResponder = fieldEditor.delegate as? NSView
        else {
            return false
        }

        let onScreenResponderBounds = effectiveFirstResponder.convert(effectiveFirstResponder.bounds, to: nil)
        return onScreenResponderBounds.contains(point)
    }
}
