import Foundation


// MARK: - BreadcrumbsViewController
//
class BreadcrumbsViewController: NSViewController {

    /// Background
    ///
    @IBOutlet private var backgroundView: BackgroundView!

    /// TextField: Search
    ///
    @IBOutlet private var searchTextField: NSTextField!

    /// ImageView: Tag / Right Chevron
    ///
    @IBOutlet private var tagImageView: NSImageView!

    /// TextField: Tag
    ///
    @IBOutlet private var tagTextField: NSTextField!

    /// ImageView: Note / Right Chevron
    ///
    @IBOutlet private var noteImageView: NSImageView!


    /// TextField: Note
    ///
    @IBOutlet private var noteTextField: NSTextField!


    /// Status: Search
    ///
    private var statusForSearch = String() {
        didSet {
            refreshInterface()
        }
    }

    /// Status: Tag
    ///
    private var statusForTags = String() {
        didSet {
            guard oldValue != statusForTags else {
                return
            }

            statusForNotes = String()
            refreshInterface()
        }
    }

    /// Status: Note
    ///
    private var statusForNotes = String() {
        didSet {
            refreshInterface()
        }
    }

    /// Responder Status
    ///
    private var mustHighlightTags: Bool = false {
        didSet {
            refreshInterface()
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

        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Theming
//
private extension BreadcrumbsViewController {

    @objc
    func themeDidChange() {
        refreshStyle()
        refreshInterface()
    }

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
        mustHighlightTags = isTagsActive
    }

    func tagsControllerDidUpdateFilter(_ filter: TagListFilter) {
        statusForTags = filter.title
    }

    func notesControllerDidSearch(text: String?) {
        statusForSearch = {
            guard let text = text, !text.isEmpty else {
                return ""
            }

            return NSLocalizedString("Searching", comment: "StatusBar Search Indicator") + .space + "\"" + text + "\""
        }()
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

    func refreshInterface() {
        let isSearchHidden              = statusForSearch.isEmpty
        searchTextField.textColor       = .simplenoteStatusBarHighlightedTextColor
        searchTextField.stringValue     = statusForSearch
        searchTextField.isHidden        = isSearchHidden

        let isTagHidden                 = !isSearchHidden
        tagImageView.isHidden           = isTagHidden
        tagImageView.contentTintColor   = .simplenoteStatusBarTextColor
        tagTextField.textColor          = mustHighlightTags ? .simplenoteStatusBarHighlightedTextColor : .simplenoteStatusBarTextColor
        tagTextField.stringValue        = statusForTags
        tagTextField.isHidden           = isTagHidden

        let isNoteHidden                = !isSearchHidden || statusForNotes.isEmpty
        noteImageView.isHidden          = isNoteHidden
        noteImageView.contentTintColor  = .simplenoteStatusBarTextColor
        noteTextField.textColor         = mustHighlightTags ? .simplenoteStatusBarTextColor : .simplenoteStatusBarHighlightedTextColor
        noteTextField.stringValue       = statusForNotes
        noteTextField.isHidden          = isNoteHidden
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let font = NSFont.systemFont(ofSize: 11, weight: .regular)
    static let maximumTitleLength = 60
}
