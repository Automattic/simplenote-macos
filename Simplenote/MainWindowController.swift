import Foundation


// MARK: - MainWindowController
//
class MainWindowController: NSWindowController {

    /// We can't have nice things: Someone decided to make `.window` an optional. Plus: we kinda need access to custom properties
    ///
    @IBOutlet private(set) var simplenoteWindow: Window!

    /// We can't have nice things (II): Autosave must be set **after** the contentViewController has been assigned. Otherwise it won't work
    /// Ref.:  https://developer.apple.com/forums/thread/23453
    ///
    override var contentViewController: NSViewController? {
        didSet {
            setupAutosave()
        }
    }


    // MARK: - Overridden Methods

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
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

    /// Initalizes the Autosave: **MUST** happen after the content has been set!
    ///
    func setupAutosave() {
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
    static let semaphoreButtonPaddingX: CGFloat = 7
    static var semaphoreButtonPositionY: CGFloat {
        let bigSurPositionY: CGFloat = 4
        let mojavePositionY: CGFloat = 3
        guard #available(macOS 11, *) else {
            return mojavePositionY
        }

        return bigSurPositionY
    }
}
