import Foundation

// MARK: - CollaborateViewController
//
class CollaborateViewController: NSViewController {

    /// Share Text Legend
    ///
    @IBOutlet private var shareTextField: NSTextField! {
        didSet {
            let text = NSLocalizedString("Collaboration is retiring on July 1st, 2024. For more details, click here.", comment: "Collaboration retirement notice")
            shareTextField.stringValue = text
        }
    }

    /// NSPopover instance that's presenting the current instance.
    ///
    private var presentingPopover: NSPopover? {
        didSet {
            refreshStyle()
        }
    }

    // MARK: - View Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        refreshStyle()
    }

    @IBAction
    func backgroundWasClicked(_ sender: Any) {
        guard let url = URL(string: SimplenoteConstants.collaborationDeprecationURL) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}

// MARK: - Private
//
private extension CollaborateViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    @objc
    func refreshStyle() {
        // Note: Backwards compatibility *requires* this line (10.13 / 10.14)
        presentingPopover?.appearance = .simplenoteAppearance
        shareTextField.textColor = .simplenoteTextColor
    }
}

// MARK: - NSPopoverDelegate
//
extension CollaborateViewController: NSPopoverDelegate {

    public func popoverWillShow(_ notification: Notification) {
        presentingPopover = notification.object as? NSPopover
    }
}
