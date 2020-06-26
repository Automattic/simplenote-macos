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


    // MARK: - Overridden Methdods

    deinit {
        stopListeningToNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextLabels()
        startListeningToNotifications()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        refreshStyle()
    }
}


// MARK: - Private
//
private extension MetricsViewController {

    func setupTextLabels() {
        modifiedTextLabel.stringValue = NSLocalizedString("Modified", comment: "")
        createdTextLabel.stringValue = NSLocalizedString("Created", comment: "")
        wordsTextLabel.stringValue = NSLocalizedString("Words", comment: "")
        charsTextLabel.stringValue = NSLocalizedString("Characters", comment: "")
    }
}


// MARK: - Notifications
//
private extension MetricsViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Style
//
private extension MetricsViewController {

    @objc
    func refreshStyle() {
        refreshLabelStyles()
    }

    func refreshLabelStyles() {
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
