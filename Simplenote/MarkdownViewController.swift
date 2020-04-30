import Foundation
import WebKit


// MARK: - MarkdownViewController
//
@objcMembers
class MarkdownViewController: NSViewController {

    /// BackgroundView
    ///
    @IBOutlet private var backgroundView: SPBackgroundView!

    /// Main WebView
    ///
    @IBOutlet private var webView: WKWebView! {
        didSet {
            setupWebView(webView)
        }
    }

    /// Allowed Outgoing link Schemes
    ///
    private let allowedOutboundSchemes = ["http", "https", "mailto"]

    /// Markdown Text to be rendered
    ///
    var markdown: String? {
        didSet {
            refreshHTML()
        }
    }


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        startListeningToNotifications()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startListeningToNotifications()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        refreshStyle()
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
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func refreshInterface() {
        refreshStyle()
        refreshHTML()
    }

    func refreshStyle() {
        backgroundView.fillColor = .simplenoteBackgroundColor
    }

    func refreshHTML() {
        let content = markdown ?? ""
        let html = SPMarkdownParser.renderHTML(fromMarkdownString: content) ?? ""

        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }
}
