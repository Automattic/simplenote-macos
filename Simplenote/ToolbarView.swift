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
    var isDisplayingNote = false {
        didSet {
            guard oldValue != isDisplayingNote else {
                return
            }

            needsDisplay = true
        }
    }

    ///
    ///
    var isDisplayingMarkdown = false {
        didSet {
            guard oldValue != isDisplayingMarkdown else {
                return
            }

            refreshPreviewImage()
            needsDisplay = true
        }
    }

    /// Indicates if the Markdown Action is to be Enabled
    ///
    var isMarkdownEnabled = false {
        didSet {
            guard oldValue != isMarkdownEnabled else {
                return
            }

            needsDisplay = true
        }
    }

    ///
    ///
    var isSelectingMultipleNotes = false {
        didSet {
            guard oldValue != isSelectingMultipleNotes else {
                return
            }

            needsDisplay = true
        }
    }

    ///
    ///
    var isShareEnabled = false {
        didSet {
            guard oldValue != isShareEnabled else {
                return
            }

            needsDisplay = true
        }
    }

    ///
    ///
    var isViewingTrash = false {
        didSet {
            guard oldValue != isViewingTrash else {
                return
            }

            needsDisplay = true
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

    override func viewWillDraw() {
        super.viewWillDraw()
        refreshInterface()
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
        actionButton.isEnabled = (isDisplayingNote || isSelectingMultipleNotes) && !isViewingTrash

        historyButton.isEnabled = isDisplayingNote && !isDisplayingMarkdown
        historyButton.isHidden = isViewingTrash

        previewButton.isHidden = !isMarkdownEnabled

        restoreButton.isEnabled = isDisplayingNote
        restoreButton.isHidden = !isViewingTrash

        shareButton.isEnabled = isShareEnabled
        shareButton.isHidden = isViewingTrash

        trashButton.isEnabled = isDisplayingNote
        trashButton.isHidden = isViewingTrash
    }

    func refreshPreviewImage() {
        let name: NSImage.Name = isDisplayingMarkdown ? .previewOn : .previewOff

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
