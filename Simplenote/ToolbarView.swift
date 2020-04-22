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
        startListeningToNotifications()
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

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func noNoteLoaded(_ note: Notification) {
        updateAllButtons(enabled: false)
    }

    @objc
    func noteLoaded(_ note: Notification) {
        updateAllButtons(enabled: true)
    }

    @objc
    func trashDidLoad(_ note: Notification) {
        updateButtons(trashOnScreen: true)
    }

    @objc
    func tagsDidLoad(_ note: Notification) {
        updateButtons(trashOnScreen: false)
    }

    @objc
    func trashDidEmpty(_ note: Notification) {
        updateAllButtons(enabled: false)
    }
}


// MARK: - Initialization
//
private extension ToolbarView {

    func setupSubviews() {
        for case let subview as NSButton in stackView.subviews {
            subview.tintImage(color: .simplenoteActionButtonTintColor)
        }
    }

    func updateAllButtons(enabled: Bool) {
        for case let subview as NSButton in stackView.subviews {
            subview.isEnabled = enabled
        }
    }

    func updateButtons(trashOnScreen: Bool) {
    }
}
