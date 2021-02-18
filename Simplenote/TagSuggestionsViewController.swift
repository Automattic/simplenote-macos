import Foundation
import AppKit
import SimplenoteSearch


// MARK: - TagSuggestionsViewController
//
class TagSuggestionsViewController: NSViewController {

    /// Interface Outlets
    ///
    @IBOutlet private var backgroundView: BackgroundView!
    @IBOutlet private var tableView: NSTableView!

    /// Mouse Tracking
    ///
    private lazy var trackingArea = NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)

    /// Interlink Notes to be presented onScreen
    ///
    var tags = [Tag]() {
        didSet {
            tableView?.reloadData()
        }
    }

    /// Closure to be executed whenever a Tag is selected
    ///
    var onTagSelection: ((Tag) -> Void)?


    // MARK: - Overridden Methods

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
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
private extension TagSuggestionsViewController {

    func setupRoundedCorners() {
        guard #available(macOS 10.15, *) else {
            return
        }

        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = Metrics.cornerRadius
    }

    func setupTableView() {
        tableView.becomeFirstResponder()
        tableView.target = self
        tableView.doubleAction = #selector(tagWasSelected)
        tableView.ensureStyleIsFullWidth()
    }

    func setupTrackingAreas() {
        view.addTrackingArea(trackingArea)
    }

    @objc
    func refreshStyle() {
        backgroundView.fillColor = .simplenoteBackgroundColor
        tableView.backgroundColor = .clear
        tableView.reloadAndPreserveSelection()
    }
}


// MARK: - Action Handlers
//
extension TagSuggestionsViewController {

    @objc
    func tagWasSelected() {
        let tag = tagAtRow(tableView.selectedRow)
        onTagSelection?(tag)
    }
}


// MARK: - Notifications
//
private extension TagSuggestionsViewController {

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


// MARK: - Wrappers
//
private extension TagSuggestionsViewController {

    func tagAtRow(_ row: Int) -> Tag {
        tags[row]
    }
}


// MARK: - NSTableViewDataSource
//
extension TagSuggestionsViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        tags.count
    }
}


// MARK: - NSTableViewDelegate
//
extension TagSuggestionsViewController: SPTableViewDelegate {

    public func tableView(_ tableView: NSTableView, didReceiveKeyDownEvent event: NSEvent) -> Bool {
        guard case NSEvent.SpecialKey.carriageReturn = event.specialKey else {
            return false
        }

        tagWasSelected()
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
        let tag = tagAtRow(row)
        let tableViewCell = tableView.makeTableViewCell(ofType: LinkTableCellView.self)
        tableViewCell.title = SearchQuerySettings.default.tagsKeyword + tag.name

        return tableViewCell
    }
}


// MARK: - Metrics!
//
private enum Metrics {
    static let cornerRadius = CGFloat(6)
}
