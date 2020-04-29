import Foundation


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
@objc
protocol PublishViewControllerDelegate {
    func publishControllerDidClickPublish(_ controller: PublishViewController)
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

    /// Internal State
    ///
    private var state: PublishState = .unpublishing {
        didSet {
            refreshInterface(newState: state)
        }
    }

    /// Returns the Publish Button's Internal State
    ///
    var publishButtonState: NSControl.StateValue {
        publishButton.state
    }

    /// Old School delegate
    ///
    weak var delegate: PublishViewControllerDelegate?


    // MARK - View Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        applyStyle()
    }

    /// Refreshes the Internal State
    ///
    /// - Parameters:
    ///     -   published: Indicates if the note we're dealing with is already published (or not)
    ///     -   url: Published note URL (if any)
    ///
    @objc
    func refreshState(published: Bool, url: String) {
        state = stateForNote(published: published, url: url)
    }

    @IBAction func buttonWasPressed(sender: Any) {
        delegate?.publishControllerDidClickPublish(self)
    }
}


// MARK: - Style
//
private extension PublishViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applyStyle), name: .ThemeDidChange, object: nil)
    }

    @objc
    func applyStyle() {
        let theme = VSThemeManager.shared().theme()

        // URL
        let urlPlaceholder = NSLocalizedString("Not Published", comment: "Placeholder displayed when a note hasn't been published.")
        let urlAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: theme.color(forKey: "popoverTextColor"),
            .font: NSFont.simplenotePopoverTextFont
        ]

        urlTextField.placeholderAttributedString = NSAttributedString(string: urlPlaceholder, attributes: urlAttributes)
        urlTextField.backgroundColor = theme.color(forKey: "shareUrlBackgroundColor")

        // Legend
        let legendParagraph = NSMutableParagraphStyle()
        legendParagraph.lineSpacing = Constants.lineSpacing
        legendParagraph.minimumLineHeight = Constants.lineHeight
        legendParagraph.maximumLineHeight = Constants.lineHeight

        let legendAttributes: [NSAttributedString.Key: Any] = [
            .font: theme.font(forKey: "popoverTextFont"),
            .foregroundColor: NSColor.simplenotePopoverTextColor,
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

    func stateForNote(published: Bool, url: String) -> PublishState {
        if published {
            return url.isEmpty ? .publishing : .published(url: url)
        }

        return url.isEmpty ? .unpublished : .unpublishing
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


// MARK: - Constants
//
private enum Constants {
    static let lineHeight = CGFloat(13)
    static let lineSpacing = CGFloat(3)
}
