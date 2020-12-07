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
    @IBOutlet private(set) var searchButton: NSButton!

    /// Search Field
    ///
    @IBOutlet private(set) var searchField: NSSearchField!

    /// Layout Constraints
    ///
    @IBOutlet private(set) var searchWidthConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var searchHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) var searchFieldWidthConstraint: NSLayoutConstraint!

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
        setupSubviews()
        setupInitialSearchState()
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
    }

    func setupSubviews() {
        metricsButton.toolTip = NSLocalizedString("Metrics", comment: "Tooltip: Note Metrics")
        moreButton.toolTip = NSLocalizedString("More", comment: "Tooltip: More Actions")
        previewButton.toolTip = NSLocalizedString("Markdown Preview", comment: "Tooltip: Markdown Preview")
        restoreButton.toolTip = NSLocalizedString("Restore", comment: "Tooltip: Restore a trashed note")
        sidebarButton.toolTip = NSLocalizedString("Toggle Sidebar", comment: "Tooltip: Restore a trashed note")
        searchButton.toolTip =  NSLocalizedString("Search", comment: "Tooltip: Search Action")

        let cells = allButtons.compactMap { $0.cell as? NSButtonCell }
        for cell in cells {
            cell.highlightsBy = .pushInCellMask
        }
    }

    func setupInitialSearchState() {
        searchFieldWidthConstraint.constant = .zero
    }
}


// MARK: - Actions
//
extension ToolbarView {

    @IBAction
    func searchWasPressed(_ sender: Any) {
        updateSearchBar(visible: true)
    }
}


// MARK: - Search Bar State Management
//
private extension ToolbarView {

    var isSearchBarVisible: Bool {
        searchFieldWidthConstraint.constant != 0
    }

    func updateSearchBar(visible: Bool) {
        let newBarAlpha     = visible ? AppKitConstants.alpha1_0 : AppKitConstants.alpha0_0
        let newBarWidth     = visible ? Metrics.searchBarSize.width : .zero
        let newButtonSize   = visible ? .zero : Metrics.buttonSize
        let newButtonAlpha  = visible ? AppKitConstants.alpha0_0 : AppKitConstants.alpha1_0

        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            context.duration = AppKitConstants.duration0_2

            searchWidthConstraint.animator().constant       = newButtonSize.width
            searchHeightConstraint.animator().constant      = newButtonSize.height
            searchFieldWidthConstraint.animator().constant  = newBarWidth

            searchButton.animator().alphaValue = newButtonAlpha
            searchField.animator().alphaValue  = newBarAlpha

            layoutSubtreeIfNeeded()

        } completionHandler: {
            self.searchField.becomeFirstResponder()
        }
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let buttonSize = CGSize(width: 22, height: 22)
    static let searchBarSize = CGSize(width: 222, height: 29)
}
