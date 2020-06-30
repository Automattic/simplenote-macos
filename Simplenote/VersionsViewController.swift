import Foundation


// MARK: - VersionsViewControllerDelegate
//
@objc
protocol VersionsViewControllerDelegate {
    func versionsController(_ controller: VersionsViewController, updatedSlider newValue: Int)
    func versionsControllerDidClickRestore(_ controller: VersionsViewController)
    func versionsControllerWillShow(_ controller: VersionsViewController)
    func versionsControllerWillClose(_ controller: VersionsViewController)
}


// MARK: - VersionsViewController
//
@objcMembers
class VersionsViewController: NSViewController {

    /// Restore Clickable Button
    ///
    @IBOutlet private var restoreButton: NSButton!

    /// Versions Slider!
    ///
    @IBOutlet private var versionSlider: NSSlider!

    /// Versions Text
    ///
    @IBOutlet private var versionTextField: NSTextField!

    /// NSPopover instance that's presenting the current instance.
    ///
    private var presentingPopover: NSPopover? {
        didSet {
            refreshStyle()
        }
    }

    /// Old School delegate
    ///
    weak var delegate: VersionsViewControllerDelegate?

    /// Returns the Maximum Slider Value
    ///
    var maxSliderValue: Int {
        Int(versionSlider.maxValue)
    }

    /// Encapsulates the Restore Button's `isEnabled` property
    ///
    var restoreActionEnabled: Bool {
        get {
            restoreButton.isEnabled
        }
        set {
            restoreButton.isEnabled = newValue
        }
    }

    /// Encapsulates the versionTextField's `stringValue` property
    ///
    var versionText: String {
        get {
            versionTextField.stringValue
        }
        set {
            versionTextField.stringValue = newValue
        }
    }


    // MARK: - View Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        refreshStyle()
    }

    /// Refreshes the Slider Settings with the specified Max / Min
    ///
    func refreshSlider(max: Int, min: Int) {
        versionSlider.maxValue = Double(max)
        versionSlider.minValue = Double(min)
        versionSlider.numberOfTickMarks = max - min + 1
        versionSlider.integerValue = max
    }
}


// MARK: - Private
//
private extension VersionsViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    @objc
    func refreshStyle() {
        presentingPopover?.appearance = .simplenoteAppearance
        versionTextField.textColor = .simplenoteTextColor
    }
}


// MARK: - NSPopoverDelegate
//
extension VersionsViewController: NSPopoverDelegate {

    public func popoverWillShow(_ notification: Notification) {
        presentingPopover = notification.object as? NSPopover
        delegate?.versionsControllerWillShow(self)
    }

    func popoverWillClose(_ notification: Notification) {
        delegate?.versionsControllerWillClose(self)
    }
}


// MARK: - Handlers
//
extension VersionsViewController {

    @IBAction
    func restoreWasPressed(sender: Any) {
        delegate?.versionsControllerDidClickRestore(self)
    }

    @IBAction
    func versionSliderChanged(sender: Any) {
        delegate?.versionsController(self, updatedSlider: versionSlider.integerValue)
    }
}
