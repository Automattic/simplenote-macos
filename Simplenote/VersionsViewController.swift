import Foundation


// MARK: - VersionsViewControllerDelegate
//
@objc
protocol VersionsViewControllerDelegate {
    func versionsController(_ controller: VersionsViewController, updatedSlider newValue: Int)
    func versionsControllerDidClickRestore(_ controller: VersionsViewController)
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
        applyStyle()
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
        NotificationCenter.default.addObserver(self, selector: #selector(applyStyle), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    @objc
    func applyStyle() {
        let theme = VSThemeManager.shared().theme()
        versionTextField.textColor = theme.color(forKey: "popoverTextColor")
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
