import Foundation
import AppKit
import SimplenoteFoundation


// MARK: - MetricsViewController
//
class MetricsViewController: NSViewController {

    /// Enclosing ClipView
    ///
    @IBOutlet private weak var clipView: NSClipView!

    /// Our main TableView
    ///
    @IBOutlet private weak var tableView: NSTableView!

    /// NSPopover instance that's presenting the current instance.
    ///
    private var presentingPopover: NSPopover? {
        didSet {
            refreshStyle()
        }
    }

    /// Notes whose metrics should be rendered
    ///
    private let notes: [Note]

    /// Main Context
    ///
    private var mainContext: NSManagedObjectContext {
        SimplenoteAppDelegate.shared().managedObjectContext
    }

    /// Entity Observer
    ///
    private lazy var observer = EntityObserver(context: mainContext, objects: notes)

    /// ResultsController: In charge of CoreData Queries!
    ///
    private lazy var resultsController = ResultsController<Note>(viewContext: mainContext, sortedBy: [
        NSSortDescriptor(keyPath: \Note.content, ascending: true)
    ])

    /// Rows to be rendered
    ///
    private var rows = [Row]()


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    init(notes: [Note]) {
        self.notes = notes
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEntityObserver()
        setupResultsControllerIfNeeded()
        startListeningToNotifications()
        refreshInterface()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        refreshStyle()
    }
}


// MARK: - Private
//
private extension MetricsViewController {

    func setupEntityObserver() {
        observer.delegate = self
    }

    func setupResultsControllerIfNeeded() {
        guard mustSetupResultsController, let plainInterlink = notes.first?.plainInterlink else {
            return
        }

        resultsController.predicate = NSPredicate.predicateForNotes(exactMatch: plainInterlink)
        try? resultsController.performFetch()
    }

    var mustSetupResultsController: Bool {
        notes.count == 1
    }
}


// MARK: - Enclosing Popover: Customize!
//
extension MetricsViewController: NSPopoverDelegate {

    public func popoverWillShow(_ notification: Notification) {
        presentingPopover = notification.object as? NSPopover
    }
}


// MARK: - Theme Support
//
private extension MetricsViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func refreshStyle() {
        // Note: Backwards compatibility *requires* this line (10.13 / 10.14)
        presentingPopover?.appearance = .simplenoteAppearance
    }
}


// MARK: - EntityObserverDelegate
//
extension MetricsViewController: EntityObserverDelegate {

    func entityObserver(_ observer: EntityObserver, didObserveChanges for: Set<NSManagedObjectID>) {
        refreshInterface()
    }
}


// MARK: - Refreshing!
//
private extension MetricsViewController {

    func refreshInterface() {
        rows = metricRows(for: notes) + referenceRows(from: resultsController.fetchedObjects)
        tableView.reloadData()

    }

    func metricRows(for notes: [Note]) -> [Row] {
        let metrics = NoteMetrics(notes: notes)
        return [
            .header(text: NSLocalizedString("Information", comment: "Note Metrics Title")),
            .metric(title: NSLocalizedString("Modified", comment: "Note Modification Date"),
                    value: metrics.modifiedDate),

            .metric(title: NSLocalizedString("Created", comment: "Note Creation Date"),
                    value: metrics.creationDate),

            .metric(title: NSLocalizedString("Words", comment: "Number of words in the note"),
                    value: String(metrics.numberOfWords)),

            .metric(title: NSLocalizedString("Characters", comment: "Number of characters in the note"),
                    value: String(metrics.numberOfChars))
        ]
    }

    func referenceRows(from notes: [Note]) -> [Row] {
        if notes.isEmpty {
            return []
        }

        var rows: [Row] = [ .header(text: NSLocalizedString("References", comment: "References Title")) ]
        for note in notes {
            rows += .reference(note: note)
        }

        return rows
    }
}


// MARK: - NSTableViewDataSource
//
extension MetricsViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        rows.count
    }
}


// MARK: - NSTableViewDelegate
//
extension MetricsViewController: NSTableViewDelegate {

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return TableRowView()
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return dequeueAndConfigureCell(at: row, in: tableView)
    }
}


// MARK: - Cell Initialization
//
private extension MetricsViewController {

    func dequeueAndConfigureCell(at index: Int, in tableView: NSTableView) -> NSView {
        switch rows[index] {
        case .header(let text):
            return dequeueHeaderCell(from: tableView, text: text)

        case .metric(let title, let value):
            return dequeueMetricCell(from: tableView, title: title, value: value)

        case .reference(let note):
            return dequeueReferenceCell(from: tableView, note: note)
        }
    }

    func dequeueHeaderCell(from tableView: NSTableView, text: String) -> NSView {
        let headerCell = tableView.makeTableViewCell(ofType: HeaderTableCellView.self)
        headerCell.title = text
        return headerCell
    }

    func dequeueMetricCell(from tableView: NSTableView, title: String, value: String?) -> NSView {
        let metricCell = tableView.makeTableViewCell(ofType: MetricTableViewCell.self)
        metricCell.title = title
        metricCell.value = value ?? "-"
        return metricCell
    }

    func dequeueReferenceCell(from tableView: NSTableView, note: Note) -> NSView {
        note.ensurePreviewStringsAreAvailable()

        let referenceCell = tableView.makeTableViewCell(ofType: ReferenceTableViewCell.self)
        referenceCell.title = note.titlePreview
        referenceCell.details = NSLocalizedString("Last modified", comment: "Reference Last Modification Date")
                                    + .space
                                    + DateFormatter.referenceFormatter.string(from: note.modificationDate)

        return referenceCell
    }
}


// MARK: - Private Types
//
private enum Row {
    case header(text: String)
    case metric(title: String, value: String?)
    case reference(note: Note)
}

private func +=(lhs: inout [Row], rhs: Row) {
    lhs.append(rhs)
}
