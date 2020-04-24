import Foundation


// MARK: - ToolbarView
//
class ToolbarView: NSView {

    /// Internal StackView
    ///
    @IBOutlet private var stackView: NSStackView!

    /// Info Button
    ///
    @IBOutlet var actionButton: NSPopUpButton!

    /// Note History
    ///
    @IBOutlet var historyButton: NSButton!

    /// Markdown Preview
    ///
    @IBOutlet var previewButton: NSButton!

    /// Restore Trashed Note
    ///
    @IBOutlet var restoreButton: NSButton!

    /// Share Contents
    ///
    @IBOutlet var shareButton: NSButton!

    /// Move to Trash
    ///
    @IBOutlet var trashButton: NSButton!


    // MARK: - Overridden

    deinit {
        stopListeningToNotifications()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubviews()
        refreshStyle()
        startListeningToNotifications()
        startListeningToThemeNotificationsIfNeeded()
    }
}


// MARK: - Notifications
//
private extension ToolbarView {

    func startListeningToNotifications() {
        let nc = NotificationCenter.default

        nc.addObserver(self, selector: #selector(noNoteLoaded), name: NSNotification.Name(rawValue: SPNoNoteLoadedNotificationName), object: nil)
        nc.addObserver(self, selector: #selector(noteLoaded), name: NSNotification.Name(rawValue: SPNoteLoadedNotificationName), object: nil)
        nc.addObserver(self, selector: #selector(trashDidLoad), name: NSNotification.Name(rawValue: kDidBeginViewingTrash), object: nil)
        nc.addObserver(self, selector: #selector(tagsDidLoad), name: NSNotification.Name(rawValue: kTagsDidLoad), object: nil)
        nc.addObserver(self, selector: #selector(trashDidEmpty), name: NSNotification.Name(rawValue: kDidEmptyTrash), object: nil)
    }

    func startListeningToThemeNotificationsIfNeeded() {
        if #available(macOS 10.15, *) {
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func noNoteLoaded(_ note: Notification) {
        refreshButtons(enabled: false)
    }

    @objc
    func noteLoaded(_ note: Notification) {
        refreshButtons(enabled: true)
    }

    @objc
    func trashDidLoad(_ note: Notification) {
        refreshButtons(trashOnScreen: true)
    }

    @objc
    func tagsDidLoad(_ note: Notification) {
        refreshButtons(trashOnScreen: false)
    }

    @objc
    func trashDidEmpty(_ note: Notification) {
        refreshButtons(enabled: false)
    }
}


// MARK: - Initialization
//
private extension ToolbarView {

    var allButtons: [NSButton] {
        return [actionButton, historyButton, previewButton, restoreButton, shareButton, trashButton]
    }

    @objc
    func refreshStyle() {
        for button in allButtons {
            button.tintImage(color: .simplenoteActionButtonTintColor)
        }
    }

    func refreshButtons(enabled: Bool) {
        for button in allButtons {
            button.isEnabled = enabled
        }
    }

    func refreshButtons(trashOnScreen: Bool) {
        actionButton.isEnabled = !trashOnScreen
        historyButton.isHidden = trashOnScreen
        restoreButton.isHidden = !trashOnScreen
        shareButton.isHidden = trashOnScreen
        trashButton.isHidden = trashOnScreen
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
