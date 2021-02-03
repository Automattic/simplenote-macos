import Foundation


// MARK: - ToolbarView
//
@objcMembers
class ToolbarView: NSView {

    /// Internal StackView
    ///
    @IBOutlet private(set) var stackView: NSStackView!

    /// Buttons
    ///
    @IBOutlet private(set) var sidebarButton: NSButton!
    @IBOutlet private(set) var metricsButton: NSButton!
    @IBOutlet private(set) var moreButton: NSButton!
    @IBOutlet private(set) var previewButton: NSButton!
    @IBOutlet private(set) var restoreButton: NSButton!

    /// Search Field
    ///
//    @IBOutlet private(set) var searchField: NSSearchField!

    /// Represents the Toolbar's State
    ///
    var state: ToolbarState  = .default {
        didSet {
            refreshInterface()
        }
    }


    // MARK: - Overridden

    deinit {
        stopListeningToNotifications()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupActionButtons()
//        setupSearchField()
        refreshStyle()
        startListeningToNotifications()
    }
}


// MARK: - Notifications
//
private extension ToolbarView {

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


// MARK: - State Management
//
private extension ToolbarView {

    func refreshInterface() {
        metricsButton.isEnabled = state.isMetricsButtonEnabled
        metricsButton.isHidden = state.isMetricsButtonHidden

        moreButton.isEnabled = state.isMoreButtonEnabled
        moreButton.isHidden = state.isMoreButtonHidden

        previewButton.isHidden = state.isPreviewActionHidden
        previewButton.image = state.previewActionImage
        previewButton.contentTintColor = .simplenoteActionButtonTintColor

        restoreButton.isEnabled = state.isRestoreActionEnabled
        restoreButton.isHidden = state.isRestoreActionHidden
    }
}


// MARK: - Theming
//
private extension ToolbarView {

    var allButtons: [NSButton] {
        [sidebarButton, metricsButton, moreButton, previewButton, restoreButton]
    }

    @objc
    func refreshStyle() {
        for button in allButtons {
            button.contentTintColor = .simplenoteActionButtonTintColor
        }

//        searchField.textColor = .simplenoteTextColor
//        searchField.placeholderAttributedString = Settings.searchBarPlaceholder
    }

    func setupActionButtons() {
        metricsButton.toolTip = NSLocalizedString("Metrics", comment: "Tooltip: Note Metrics")
        moreButton.toolTip = NSLocalizedString("More", comment: "Tooltip: More Actions")
        previewButton.toolTip = NSLocalizedString("Markdown Preview", comment: "Tooltip: Markdown Preview")
        restoreButton.toolTip = NSLocalizedString("Restore", comment: "Tooltip: Restore a trashed note")
        sidebarButton.toolTip = NSLocalizedString("Toggle Sidebar", comment: "Tooltip: Restore a trashed note")

        let cells = allButtons.compactMap { $0.cell as? NSButtonCell }
        for cell in cells {
            cell.highlightsBy = .pushInCellMask
        }
    }

//    func setupSearchField() {
//        searchField.centersPlaceholder = false
//    }
}


// MARK: - Actions
//
extension ToolbarView {

    @IBAction
    func searchWasPressed(_ sender: Any) {
        beginSearch()
    }
}


// MARK: - Search Bar Public API
//
extension ToolbarView {

    /// Enters Search Mode whenever the current Toolbar State allows
    ///
    func beginSearch() {
//        window?.makeFirstResponder(self.searchField)
//        delegate?.toolbarDidBeginSearch()
    }

    /// Ends Search whenever the SearchBar was actually visible
    ///
    func endSearch() {
//        searchField.cancelSearch()
//        searchField.resignFirstResponder()
//        delegate?.toolbarDidEndSearch()
    }
}


// MARK: - NSSearchFieldDelegate
//
extension ToolbarView: NSSearchFieldDelegate {

    public func controlTextDidEndEditing(_ obj: Notification) {
//        delegate?.toolbarDidEndSearch()
    }

    @IBAction
    public func performSearch(_ sender: Any) {
//        delegate?.toolbar(self, didSearch: searchField.stringValue)
    }
}


// MARK: - Settings
//
private enum Settings {
    static let searchBarFullWidth = CGFloat(222)
    static var searchBarPlaceholder: NSAttributedString {
        NSAttributedString(string: NSLocalizedString("Search", comment: "Search Field Placeholder"), attributes: [
            .font: NSFont.simplenoteSecondaryTextFont,
            .foregroundColor: NSColor.simplenoteSecondaryTextColor
        ])
    }
}
