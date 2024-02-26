import Foundation
import SimplenoteFoundation

// MARK: - Represents the PublishViewController's Internal State
//
enum PublishState {
    case publishing
    case published(url: String)
    case unpublishing
    case unpublished
}

// MARK: - VersionsViewControllerDelegate
//
protocol PublishViewControllerDelegate: AnyObject {
    func publishControllerDidClickPublish(_ controller: PublishViewController)
    func publishControllerDidClickUnpublish(_ controller: PublishViewController)
}

// MARK: - PublishViewController
//
@objcMembers
class PublishViewController: NSViewController {

    /// Publish Legend
    ///
    @IBOutlet private var legendTextField: NSTextField!

    /// Publish Button
    ///
    @IBOutlet private var publishButton: NSButton!

    /// Note's Published URL
    ///
    @IBOutlet private var urlTextField: NSTextField!

    /// Note whose publish state should be rendered
    ///
    private let note: Note

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

    /// Internal State
    ///
    private var state: PublishState = .unpublishing {
        didSet {
            refreshInterface(newState: state)
        }
    }

    /// Old School delegate
    ///
    weak var delegate: PublishViewControllerDelegate?

    // MARK: - View Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(note: Note) {
        let mainContext = SimplenoteAppDelegate.shared().managedObjectContext
        self.observer = EntityObserver(context: mainContext, object: note)
        self.note = note

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        setupEntityObserver()
        refreshStyle()
        refreshState()
    }
}

// MARK: - Actions
//
extension PublishViewController {

    @IBAction func buttonWasPressed(sender: Any) {
        guard let delegate = delegate else {
            return
        }

        switch publishButton.state {
        case .on:
            delegate.publishControllerDidClickPublish(self)
        default:
            delegate.publishControllerDidClickUnpublish(self)
        }
    }
}

// MARK: - Initialization
//
private extension PublishViewController {

    func setupEntityObserver() {
        observer.delegate = self
    }
}

// MARK: - Style
//
private extension PublishViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
    }

    @objc
    func refreshStyle() {
        // Note: Backwards compatibility *requires* this line (10.13 / 10.14)
        presentingPopover?.appearance = .simplenoteAppearance

        // URL
        let urlPlaceholder = NSLocalizedString("Not Published", comment: "Placeholder displayed when a note hasn't been published.")
        let urlAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.simplenoteTextColor,
            .font: NSFont.simplenoteSecondaryTextFont
        ]

        urlTextField.placeholderAttributedString = NSAttributedString(string: urlPlaceholder, attributes: urlAttributes)
        urlTextField.backgroundColor = .simplenotePopoverBackgroundColor

        // Legend
        let legendParagraph = NSMutableParagraphStyle()
        legendParagraph.lineSpacing = Constants.lineSpacing
        legendParagraph.minimumLineHeight = Constants.lineHeight
        legendParagraph.maximumLineHeight = Constants.lineHeight

        let legendAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.simplenoteSecondaryTextFont,
            .foregroundColor: NSColor.simplenoteTextColor,
            .paragraphStyle: legendParagraph
        ]

        let legendText = NSLocalizedString("Publish this note to a web page. The page will stay updated with the contents of your note.",
                                           comment: "Text presented when the note is about to be published")

        legendTextField.attributedStringValue = NSAttributedString(string: legendText, attributes: legendAttributes)
    }
}

// MARK: - Private
//
private extension PublishViewController {

    func refreshState() {
        if note.published {
            state = note.publishURL.isEmpty ? .publishing : .published(url: note.publishURL)
            return
        }

        state = note.publishURL.isEmpty ? .unpublished : .unpublishing
    }

    func refreshInterface(newState: PublishState) {
        switch newState {
        case .publishing:
            urlTextField.stringValue = NSLocalizedString("Publishing...", comment: "Displayed during a Publish Operation")
            publishButton.title = NSLocalizedString("Publish to Web Page", comment: "Publish to WebPage Action")
            publishButton.isEnabled = false

        case .published(let url):
            urlTextField.stringValue = SPSimplenotePublishURL + url
            publishButton.title = NSLocalizedString("Unpublish", comment: "Unpublish Note Action")
            publishButton.isEnabled = true
            publishButton.state = .on

        case .unpublished:
            urlTextField.stringValue = ""
            publishButton.title = NSLocalizedString("Publish to Web Page", comment: "Publish to WebPage Action")
            publishButton.isEnabled = true
            publishButton.state = .off

        case .unpublishing:
            urlTextField.stringValue = NSLocalizedString("Unpublishing...", comment: "Displayed during an Unpublish Operation")
            publishButton.title = NSLocalizedString("Unpublish", comment: "Unpublish Note Action")
            publishButton.isEnabled = false
        }
    }
}

// MARK: - NSPopoverDelegate
//
extension PublishViewController: NSPopoverDelegate {

    public func popoverWillShow(_ notification: Notification) {
        presentingPopover = notification.object as? NSPopover
    }
}

// MARK: - EntityObserverDelegate
//
extension PublishViewController: EntityObserverDelegate {

    func entityObserver(_ observer: EntityObserver, didObserveChanges for: Set<NSManagedObjectID>) {
        refreshState()
    }
}

// MARK: - Constants
//
private enum Constants {
    static let lineHeight = CGFloat(13)
    static let lineSpacing = CGFloat(3)
}
