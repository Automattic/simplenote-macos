import Foundation


// MARK: - ShareViewController
//
class ShareViewController: NSViewController {

    /// Share Text Legend
    ///
    @IBOutlet private var shareTextField: NSTextField! {
        didSet {
            shareTextField.stringValue = NSLocalizedString("Add an email address as a tag to share this note with someone. Then you can both make changes to it.", comment: "Text presented when sharing a Note")
        }
    }

    /// NSPopover instance that's presenting the current instance.
    ///
    private var presentingPopover: NSPopover? {
        didSet {
            refreshStyle()
        }
    }


    // MARK - View Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        refreshStyle()
    }
}


// MARK: - Private
//
private extension ShareViewController {

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
extension ShareViewController: NSPopoverDelegate {

    public func popoverWillShow(_ notification: Notification) {
        presentingPopover = notification.object as? NSPopover
    }
}
