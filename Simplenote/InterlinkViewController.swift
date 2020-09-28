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


    // MARK: - Overridden Methdos

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupMouseCursor()
        setupResultsController()
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
    }
}


// MARK: - Setup!
//
private extension InterlinkViewController {

    func setupBackground() {
        backgroundView.fillColor = .simplenoteBackgroundColor
        tableView.backgroundColor = .clear
    }

    func setupMouseCursor() {
        view.addTrackingArea(trackingArea)
    }

    func setupResultsController() {
        resultsController.onDidChangeContent = { [weak self] _, _ in
            self?.tableView.reloadData()
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

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRowView()
        rowView.selectedBackgroundColor = .simplenoteSelectedBackgroundColor
        return rowView
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let note = resultsController.fetchedObjects[row]

        let tableViewCell = tableView.makeTableViewCell(ofType: LinkTableCellView.self)
        tableViewCell.title = note.titlePreview
        return tableViewCell
    }
}
