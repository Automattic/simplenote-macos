import Foundation


// MARK: - PublishViewController
//
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


    // MARK - View Lifecycle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startListeningToNotifications()
        applyStyle()
    }
}


// MARK: - Private
//
private extension PublishViewController {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applyStyle), name: .VSThemeManagerThemeDidChange, object: nil)
    }

    @objc
    func applyStyle() {
        let theme = VSThemeManager.shared().theme()

        // URL
        let urlPlaceholder = NSLocalizedString("Not Published", comment: "Placeholder displayed when a note hasn't been published.")
        let urlAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: theme.color(forKey: "popoverTextColor"),
            .font: theme.color(forKey: "popoverTextFont")
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
            .foregroundColor: theme.color(forKey: "popoverTextColor"),
            .paragraphStyle: legendParagraph
        ]

        let legendText = NSLocalizedString("Publish this note to a web page. The page will stay updated with the contents of your note.",
                                           comment: "Text presented when the note is about to be published")

        legendTextField.attributedStringValue = NSAttributedString(string: legendText, attributes: legendAttributes)
    }
}


// MARK: - Constants
//
private enum Constants {
    static let lineHeight = CGFloat(13)
    static let lineSpacing = CGFloat(3)
}
