import Foundation


// MARK: - BreadcrumbsViewController
//
class BreadcrumbsViewController: NSViewController {

    /// Background
    ///
    @IBOutlet private var backgroundBox: NSBox!
    @IBOutlet private var dividerView: BackgroundView!

    /// TextField: Search
    ///
    @IBOutlet private var searchTextField: NSTextField!

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

    /// Indicates if there's a User Tag being presented (false indicates system filter!)
    ///
    private var isUserTagSelected: Bool = false


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        refreshStyle()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        refreshRTLSupport()
    }
}


// MARK: - Notifications
//
private extension BreadcrumbsViewController {

    func startListeningToNotifications() {
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
}


// MARK: - Public API(s)
//
extension BreadcrumbsViewController {

    func responderWasUpdated(isTagsActive: Bool) {
        mustHighlightTags = isTagsActive
    }

    @objc
    func didReceiveNewContent(_ note: Note) {
        refreshStatus(for: note)
    }

    func tagsControllerDidUpdateFilter(_ filter: TagListFilter) {
        statusForTags = filter.title
        isUserTagSelected = {
            guard case .tag(_) = filter else {
                return false
            }

            return true
        }()
    }

    func tagsControllerDidRenameTag(oldName: String, newName: String) {
        guard statusForTags == oldName, isUserTagSelected else {
            return
        }

        statusForTags = newName
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
        refreshStatus(for: note)
    }

    func notesControllerDidSelectNotes(_ notes: [Note]) {
        statusForNotes = NSLocalizedString("\(notes.count) Selected", comment: "Presented when there are multiple selected notes")
    }

    func notesControllerDidSelectZeroNotes() {
        statusForNotes = String()
    }

    func editorControllerUpdatedNote(_ note: Note) {
        refreshStatus(for: note)
    }
}


// MARK: - Private Helpers
//
private extension BreadcrumbsViewController {

    private func refreshStatus(for note: Note) {
        note.ensurePreviewStringsAreAvailable()

        statusForNotes = {
            let title   = note.titlePreview ?? ""
            let clipped = String(title.prefix(Metrics.maximumTitleLength))
            let suffix  = clipped.count < title.count ? "..." : ""

            return clipped + suffix
        }()
    }
}


// MARK: - Interface
//
private extension BreadcrumbsViewController {

    func refreshInterface() {
        let isSearchHidden              = statusForSearch.isEmpty
        searchTextField.textColor       = .simplenoteStatusBarHighlightedTextColor
        searchTextField.stringValue     = statusForSearch
        searchTextField.isHidden        = isSearchHidden

        let isTagHidden                 = !isSearchHidden
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

    func refreshStyle() {
        backgroundBox.boxType = .simplenoteSidebarBoxType
        backgroundBox.fillColor = .simplenoteSecondaryBackgroundColor
        dividerView.borderColor = .simplenoteDividerColor
        dividerView.drawsTopBorder = true
    }

    func refreshRTLSupport() {
        let isRTL        = view.window?.isRTL ?? false
        let isNotRotated = noteImageView.boundsRotation != Metrics.rotation180Degrees

        guard isRTL, isNotRotated else {
            return
        }

        noteImageView.rotate(byDegrees: Metrics.rotation180Degrees)
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let font = NSFont.systemFont(ofSize: 11, weight: .regular)
    static let maximumTitleLength = 60
    static let rotation180Degrees = CGFloat(180)
}
