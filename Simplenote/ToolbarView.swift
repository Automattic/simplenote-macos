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
    @IBOutlet private(set) var actionButton: NSPopUpButton!

    /// Info Wrapper: NSPopUpButton is allocating extra width, due to its inner menu. Violent hack to normalize width(s)
    ///
    @IBOutlet private(set) var actionWrapperView: NSView!

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

        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Initialization
//
private extension ToolbarView {

    func refreshInterface() {
        actionButton.isEnabled = state.isActionButtonEnabled
        actionWrapperView.isHidden = state.isActionButtonHidden

        historyButton.isEnabled = state.isHistoryActionEnabled
        historyButton.isHidden = state.isHistoryActionHidden

        previewButton.isHidden = state.isPreviewActionHidden
        previewButton.image = state.previewActionImage
        previewButton.tintImage(color: .simplenoteActionButtonTintColor)

        restoreButton.isEnabled = state.isRestoreActionEnabled
        restoreButton.isHidden = state.isRestoreActionHidden

        shareButton.isEnabled = state.isShareActionEnabled
        shareButton.isHidden = state.isShareActionHidden

        trashButton.isEnabled = state.isTrashActionEnabled
        trashButton.isHidden = state.isTrashActionHidden
    }

    @objc
    func refreshStyle() {
        let buttons: [NSButton] = [actionButton, historyButton, previewButton, restoreButton, shareButton, trashButton]

        for button in buttons {
            button.tintImage(color: .simplenoteActionButtonTintColor)
        }
    }

    func setupSubviews() {
        actionButton.toolTip = NSLocalizedString("Details", comment: "Tooltip: Note Details")
        historyButton.toolTip = NSLocalizedString("History", comment: "Tooltip: History Picker")
        previewButton.toolTip = NSLocalizedString("Markdown Preview", comment: "Tooltip: Markdown Preview")
        restoreButton.toolTip = NSLocalizedString("Restore", comment: "Tooltip: Restore a trashed note")
        shareButton.toolTip = NSLocalizedString("Share", comment: "Tooltip: Share a note")
        trashButton.toolTip = NSLocalizedString("Trash", comment: "Tooltip: Trash a Note")
    }
}
