import Foundation


// MARK: - ToolbarDelegate
//
protocol ToolbarDelegate: NSObject {
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
        previewButton.contentTintColor = .simplenoteActionButtonTintColor

        restoreButton.isEnabled = state.isRestoreActionEnabled
        restoreButton.isHidden = state.isRestoreActionHidden

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
            button.contentTintColor = .simplenoteActionButtonTintColor
        }

        searchField.textColor = .simplenoteTextColor
        searchField.placeholderAttributedString = Settings.searchBarPlaceholder
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

    /// Enters Search Mode whenever the current Toolbar State allows
    ///
    func beginSearch() {
        if state.isSearchActionHidden {
            return
        }

        /// **Workaround:**  We're getting spurious `controlTextDidEndEditing` callbacks, which may yield to really uncool animation glitches.
        dismissSearchBarOnEndEditing = false

        /// Ensure the SearchBar is visible + Move the focus
        updateSearchBarIfNeeded(visible: true) {

            /// Note: Not waiting for the Animation's completion causes rendering issues in macOS < 11
            self.window?.makeFirstResponder(self.searchField)

            /// **Workaround:** Back to normal please
            self.dismissSearchBarOnEndEditing = true
        }
    }

    /// Ends Search whenever the SearchBar was actually visible
    ///
    func endSearch() {
        guard isSearchBarVisible else {
            return
        }

        searchField.cancelSearch()
        searchField.resignFirstResponder()
        updateSearchBarIfNeeded(visible: false)
    }
}


// MARK: - NSSearchFieldDelegate
//
extension ToolbarView: NSSearchFieldDelegate {

    public func controlTextDidEndEditing(_ obj: Notification) {
        guard dismissSearchBarOnEndEditing, searchField.stringValue.isEmpty else {
            return
        }

        updateSearchBarIfNeeded(visible: false)
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

    func updateSearchBarIfNeeded(visible: Bool, completionHandler: (() -> Void)? = nil) {
        guard isSearchBarVisible != visible else {
            completionHandler?()
            return
        }

        updateSearchBar(visible: visible, completionHandler: completionHandler)
    }

    func updateSearchBar(visible: Bool, completionHandler: (() -> Void)? = nil) {
        let newBarWidth     = visible ? Settings.searchBarFullWidth : .zero
        let newButtonAlpha  = visible ? AppKitConstants.alpha0_0 : AppKitConstants.alpha1_0

        let delayForAlpha   = visible ? AppKitConstants.delay0_0 : AppKitConstants.delay0_15
        let delayForResize  = visible ? AppKitConstants.delay0_15 : AppKitConstants.delay0_0

        searchButton.isHidden = false

        /// Phase #1: Fade In / Out the Search Action Button
        ///
        NSAnimationContext.runAnimationGroup(after: delayForAlpha) { context in
            context.duration = AppKitConstants.duration0_2
            self.searchButton.animator().alphaValue = newButtonAlpha
        } completionHandler: {
            self.searchButton.isHidden = visible
        }

        /// Phase #2: Resize the SearchBar itself
        ///
        NSAnimationContext.runAnimationGroup(after: delayForResize) { context in
            context.duration = AppKitConstants.duration0_2
            self.searchFieldWidthConstraint.animator().constant = newBarWidth
            self.layoutSubtreeIfNeeded()
        } completionHandler: {
            completionHandler?()
        }
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
