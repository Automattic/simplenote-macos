import Foundation
import AppKit
import SimplenoteFoundation


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

    /// Notes whose metrics should be rendered
    ///
    private let notes: [Note]

    /// Entity Observer
    ///
    private let observer: EntityObserver

    /// NSPopover instance that's presenting the current instance.
    ///
    private var presentingPopover: NSPopover? {
        didSet {
            refreshStyle()
        }
    }


    // MARK: - Lifecycle

    deinit {
        stopListeningToNotifications()
    }

    init(notes: [Note]) {
        let mainContext = SimplenoteAppDelegate.shared().managedObjectContext

        self.observer = EntityObserver(context: mainContext, objects: notes)
        self.notes = notes

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextLabels()
        setupEntityObserver()
        startListeningToNotifications()
        refreshMetrics()
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
        modifiedTextLabel.stringValue = NSLocalizedString("Modified", comment: "Note Modification Date")
        createdTextLabel.stringValue = NSLocalizedString("Created", comment: "Note Creation Date")
        wordsTextLabel.stringValue = NSLocalizedString("Words", comment: "Number of words in the note")
        charsTextLabel.stringValue = NSLocalizedString("Characters", comment: "Number of characters in the note")
    }

    func setupEntityObserver() {
        observer.delegate = self
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
        // Note: Backwards compatibility *requires* this line (10.13 / 10.14)
        presentingPopover?.appearance = .simplenoteAppearance

        for label in [ modifiedTextLabel, createdTextLabel, wordsTextLabel, charsTextLabel ] {
            label?.textColor = .simplenoteTextColor
        }

        for label in [ modifiedDetailsLabel, createdDetailsLabel, wordsDetailsLabel, charsDetailsLabel ] {
            label?.textColor = .simplenoteSecondaryTextColor
        }
    }
}


// MARK: - EntityObserverDelegate
//
extension MetricsViewController: EntityObserverDelegate {

    func entityObserver(_ observer: EntityObserver, didObserveChanges for: Set<NSManagedObjectID>) {
        refreshMetrics()
    }
}


// MARK: - Rendering Metrics!
//
private extension MetricsViewController {

    func refreshMetrics() {
        let metrics = NoteMetrics(notes: notes)

        modifiedDetailsLabel.stringValue = metrics.modifiedDate ?? "-"
        createdDetailsLabel.stringValue = metrics.creationDate ?? "-"
        wordsDetailsLabel.stringValue = String(metrics.numberOfWords)
        charsDetailsLabel.stringValue = String(metrics.numberOfChars)
    }
}
