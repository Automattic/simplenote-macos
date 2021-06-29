import Foundation


// MARK: - BreadcrumbsViewController
//
class BreadcrumbsViewController: NSViewController {

    /// Background
    ///
    @IBOutlet private var backgroundView: BackgroundView!

    /// Status: TextField
    ///
    @IBOutlet private var statusTextField: NSTextField!


    /// Status: Search
    ///
    private var statusForSearch: String? {
        didSet {
            refreshStatus()
        }
    }

    /// Status: Tag
    ///
    private var statusForTags = String() {
        didSet {
            refreshStatus()
        }
    }

    /// Status: Note
    ///
    private var statusForNotes = String() {
        didSet {
            refreshStatus()
        }
    }

    /// Responder Status
    ///
    private var isTagsActive: Bool = false {
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

    func responderWasUpdated(isTagsActive: Bool) {
        self.isTagsActive = isTagsActive
    }

    func tagsControllerDidUpdateFilter(_ filter: TagListFilter) {
        let newStatusForTags = filter.title
        guard newStatusForTags != statusForTags else {
            return
        }

        statusForTags = filter.title
        statusForNotes = String()
    }

    func notesControllerDidSearch(text: String?) {
        statusForSearch = text
    }

    func notesControllerDidSelectNote(_ note: Note) {
        note.ensurePreviewStringsAreAvailable()

        statusForNotes = {
            let title   = note.titlePreview ?? ""
            let clipped = String(title.prefix(Metrics.maximumTitleLength))
            let suffix  = clipped.count < title.count ? "..." : ""

            return clipped + suffix
        }()
    }

    func notesControllerDidSelectNotes(_ notes: [Note]) {
        statusForNotes = NSLocalizedString("\(notes.count) Selected", comment: "Presented when there are multiple selected notes")
    }

    func notesControllerDidSelectZeroNotes() {
        statusForNotes = String()
    }

    func editorControllerUpdatedNote(_ note: Note) {
        // Yup. Same handler, different public API. Capisce?
        notesControllerDidSelectNote(note)
    }
}


// MARK: - Status
//
private extension BreadcrumbsViewController {

    func refreshStatus() {
        statusTextField.attributedStringValue = attributedSearchText() ?? attributedPathText()
    }

    func attributedSearchText() -> NSAttributedString? {
        guard let searchText = statusForSearch, !searchText.isEmpty else {
            return nil
        }

        let text = NSLocalizedString("Searching", comment: "StatusBar Search Indicator") + .space + "\"" + searchText + "\""
        return NSMutableAttributedString(string: text, attributes: StatusStyle.active)
    }

    func attributedPathText() -> NSAttributedString {
        let tagsStyle   = isTagsActive ? StatusStyle.active : StatusStyle.regular
        let notesStyle  = isTagsActive ? StatusStyle.regular : StatusStyle.active
        let output      = NSMutableAttributedString(string: statusForTags, attributes: tagsStyle)

        if statusForNotes.isEmpty {
            return output
        }

        output += NSAttributedString(string: " / ", attributes: StatusStyle.regular)
        output += NSMutableAttributedString(string: statusForNotes, attributes: notesStyle)

        return output
    }
}


// MARK: - StatusStyle
//
private enum StatusStyle {
    static var regular: [NSAttributedString.Key : Any] {
        return [
            .font:              Metrics.font,
            .foregroundColor:   NSColor.simplenoteStatusBarTextColor
        ]
    }

    static var active: [NSAttributedString.Key : Any] {
        return [
            .font:              Metrics.font,
            .foregroundColor:   NSColor.simplenoteStatusBarHighlightedTextColor
        ]
    }
}


private enum Metrics {
    static let font = NSFont.systemFont(ofSize: 11, weight: .regular)
    static let maximumTitleLength = 60
}
