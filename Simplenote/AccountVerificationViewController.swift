import Foundation
import AppKit


// MARK: - AccountVerificationViewController
//
class AccountVerificationViewController: NSViewController {

    /// Interface Outlets
    ///
    @IBOutlet private var iconImageView: NSImageView!
    @IBOutlet private var titleLabel: NSTextField!
    @IBOutlet private var textLabel: NSTextField!
    @IBOutlet private var primaryButton: NSButton!
    @IBOutlet private var secondaryButton: NSButton!
    @IBOutlet private var dismissButton: NSButton!

    /// Verification Controller
    ///
    private let controller: AccountVerificationController

    /// Display Configuration
    ///
    private var configuration: AccountVerificationConfiguration {
        didSet {
            refreshStyle()
            refreshContent()
            trackScreen()
        }
    }

    // MARK: - Deinit

    deinit {
        stopListeningToNotifications()
    }

    // MARK: - Initializers

    init(configuration: AccountVerificationConfiguration, controller: AccountVerificationController) {
        self.configuration = configuration
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStyle()
        refreshContent()
        startListeningToNotifications()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        trackScreen()
    }
}


// MARK: - Actions
//
extension AccountVerificationViewController {

    @IBAction
    func dismissWasPressed(_ sender: Any) {
        super.dismiss(sender)
    }
}


// MARK: - Refreshing UI
//
private extension AccountVerificationViewController {

    func refreshStyle() {
        iconImageView.contentTintColor = .simplenoteSecondaryTextColor
        titleLabel.textColor = .simplenoteAlertTextColor
        textLabel.textColor = .simplenoteAlertTextColor

        primaryButton.contentTintColor = .simplenoteAlertTextColor
        secondaryButton.contentTintColor = .simplenoteLinkColor

        let primaryButtonCell = primaryButton.cell as? ButtonCell
        primaryButtonCell?.textColor = .simplenoteAlertPrimaryActionTextColor
        primaryButtonCell?.regularBackgroundColor = .simplenoteAlertPrimaryActionBackgroundColor
        primaryButtonCell?.highlightedBackgroundColor = .simplenoteAlertPrimaryActionHighlightedBackgroundColor

//        dismissButton
    }

    func refreshContent() {
        let message = String(format: configuration.messageTemplate, controller.email)

        iconImageView.image = NSImage(named: configuration.iconName)
        titleLabel.stringValue = configuration.title
        textLabel.attributedStringValue = attributedText(message, highlighting: controller.email)
        primaryButton.title = configuration.primaryActionTitle ?? String()
        secondaryButton.title = configuration.secondaryActionTitle

        primaryButton.isHidden = configuration.primaryActionTitle == nil
    }

    func attributedText(_ text: String, highlighting term: String) -> NSAttributedString {
        let attributedMessage = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: NSColor.simplenoteTextColor,
            .font: NSFont.systemFont(ofSize: Metrics.bodyFontSize)
        ])

        if let range = text.range(of: term) {
            attributedMessage.addAttribute(.font,
                                           value: NSFont.boldSystemFont(ofSize: Metrics.bodyFontSize),
                                           range: NSRange(range, in: text))
        }

        return attributedMessage
    }
}


// MARK: - Notifications
//
private extension AccountVerificationViewController {

    func startListeningToNotifications() {
        if #available(macOS 10.15, *) {
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(themeWasUpdated), name: .ThemeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func themeWasUpdated() {
        refreshStyle()
    }
}


// MARK: - Tracks
//
private extension AccountVerificationViewController {
    func trackScreen() {
        switch configuration {
        case .review:
            SPTracker.trackVerificationReviewScreenViewed()
        case .verify:
            SPTracker.trackVerificationVerifyScreenViewed()
        default:
            break
        }
    }
}


// MARK: - Configuration
//
struct AccountVerificationConfiguration: Equatable {
    let iconName: NSImage.Name
    let title: String
    let messageTemplate: String
    let primaryActionTitle: String?
    let secondaryActionTitle: String
    let errorMessageTitle: String
}

extension AccountVerificationConfiguration {
    static let review = AccountVerificationConfiguration(iconName: .info,
                                                         title: Localization.Review.title,
                                                         messageTemplate: Localization.Review.messageTemplate,
                                                         primaryActionTitle: Localization.Review.confirm,
                                                         secondaryActionTitle: Localization.Review.changeEmail,
                                                         errorMessageTitle: Localization.Review.errorMessageTitle)

    static let verify = AccountVerificationConfiguration(iconName: .mail,
                                                         title: Localization.Verify.title,
                                                         messageTemplate: Localization.Verify.messageTemplate,
                                                         primaryActionTitle: nil,
                                                         secondaryActionTitle: Localization.Verify.resendEmail,
                                                         errorMessageTitle: Localization.Verify.errorMessageTitle)
}


// MARK: - UI Metrics
//
private enum Metrics {
    static let bodyFontSize: CGFloat = 16
}


// MARK: - Localization
//
private enum Localization {
    static let errorMessage = NSLocalizedString("Please check your network settings and try again.", comment: "Error message. Account verification")
    static let okButton = NSLocalizedString("OK", comment: "Dismisses an AlertController")

    struct Review {
        static let title = NSLocalizedString("Review Your Account", comment: "Title -> Review you account screen")
        static let messageTemplate = NSLocalizedString("You are registered with Simplenote using the email %1$@.\n\nImprovements to account security may result in account loss if you no longer have access to this email address.", comment: "Message -> Review you account screen. Parameter: %1$@ - email address")
        static let confirm = NSLocalizedString("Confirm", comment: "Confirm button -> Review you account screen")
        static let changeEmail = NSLocalizedString("Change Account Email", comment: "Change email button -> Review you account screen")
        static let errorMessageTitle = NSLocalizedString("Cannot Confirm Account", comment: "Error message title. Review you account screen")
    }

    struct Verify {
        static let title = NSLocalizedString("Verify Your Email", comment: "Title -> Verify your email screen")
        static let messageTemplate = NSLocalizedString("We’ve sent a verification email to %1$@. Please check your inbox and follow the instructions.", comment: "Message -> Verify your email screen. Parameter: %1$@ - email address")
        static let resendEmail = NSLocalizedString("Resend Email", comment: "Resend email button -> Verify your email screen")
        static let errorMessageTitle = NSLocalizedString("Cannot Send Verification Email", comment: "Error message title. Verify your email screen")
    }
}
