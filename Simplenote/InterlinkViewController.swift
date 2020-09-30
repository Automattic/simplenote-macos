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
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.content, ascending: true)
        return ResultsController(viewContext: mainContext, sortedBy: [sortDescriptor])
    }()


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

    /// Refreshes the UI so that Interlinks for the specified Keyword are rendered
    ///
    func displayInterlinks(for keyword: String) {
        refreshResultsPredicate(for: keyword)
        tableView.reloadDataAndResetSelection()
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

    func setupTrackingAreas() {
        view.addTrackingArea(trackingArea)
    }

    func setupResultsController() {
        resultsController.limit = Settings.maximumNumberOfResults
        resultsController.onDidChangeContent = { [weak self] _, _ in
            self?.tableView.reloadAndPreserveSelection()
        }
    }

    func refreshResultsPredicate(for keyword: String) {
        resultsController.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate.predicateForNotes(searchText: keyword),
            NSPredicate.predicateForNotes(deleted: false)
        ])

        try? resultsController.performFetch()
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

    func noteAtRow(_ row: Int) -> Note? {
        let objects = resultsController.fetchedObjects
        guard row < objects.count else {
            return nil
        }

        return objects[row]
    }
}


// MARK: - NSTableViewDataSource
//
extension InterlinkViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        resultsController.numberOfObjects
    }
}


// MARK: - NSTableViewDelegate
//
extension InterlinkViewController: NSTableViewDelegate {

    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        true
    }

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRowView()
        rowView.selectedBackgroundColor = .simplenoteSelectedBackgroundColor
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
