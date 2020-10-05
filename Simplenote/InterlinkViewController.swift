import Foundation
import AppKit
import SimplenoteFoundation
import SimplenoteSearch


// MARK: - InterlinkViewController
//
class InterlinkViewController: NSViewController {

    /// Background
    ///
    @IBOutlet private var backgroundView: BackgroundView!

    /// Autocomplete TableView
    ///
    @IBOutlet private var tableView: NSTableView!

    /// Mouse Tracking
    ///
    private lazy var trackingArea = NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)

    /// LookupController: Performs In-Memory Search!
    ///
    private let lookupController = LookupController()

    /// Lookup Notes to be presented onScreen
    ///
    private var notes = [LookupNote]()

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?


    // MARK: - Overridden Methods

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStyle()
        startListeningToNotifications()
        setupLookupController()
        setupRoundedCorners()
        setupTableView()
        setupTrackingAreas()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSCursor.pointingHand.set()
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.arrow.set()
    }
}


// MARK: - Public API(s)
//
extension InterlinkViewController {

    /// Refreshes the Autocomplete Results. Returns `true` when there are visible rows.
    /// - Important:
    ///     By design, whenever there are no results we won't be refreshing the TableView. Instead, we'll stick to the "old results".
    ///     This way we get to avoid the awkward visual effect of "empty autocomplete window"
    ///
    func refreshInterlinks(for keyword: String) -> Bool {
        notes = lookupController.search(titleText: keyword, limit: Settings.maximumNumberOfResults)
        if notes.isEmpty {
            return false
        }

        tableView.reloadDataAndResetSelection()
        return true
    }
}


// MARK: - Setup!
//
private extension InterlinkViewController {

    func setupRoundedCorners() {
        guard #available(macOS 10.15, *) else {
            return
        }

        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = Settings.cornerRadius
    }

    func setupTableView() {
        tableView.becomeFirstResponder()
        tableView.target = self
        tableView.doubleAction = #selector(performInterlinkInsert)
    }

    func setupTrackingAreas() {
        view.addTrackingArea(trackingArea)
    }

    func setupLookupController() {
        let predicate = NSPredicate.predicateForNotes(deleted: false)
        let notesBucket = SimplenoteAppDelegate.shared().simperium.notesBucket
        let allNotes = notesBucket.objects(ofType: Note.self, for: predicate)

        lookupController.preloadLookupTable(for: allNotes)
    }
}


// MARK: - Action Handlers
//
extension InterlinkViewController {

    @objc
    func performInterlinkInsert() {
        guard let searchNote = searchNoteAtRow(tableView.selectedRow) else {
            return
        }

        onInsertInterlink?(searchNote.markdownInternalLink)
    }
}


// MARK: - Notifications
//
private extension InterlinkViewController {

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


// MARK: - Interface
//
private extension InterlinkViewController {

    @objc
    func refreshStyle() {
        backgroundView.fillColor = .simplenoteBackgroundColor
        tableView.backgroundColor = .clear
        tableView.reloadAndPreserveSelection()
    }
}


// MARK: - Wrappers
//
private extension InterlinkViewController {

    func searchNoteAtRow(_ row: Int) -> LookupNote? {
        return row < notes.count ? notes[row] : nil
    }
}


// MARK: - NSTableViewDataSource
//
extension InterlinkViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        notes.count
    }
}


// MARK: - NSTableViewDelegate
//
extension InterlinkViewController: SPTableViewDelegate {

    public func tableView(_ tableView: NSTableView, didReceiveKeyDownEvent event: NSEvent) -> Bool {
        guard case NSEvent.SpecialKey.carriageReturn = event.specialKey else {
            return false
        }

        performInterlinkInsert()
        return true
    }

    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        true
    }

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRowView()
        rowView.selectedBackgroundColor = .simplenoteSelectedBackgroundColor
        return rowView
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let note = searchNoteAtRow(row) else {
            return nil
        }

        let tableViewCell = tableView.makeTableViewCell(ofType: LinkTableCellView.self)
        tableViewCell.title = note.title
        return tableViewCell
    }
}


// MARK: - Settings!
//
private enum Settings {
    static let cornerRadius = CGFloat(6)
    static let maximumNumberOfResults = 15
}
