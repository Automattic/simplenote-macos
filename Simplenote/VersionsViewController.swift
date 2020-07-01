import Foundation
import AppKit


// MARK: - VersionsViewControllerDelegate
//
protocol VersionsViewControllerDelegate: class {
    func versionsController(_ controller: VersionsViewController, selected version: NoteVersion)
    func versionsControllerDidClickRestore(_ controller: VersionsViewController)
    func versionsControllerWillShow(_ controller: VersionsViewController)
    func versionsControllerWillClose(_ controller: VersionsViewController)
}


// MARK: - VersionsViewController
//
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

    /// Note for which we'll allow History Sliding
    ///
    private let note: Note

    /// Versions associated to the current Note
    ///
    private var versions = [String: NoteVersion]()

    /// VersionsController Observer Receipt
    ///
    private var versionsToken: Any!

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


    // MARK: - Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlider()
        setupLabels()
        requestVersions()
        startListeningToNotifications()
    }
}


// MARK: - Initialization
//
private extension VersionsViewController {

    func setupSlider() {
        let maximum = Int(note.version()) ?? .zero
        let minimum = max(maximum - Settings.numberOfVersions, 1)

        versionSlider.maxValue = Double(maximum)
        versionSlider.minValue = Double(minimum)
        versionSlider.numberOfTickMarks = maximum - minimum + 1
        versionSlider.integerValue = maximum
    }

    func setupLabels() {
        refreshLabels(date: note.modificationDate)
    }
}


// MARK: - Notifications
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

    func popoverWillShow(_ notification: Notification) {
        presentingPopover = notification.object as? NSPopover
        delegate?.versionsControllerWillShow(self)
    }

    func popoverWillClose(_ notification: Notification) {
        delegate?.versionsControllerWillClose(self)
    }
}


// MARK: - Actions
//
extension VersionsViewController {

    @IBAction
    func restoreWasPressed(sender: Any) {
        delegate?.versionsControllerDidClickRestore(self)
    }

    @IBAction
    func versionSliderChanged(sender: Any) {
        guard let version = versions[String(versionSlider.integerValue)] else {
            disableActions()
            return
        }

        NSLog("<> Loading version \(versionSlider.integerValue)");
        refreshLabels(date: version.modificationDate)
        refreshActions()

        delegate?.versionsController(self, selected: version)
    }
}


// MARK: - Helpers
//
private extension VersionsViewController {

    func refreshLabels(date: Date) {
        let text = NSLocalizedString("Version", comment: "Label for the current version of a note")
        let date = DateFormatter.historyFormatter.string(from: date)

        versionTextField.stringValue = "\(text): \(date)"
    }

    func refreshActions() {
        restoreButton.isEnabled = versionSlider.integerValue != Int(versionSlider.maxValue)
    }

    func disableActions() {
        restoreButton.isEnabled = false
    }
}


// MARK: - Simperium
//
private extension VersionsViewController {

    func requestVersions() {
        versionsToken = VersionsController.shared.requestVersions(for: note.simperiumKey, numberOfVersions: Settings.numberOfVersions) { [weak self] note in
            self?.versions[note.version] = note
        }
    }
}


// MARK: - Settings
//
private enum Settings {
    static let numberOfVersions = Int(30)
}
