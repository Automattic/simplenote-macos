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


    // MARK - View Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        applyStyle()
    }
}


// MARK: - Private
//
private extension ShareViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applyStyle), name: .ThemeDidChange, object: nil)
    }

    @objc
    func applyStyle() {
        shareTextField.textColor = .simplenotePopoverTextColor
    }
}
