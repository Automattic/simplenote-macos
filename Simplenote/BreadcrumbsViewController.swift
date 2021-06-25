import Foundation


// MARK: - BreadcrumbsViewController
//
class BreadcrumbsViewController: NSViewController {

    /// Status Label
    ///
    @IBOutlet private var statusTextField: NSTextField!

    /// Background
    ///
    @IBOutlet private var backgroundView: BackgroundView!

    ///
    ///
    private var statusForTags = String() {
        didSet {
            refreshStatus()
        }
    }

    ///
    ///
    private var statusForNotes = String() {
        didSet {
            refreshStatus()
        }
    }


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        refreshStyle()
    }
}


// MARK: - Notifications
//
private extension BreadcrumbsViewController {

    func startListeningToNotifications() {
        if #available(macOS 10.15, *) {
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Theming
//
private extension BreadcrumbsViewController {

    @objc
    func refreshStyle() {
        backgroundView.drawsTopBorder = true
        backgroundView.borderColor = .simplenoteDividerColor
        backgroundView.fillColor = .simplenoteStatusBarBackgroundColor
    }
}


// MARK: - Public API(s)
//
extension BreadcrumbsViewController {

    func tagsControllerDidUpdateFilter(_ filter: TagListFilter) {
        statusForTags = filter.title
    }

    func notesControllerDidSelectNote(_ note: Note) {
        statusForNotes = note.titlePreview ?? ""
    }

    func notesControllerDidSelectNotes(_ notes: [Note]) {
        statusForNotes = NSLocalizedString("Many Selected", comment: "Presented when there are multiple selected notes")
    }

    func notesControllerDidSelectZeroNotes() {
        statusForNotes = NSLocalizedString("-", comment: "Presented when there are no selected notes")
    }

    func editorControllerUpdatedNote(_ note: Note) {
        statusForNotes = note.titlePreview ?? ""
    }
}


// MARK: - Status
//
private extension BreadcrumbsViewController {

    func refreshStatus() {
        let suffix = statusForNotes.isEmpty ? "" : " / " + statusForNotes
        statusTextField.stringValue = statusForTags + suffix
    }
}
