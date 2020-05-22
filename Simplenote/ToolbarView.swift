import Foundation


// MARK: - ToolbarView
//
@objcMembers
class ToolbarView: NSView {

    /// Internal StackView
    ///
    @IBOutlet private(set) var stackView: NSStackView!

    /// Info Button
    ///
    @IBOutlet private(set) var actionButton: NSButton!

    /// Note History
    ///
    @IBOutlet private(set) var historyButton: NSButton!

    /// Markdown Preview
    ///
    @IBOutlet private(set) var previewButton: NSButton!

    /// Restore Trashed Note
    ///
    @IBOutlet private(set) var restoreButton: NSButton!

    /// Share Contents
    ///
    @IBOutlet private(set) var shareButton: NSButton!

    /// Move to Trash
    ///
    @IBOutlet private(set) var trashButton: NSButton!

    /// Action Menu
    ///
    @IBOutlet private(set) var actionMenu: NSMenu!


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
        actionButton.isEnabled = state.isActionButtonEnabled
        actionButton.isHidden = state.isActionButtonHidden

        historyButton.isEnabled = state.isHistoryActionEnabled
        historyButton.isHidden = state.isHistoryActionHidden

        previewButton.isHidden = state.isPreviewActionHidden
        previewButton.image = state.previewActionImage
        previewButton.tintImage(color: .simplenoteSecondaryActionButtonTintColor)

        restoreButton.isEnabled = state.isRestoreActionEnabled
        restoreButton.isHidden = state.isRestoreActionHidden

        shareButton.isEnabled = state.isShareActionEnabled
        shareButton.isHidden = state.isShareActionHidden

        trashButton.isEnabled = state.isTrashActionEnabled
        trashButton.isHidden = state.isTrashActionHidden
    }
}


// MARK: - Theming
//
private extension ToolbarView {

    var allButtons: [NSButton] {
        [actionButton, historyButton, previewButton, restoreButton, shareButton, trashButton]
    }

    @objc
    func refreshStyle() {
        refreshButtonsStyle()
        refreshActionMenuStyle()
    }

    func refreshButtonsStyle() {
        for button in allButtons {
            button.tintImage(color: .simplenoteSecondaryActionButtonTintColor)
        }
    }

    func refreshActionMenuStyle() {
        guard let actionButtonItem = actionButton.menu?.items.first, let image = actionButtonItem.image else {
            return
        }

        actionButtonItem.image = image.tinted(with: .simplenoteSecondaryActionButtonTintColor)
    }

    func setupSubviews() {
        actionButton.toolTip = NSLocalizedString("Details", comment: "Tooltip: Note Details")
        historyButton.toolTip = NSLocalizedString("History", comment: "Tooltip: History Picker")
        previewButton.toolTip = NSLocalizedString("Markdown Preview", comment: "Tooltip: Markdown Preview")
        restoreButton.toolTip = NSLocalizedString("Restore", comment: "Tooltip: Restore a trashed note")
        shareButton.toolTip = NSLocalizedString("Share", comment: "Tooltip: Share a note")
        trashButton.toolTip = NSLocalizedString("Trash", comment: "Tooltip: Trash a Note")

        let cells = allButtons.compactMap { $0.cell as? NSButtonCell }
        for cell in cells {
            cell.highlightsBy = .pushInCellMask
        }
    }
}
