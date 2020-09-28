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


    // MARK: - Overridden Methdos

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupMouseCursor()
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

    func setupBackground() {
        backgroundView.fillColor = .simplenoteBackgroundColor
        tableView.backgroundColor = .clear
    }

    func setupMouseCursor() {
        view.addTrackingArea(trackingArea)
    }
}


// MARK: - NSTableViewDataSource
//
extension InterlinkViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        // TODO: Drop this placeholder!
        return 5
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
        let tableViewCell = tableView.makeTableViewCell(ofType: LinkTableCellView.self)

        // TODO: Drop this placeholder!
        tableViewCell.title = "Placeholder!"
        return tableViewCell
    }
}
