import Foundation
import WebKit
import SimplenoteFoundation

// MARK: - MarkdownViewController
//
@objcMembers
class MarkdownViewController: NSViewController {

    /// BackgroundView
    ///
    @IBOutlet private var backgroundView: BackgroundView!

    /// Main WebView
    /// -   Note: We're embedding the WebView inside a NSScrollView, as a workaround to fix an annoying layout bug.
    ///
    /// -   Bug: Whenever the containing window has the `fullSizeContentView` mask, WebKit is assuming the Position Y is always zero.
    ///         This has the super cool side effect of cutting off the content. As per macOS 10.15, WKWebView is no longer exposing the
    ///         internal ScrollView, so there is no direct way to fix this, other than providing a different enclosing environment.
    ///
    @IBOutlet private var webView: WKWebView! {
        didSet {
            setupWebView(webView)
        }
    }

    /// Allowed Outgoing link Schemes
    ///
    private let allowedOutboundSchemes = ["http", "https", "mailto", SimplenoteConstants.simplenoteScheme]

    /// Markdown Text to be rendered
    ///
    private var note: Note? {
        didSet {
            refreshHTML()
        }
    }

    /// Entity Observer: Helps us keep track of changes applied to a Note
    ///
    private var entityObserver: EntityObserver?

    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
        stopListeningToSystemNotifications()
        stopListeningToNoteUpdates()
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        startListeningToNotifications()
        startListeningToSystemNotifications()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startListeningToNotifications()
        startListeningToSystemNotifications()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        refreshStyle()
    }

    override func removeFromParent() {
        super.removeFromParent()
        stopListeningToNoteUpdates()
    }

    /// For performance purposes: We'll ensure the WebView is ready to refresh in a split second
    ///
    func preloadView() {
        if isViewLoaded {
            return
        }

        loadView()
        refreshHTML()
    }

    /// Starts displaying the contents of a Note. The UI will be automatically refreshed when such entity is updated anyhow.
    ///
    func startDisplayingContents(of note: Note) {
        self.note = note
        startListeningToUpdates(for: note)
    }
}

// MARK: - WKNavigationDelegate
//
extension MarkdownViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType == .linkActivated else {
            decisionHandler(.allow)
            return
        }

        if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased(), allowedOutboundSchemes.contains(scheme) {
            NSWorkspace.shared.open(url)
        }

        decisionHandler(.cancel)
    }
}

// MARK: - EntityObserverDelegate
//
extension MarkdownViewController: EntityObserverDelegate {

    func entityObserver(_ observer: EntityObserver, didObserveChanges identifiers: Set<NSManagedObjectID>) {
        refreshHTML()
    }
}

// MARK: - Private
//
private extension MarkdownViewController {

    func setupWebView(_ webView: WKWebView) {

        /// Hack:
        /// In macOS... this is absolutely the only way to prevent WebKit from rendering its background. We intend to
        /// use `backgroundView` to render BG, and have the MarkdownPreview rendering on top, with full transparency.
        ///
        webView.setValue(false, forKey: "drawsBackground")
    }
}

// MARK: - Notification Helpers
//
private extension MarkdownViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshInterface), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        DistributedNotificationCenter.default().removeObserver(self)
    }

    func startListeningToSystemNotifications() {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(refreshInterface), name: .AppleInterfaceThemeChanged, object: nil)
    }

    func stopListeningToSystemNotifications() {
        DistributedNotificationCenter.default().removeObserver(self)
    }

    func startListeningToUpdates(for note: Note) {
        let mainContext = SimplenoteAppDelegate.shared().managedObjectContext

        entityObserver = EntityObserver(context: mainContext, object: note)
        entityObserver?.delegate = self
    }

    func stopListeningToNoteUpdates() {
        entityObserver?.delegate = nil
        entityObserver = nil
    }

    @objc
    func refreshInterface() {
        refreshStyle()
        refreshHTML()
    }

    func refreshStyle() {
        backgroundView.fillColor = .simplenoteSecondaryBackgroundColor
    }

    func refreshHTML() {
        let content = note?.content ?? ""
        let html = SPMarkdownParser.renderHTML(fromMarkdownString: content) ?? ""

        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }
}
