import Foundation
import AppKit

// MARK: - InterlinkViewController
//
class InterlinkViewController: NSViewController {

    /// Interface Outlets
    ///
    @IBOutlet private var backgroundView: BackgroundView!
    @IBOutlet private var tableView: NSTableView!

    /// Mouse Tracking
    ///
    private lazy var trackingArea = NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)

    /// Interlink Notes to be presented onScreen
    ///
    var notes = [Note]() {
        didSet {
            tableView?.reloadData()
        }
    }

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStyle()
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

// MARK: - Setup!
//
private extension InterlinkViewController {

    func setupRoundedCorners() {
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = Settings.cornerRadius
    }

    func setupTableView() {
        tableView.becomeFirstResponder()
        tableView.target = self
        tableView.doubleAction = #selector(performInterlinkInsert)

        tableView.ensureStyleIsFullWidth()
    }

    func setupTrackingAreas() {
        view.addTrackingArea(trackingArea)
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
}
