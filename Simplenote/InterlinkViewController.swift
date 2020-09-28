import Foundation
import AppKit


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

    /// Notes to be rendered
    ///
    var notes: [Note] = [] {
        didSet {
            refreshInterface()
        }
    }


    // MARK: - Overridden Methdos

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupMouseCursor()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.pointingHand.set()
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
        tableView.addCursorRect(tableView.bounds, cursor: .pointingHand)
    }

    func refreshInterface() {
        tableView.reloadData()
    }

    func note(at row: Int) -> Note {
        notes[row]
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
extension InterlinkViewController: NSTableViewDelegate {

    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRowView()
        rowView.selectedBackgroundColor = .simplenoteSelectedBackgroundColor
        return rowView
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let note = self.note(at: row)
        note.ensurePreviewStringsAreAvailable()

        let tableViewCell = tableView.makeTableViewCell(ofType: LinkTableCellView.self)
        tableViewCell.title = note.titlePreview
        return tableViewCell
    }
}
