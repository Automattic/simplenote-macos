import Foundation


// MARK: - MainWindowController
//
class MainWindowController: NSWindowController {

    /// We can't have nice things: Someone decided to make `.window` an optional. Plus: we kinda need access to custom properties
    ///
    @IBOutlet private(set) var simplenoteWindow: Window!

    // MARK: - Overridden Methods

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        setupMainWindow()
        setupToolbar()
        relocateSemaphoreButtons()
        startListeningToFullscreenNotifications()
    }
}


// MARK: - NSWindowDelegate
//
extension MainWindowController: NSWindowDelegate {

    /// Let's autohide the Toolbar, since it causes a shaky animation
    ///
    func window(_ window: NSWindow, willUseFullScreenPresentationOptions proposedOptions: NSApplication.PresentationOptions = []) -> NSApplication.PresentationOptions {
        [.autoHideToolbar, .autoHideMenuBar, .fullScreen]
    }
}


// MARK: - Initialization
//
private extension MainWindowController {

    /// Initalizes the Main Window
    ///
    func setupMainWindow() {
        simplenoteWindow.setFrameAutosaveName(.mainWindow)
    }

    /// We're attaching empty Toolbar, which will increase the Window's Title Height
    ///
    func setupToolbar() {
        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        simplenoteWindow.toolbar = customToolbar
    }

    /// We'll need to drop the Semaphore Workaround when entering Fullscreen
    ///
    func startListeningToFullscreenNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(willEnterFullscreen), name: NSWindow.willEnterFullScreenNotification, object: simplenoteWindow)
        nc.addObserver(self, selector: #selector(willExitFullscreen), name: NSWindow.willExitFullScreenNotification, object: simplenoteWindow)
    }
}


// MARK: - Semaphore Workaround
//
private extension MainWindowController {

    func relocateSemaphoreButtons() {
        simplenoteWindow.semaphoreButtonOriginY = Metrics.semaphoreButtonPositionY
        simplenoteWindow.semaphoreButtonPaddingX = Metrics.semaphoreButtonPaddingX
    }

    func disableSemaphoreButtonsWorkaround() {
        simplenoteWindow.semaphoreButtonOriginY = nil
        simplenoteWindow.semaphoreButtonPaddingX = nil
    }
}


// MARK: - Notifications
//
extension MainWindowController {

    @objc
    func willEnterFullscreen() {
        disableSemaphoreButtonsWorkaround()
    }

    @objc
    func willExitFullscreen() {
        relocateSemaphoreButtons()
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let semaphoreButtonPositionY: CGFloat = 4
    static let semaphoreButtonPaddingX: CGFloat = 7
}
