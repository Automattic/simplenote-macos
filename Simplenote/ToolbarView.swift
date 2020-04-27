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

    ///
    ///
    var displayingNote = false {
        didSet {
            guard oldValue != displayingNote else {
                return
            }

            refreshInterface()
        }
    }

    ///
    ///
    var displayingMarkdown = false {
        didSet {
            guard oldValue != displayingMarkdown else {
                return
            }

            refreshPreviewImage()
            refreshInterface()
        }
    }

    ///
    ///
    var displayingTrash = false {
        didSet {
            guard oldValue != displayingTrash else {
                return
            }

            refreshInterface()
        }
    }

    ///
    ///
    var isMarkdownAllowed = false {
        didSet {
            guard oldValue != isMarkdownAllowed else {
                return
            }

            refreshInterface()
        }
    }

    ///
    ///
    var isShareAllowed = false {
        didSet {
            guard oldValue != isShareAllowed else {
                return
            }

            refreshInterface()
        }
    }

    ///
    ///
    var multipleSelection = false {
        didSet {
            guard oldValue != multipleSelection else {
                return
            }

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
        actionButton.isEnabled = (displayingNote || multipleSelection) && !displayingTrash

        historyButton.isEnabled = displayingNote && !displayingMarkdown
        historyButton.isHidden = displayingTrash

        previewButton.isEnabled = displayingNote
        previewButton.isHidden = !isMarkdownAllowed || displayingTrash

        restoreButton.isEnabled = displayingNote
        restoreButton.isHidden = !displayingTrash

        shareButton.isEnabled = isShareAllowed && displayingNote
        shareButton.isHidden = displayingTrash

        trashButton.isEnabled = displayingNote
        trashButton.isHidden = displayingTrash
    }

    func refreshPreviewImage() {
        let name: NSImage.Name = displayingMarkdown ? .previewOn : .previewOff

        previewButton.image = NSImage(named: name)
        previewButton.tintImage(color: .simplenoteActionButtonTintColor)
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
