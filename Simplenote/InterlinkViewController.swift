import Foundation
import AppKit
import SimplenoteFoundation


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

    /// Main Context
    ///
    private var mainContext: NSManagedObjectContext {
        SimplenoteAppDelegate.shared().managedObjectContext
    }

    /// ResultsController: In charge of CoreData Queries!
    ///
    private lazy var resultsController: ResultsController<Note> = {
        return ResultsController<Note>(viewContext: mainContext, sortedBy: [
            NSSortDescriptor(keyPath: \Note.content, ascending: true)
        ])
    }()

    /// In-Memory Filtered Notes
    /// -   Our Storage does not split `Title / Body`. Filtering by keywords in the title require a NSPredicate + Block
    /// -   The above is awfully underperformant.
    /// -   Most efficient approach code wise / speed involves simply keeping a FRC instance, and filtering it as needed
    ///
    private var filteredNotes = [Note]()

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?


    // MARK: - Overridden Methods

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        refreshStyle()
        setupResultsController()
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
    func refreshInterlinks(for keyword: String, excluding excludedID: NSManagedObjectID?) -> Bool {
        filteredNotes = filterNotes(resultsController.fetchedObjects, byTitleKeyword: keyword, excluding: excludedID)
        let displaysRows = filteredNotes.count > .zero

        if displaysRows {
            refreshTableView()
        }

        return displaysRows
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

        guard #available(macOS 11.0, *) else {
            return
        }

        tableView.style = .fullWidth
    }

    func setupTrackingAreas() {
        view.addTrackingArea(trackingArea)
    }

    func setupResultsController() {
        resultsController.predicate = NSPredicate.predicateForNotes(deleted: false)
        try? resultsController.performFetch()
    }
}


// MARK: - Filtering
//
private extension InterlinkViewController {

    func filterNotes(_ notes: [Note], byTitleKeyword keyword: String, excluding excludedID: NSManagedObjectID?, limit: Int = Settings.maximumNumberOfResults) -> [Note] {
        var output = [Note]()
        let normalizedKeyword = keyword.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)

        for note in notes where note.objectID != excludedID {
            note.ensurePreviewStringsAreAvailable()
            guard let normalizedTitle = note.titlePreview?.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil),
                  normalizedTitle.contains(normalizedKeyword)
            else {
                continue
            }

            output.append(note)

            if output.count >= limit {
                break
            }
        }

        return output
    }

    func refreshTableView() {
        tableView.reloadDataAndResetSelection()
    }
}


// MARK: - Action Handlers
//
extension InterlinkViewController {

    @objc
    func performInterlinkInsert() {
        guard let markdownInterlink = noteAtRow(tableView.selectedRow)?.markdownInterlink else {
            return
        }

        onInsertInterlink?(markdownInterlink)
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

    func noteAtRow(_ row: Int) -> Note? {
        guard row < filteredNotes.count else {
            return nil
        }

        return filteredNotes[row]
    }
}


// MARK: - NSTableViewDataSource
//
extension InterlinkViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        filteredNotes.count
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
        rowView.style = .fullWidth
        return rowView
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let note = noteAtRow(row) else {
            return nil
        }

        note.ensurePreviewStringsAreAvailable()

        let tableViewCell = tableView.makeTableViewCell(ofType: LinkTableCellView.self)
        tableViewCell.title = note.titlePreview
        return tableViewCell
    }
}


// MARK: - Settings!
//
private enum Settings {
    static let cornerRadius = CGFloat(6)
    static let maximumNumberOfResults = 15
}
