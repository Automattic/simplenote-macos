import Foundation
import AppKit


// MARK: - MetricsViewController
//
class MetricsViewController: NSViewController {

    /// Modified: Left Text Label
    ///
    @IBOutlet private(set) var modifiedTextLabel: NSTextField!

    /// Modified: Note Metrics!
    ///
    @IBOutlet private(set) var modifiedDetailsLabel: NSTextField!

    /// Created: Left Text Label
    ///
    @IBOutlet private(set) var createdTextLabel: NSTextField!

    /// Created: Note Metrics!
    ///
    @IBOutlet private(set) var createdDetailsLabel: NSTextField!

    /// Words: Left Text Label
    ///
    @IBOutlet private(set) var wordsTextLabel: NSTextField!

    /// Words: Note Metrics!
    ///
    @IBOutlet private(set) var wordsDetailsLabel: NSTextField!

    /// Characters: Left Text Label
    ///
    @IBOutlet private(set) var charsTextLabel: NSTextField!

    /// Characters: Note Metrics!
    ///
    @IBOutlet private(set) var charsDetailsLabel: NSTextField!

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


    // MARK: - Overridden Methdods

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
        let primaryLabels = [
            modifiedTextLabel, createdTextLabel, wordsTextLabel, charsTextLabel
        ]

        let secondaryLabels = [
            modifiedDetailsLabel, createdDetailsLabel, wordsDetailsLabel, charsDetailsLabel
        ]

        for label in primaryLabels {
            label?.textColor = .simplenoteTextColor
        }

        for label in secondaryLabels {
            label?.textColor = .simplenoteSecondaryTextColor
        }
    }
}


// MARK: - Rendering Metrics!
//
extension MetricsViewController {

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
