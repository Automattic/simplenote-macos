import Foundation


// MARK: - ToolbarDelegate
//
protocol ToolbarDelegate: NSObject {
    func toolbarDidBeginSearch(_ toolbar: ToolbarView)
    func toolbarDidEndSearch(_ toolbar: ToolbarView)
    func toolbar(_ toolbar: ToolbarView, didSearch keyword: String)
}


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
    @IBOutlet private(set) var searchButton: NSButton!

    /// Search Container
    ///
    @IBOutlet private(set) var searchContainerView: NSView!

    /// Search Field
    ///
    @IBOutlet private(set) var searchField: NSSearchField!

    /// Layout Constraints
    ///
    @IBOutlet private(set) var searchButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var searchButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var searchFieldWidthConstraint: NSLayoutConstraint!

    /// Toolbar Delegate
    ///
    weak var delegate: ToolbarDelegate?

    /// Indicates if the Search Mode should be dismissed whenever the SearchBar stops being First Responder  (and there is no Search Keyword!)
    ///
    var dismissSearchBarOnEndEditing = true

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
        setupLayoutConstraintsForInitialState()
        setupSearchField()
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
        previewButton.contentTintColor = .simplenoteSecondaryActionButtonTintColor

        restoreButton.isEnabled = state.isRestoreActionEnabled
        restoreButton.isHidden = state.isRestoreActionHidden

        searchButton.isEnabled = state.isSearchActionEnabled
        searchContainerView.isHidden = state.isSearchActionHidden
    }
}


// MARK: - Theming
//
private extension ToolbarView {

    var allButtons: [NSButton] {
        [sidebarButton, metricsButton, moreButton, previewButton, restoreButton, searchButton]
    }

    @objc
    func refreshStyle() {
        for button in allButtons {
            button.contentTintColor = .simplenoteSecondaryActionButtonTintColor
        }

        searchField.textColor = .simplenoteTextColor
        searchField.placeholderAttributedString = Placeholders.searchString
    }

    func setupActionButtons() {
        metricsButton.toolTip = NSLocalizedString("Metrics", comment: "Tooltip: Note Metrics")
        moreButton.toolTip = NSLocalizedString("More", comment: "Tooltip: More Actions")
        previewButton.toolTip = NSLocalizedString("Markdown Preview", comment: "Tooltip: Markdown Preview")
        restoreButton.toolTip = NSLocalizedString("Restore", comment: "Tooltip: Restore a trashed note")
        searchButton.toolTip =  NSLocalizedString("Search", comment: "Tooltip: Search Action")
        sidebarButton.toolTip = NSLocalizedString("Toggle Sidebar", comment: "Tooltip: Restore a trashed note")

        let cells = allButtons.compactMap { $0.cell as? NSButtonCell }
        for cell in cells {
            cell.highlightsBy = .pushInCellMask
        }
    }

    func setupLayoutConstraintsForInitialState() {
        searchFieldWidthConstraint.constant = .zero
    }

    func setupSearchField() {
        searchField.centersPlaceholder = false
    }
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

    func beginSearch() {
        refreshLayoutIfNeeded(displaySearchBar: true)
        window?.makeFirstResponder(searchField)
    }

    func endSearch() {
        searchField.cancelSearch()
        searchField.resignFirstResponder()
        refreshLayoutIfNeeded(displaySearchBar: false)
    }

    func endSearchIfNeeded() {
        guard isSearchBarVisible else {
            return
        }

        endSearch()
    }
}


// MARK: - NSSearchFieldDelegate
//
extension ToolbarView: NSSearchFieldDelegate {

    public func controlTextDidBeginEditing(_ obj: Notification) {
        delegate?.toolbarDidBeginSearch(self)
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        guard dismissSearchBarOnEndEditing else {
            return
        }

        dismissSearchBarIfNeeded()
        delegate?.toolbarDidEndSearch(self)

    }

    @IBAction
    public func performSearch(_ sender: Any) {
        delegate?.toolbar(self, didSearch: searchField.stringValue)
    }
}


// MARK: - Search Bar State Management
//
private extension ToolbarView {

    var isSearchBarVisible: Bool {
        searchFieldWidthConstraint.constant != 0
    }

    func dismissSearchBarIfNeeded() {
        guard searchField.stringValue.isEmpty else {
            return
        }

        refreshLayoutIfNeeded(displaySearchBar: false)
    }

    func refreshLayoutIfNeeded(displaySearchBar: Bool) {
        guard isSearchBarVisible != displaySearchBar else {
            return
        }

        let newBarWidth     = displaySearchBar ? Metrics.searchBarSize.width : .zero
        let newButtonSize   = displaySearchBar ? .zero : Metrics.buttonSize
        let newButtonAlpha  = displaySearchBar ? AppKitConstants.alpha0_0 : AppKitConstants.alpha1_0

        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            context.duration = AppKitConstants.duration0_2

            searchButtonWidthConstraint.animator().constant     = newButtonSize.width
            searchButtonHeightConstraint.animator().constant    = newButtonSize.height
            searchFieldWidthConstraint.animator().constant      = newBarWidth
            searchButton.animator().alphaValue = newButtonAlpha

            layoutSubtreeIfNeeded()
        }
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let buttonSize = CGSize(width: 22, height: 22)
    static let searchBarSize = CGSize(width: 222, height: 29)
}


// MARK: - Settings
//
private enum Placeholders {
    static var searchString: NSAttributedString {
        NSAttributedString(string: NSLocalizedString("Search", comment: "Search Field Placeholder"), attributes: [
            .foregroundColor: NSColor.simplenoteSecondaryTextColor,
            .font: NSFont.simplenoteSecondaryTextFont
        ])
    }
}
