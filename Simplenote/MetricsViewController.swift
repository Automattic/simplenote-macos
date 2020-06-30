import Foundation
import AppKit


// MARK: - MetricsViewController
//
class MetricsViewController: NSViewController {

    /// Modified: Left Text / Right Details
    ///
    @IBOutlet private(set) var modifiedTextLabel: NSTextField!
    @IBOutlet private(set) var modifiedDetailsLabel: NSTextField!

    /// Created: Left Text / Right Details
    ///
    @IBOutlet private(set) var createdTextLabel: NSTextField!
    @IBOutlet private(set) var createdDetailsLabel: NSTextField!

    /// Words: Left Text / Right Details
    ///
    @IBOutlet private(set) var wordsTextLabel: NSTextField!
    @IBOutlet private(set) var wordsDetailsLabel: NSTextField!

    /// Characters: Left Text / Right Details
    ///
    @IBOutlet private(set) var charsTextLabel: NSTextField!
    @IBOutlet private(set) var charsDetailsLabel: NSTextField!

    /// NSPopover instance that's presenting the current instance.
    ///
    private var presentingPopover: NSPopover? {
        didSet {
            refreshStyle()
        }
    }

    /// Metrics Controller
    ///
    private let controller = MetricsController()

    /// Date Formatter
    ///
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextLabels()
        startListeningToNotifications()
        startObservingMetricUpdates()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        refreshStyle()
        refreshMetrics()
    }

    func displayMetrics(for notes: [Note]) {
        // Ensure the view is Loaded: we want the NSViewController.view to acquire its final size *synchronously*
        loadViewIfNeeded()
        controller.startReportingMetrics(for: notes)
    }
}


// MARK: - Private
//
private extension MetricsViewController {

    func setupTextLabels() {
        modifiedTextLabel.stringValue = NSLocalizedString("Modified", comment: "Note Modification Date")
        createdTextLabel.stringValue = NSLocalizedString("Created", comment: "Note Creation Date")
        wordsTextLabel.stringValue = NSLocalizedString("Words", comment: "Number of words in the note")
        charsTextLabel.stringValue = NSLocalizedString("Characters", comment: "Number of characters in the note")
    }

    func loadViewIfNeeded() {
        guard !isViewLoaded else {
            return
        }

        _ = view
    }
}


// MARK: - Enclosing Popover: Customize!
//
extension MetricsViewController: NSPopoverDelegate {

    public func popoverWillShow(_ notification: Notification) {
        presentingPopover = notification.object as? NSPopover
    }
}


// MARK: - Theme Support
//
private extension MetricsViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func refreshStyle() {
        presentingPopover?.appearance = .simplenoteAppearance

        for label in [ modifiedTextLabel, createdTextLabel, wordsTextLabel, charsTextLabel ] {
            label?.textColor = .simplenoteTextColor
        }

        for label in [ modifiedDetailsLabel, createdDetailsLabel, wordsDetailsLabel, charsDetailsLabel ] {
            label?.textColor = .simplenoteSecondaryTextColor
        }
    }
}


// MARK: - Rendering Metrics!
//
private extension MetricsViewController {

    func startObservingMetricUpdates() {
        controller.onChange = { [weak self] in
            self?.refreshMetrics()
        }
    }

    func refreshMetrics() {
        let created = controller.creationDate.map {
            dateFormatter.string(from: $0)
        }

        let modified = controller.modifiedDate.map {
            dateFormatter.string(from: $0)
        }

        modifiedDetailsLabel.stringValue = modified ?? "-"
        createdDetailsLabel.stringValue = created ?? "-"
        wordsDetailsLabel.stringValue = String(controller.numberOfWords)
        charsDetailsLabel.stringValue = String(controller.numberOfChars)
    }
}
