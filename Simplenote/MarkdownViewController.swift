import Foundation
import WebKit


// MARK: - MarkdownViewController
//
@objcMembers
class MarkdownViewController: NSViewController {

    /// Main WebView
    ///
    @IBOutlet private var webView: WKWebView!

    /// Allowed Outgoing link Schemes
    ///
    private let allowedOutboundSchemes = ["http", "https", "mailto"]

    /// Markdown Text to be rendered
    ///
    var markdown: String? {
        didSet {
            reloadHTML()
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


    /// For performance purposes: We'll ensure the WebView is ready to refresh in a split second
    ///
    func preloadView() {
        if isViewLoaded {
            return
        }

        loadView()
        reloadHTML()
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


// MARK: - Notification Helpers
//
extension MarkdownViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHTML), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func reloadHTML() {
        let content = markdown ?? ""
        let html = SPMarkdownParser.renderHTML(fromMarkdownString: content) ?? ""

        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }
}
