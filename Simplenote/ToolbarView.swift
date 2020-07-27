import Foundation


// MARK: - ToolbarView
//
@objcMembers
class ToolbarView: NSView {

    /// Internal StackView
    ///
    @IBOutlet private(set) var stackView: NSStackView!

    /// Metrics Button
    ///
    @IBOutlet private(set) var metricsButton: NSButton!

    /// More Button
    ///
    @IBOutlet private(set) var moreButton: NSButton!

    /// Markdown Preview
    ///
    @IBOutlet private(set) var previewButton: NSButton!

    /// Restore Trashed Note
    ///
    @IBOutlet private(set) var restoreButton: NSButton!

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
        previewButton.tintImage(color: .simplenoteSecondaryActionButtonTintColor)

        restoreButton.isEnabled = state.isRestoreActionEnabled
        restoreButton.isHidden = state.isRestoreActionHidden
    }
}


// MARK: - Theming
//
private extension ToolbarView {

    var allButtons: [NSButton] {
        [metricsButton, moreButton, previewButton, restoreButton]
    }

    @objc
    func refreshStyle() {
        for button in allButtons {
            button.tintImage(color: .simplenoteSecondaryActionButtonTintColor)
        }
    }

    func setupSubviews() {
        metricsButton.toolTip = NSLocalizedString("Metrics", comment: "Tooltip: Note Metrics")
        moreButton.toolTip = NSLocalizedString("More", comment: "Tooltip: More Actions")
        previewButton.toolTip = NSLocalizedString("Markdown Preview", comment: "Tooltip: Markdown Preview")
        restoreButton.toolTip = NSLocalizedString("Restore", comment: "Tooltip: Restore a trashed note")

        let cells = allButtons.compactMap { $0.cell as? NSButtonCell }
        for cell in cells {
            cell.highlightsBy = .pushInCellMask
        }
    }
}
