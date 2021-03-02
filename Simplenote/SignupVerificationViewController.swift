import Foundation
import AppKit


// MARK: - SignupVerificationViewController
//
class SignupVerificationViewController: NSViewController {

    /// Outlets
    ///
    @IBOutlet private var messageTextField: NSTextField!
    @IBOutlet private var supportTextField: NSTextField!
    @IBOutlet private var backButton: NSButton!

    /// Signup Email
    ///
    private let email: String

    /// Simperium's Authenticator: Required only in case we must present back the Authentication Flow
    ///
    private let authenticator: SPAuthenticator


    /// Designated Initializer
    ///
    init(email: String, authenticator: SPAuthenticator) {
        self.email = email
        self.authenticator = authenticator
        let nibName = type(of: self).classNameWithoutNamespaces
        super.init(nibName: nibName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageLabel()
        setupSupportLabel()
        setupBackButton()
    }
}


// MARK: - Interface
//
private extension SignupVerificationViewController {

    func setupMessageLabel() {
        let text = String(format: Localization.messageTemplate, email)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.simplenoteTextColor,
            .font: Fonts.regularMessageFont,
            .paragraphStyle: paragraphStyle
        ]

        let highlightAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.boldMessageFont
        ]

        messageTextField.attributedStringValue = NSMutableAttributedString(string: text,
                                                                           attributes: attributes,
                                                                           highlighting: email,
                                                                           highlightAttributes: highlightAttributes)
    }

    func setupSupportLabel() {
        let text = String(format: Localization.support, SPCredentials.simplenoteFeedbackMail)

        supportTextField.stringValue = text
        supportTextField.textColor = .simplenoteSecondaryTextColor
    }

    func setupBackButton() {
        backButton.title = Localization.back
        backButton.contentTintColor = .simplenoteLinkColor
    }
}


// MARK: - Action Handlers
//
extension SignupVerificationViewController {

    @IBAction
    func backWasPressed(_ sender: Any) {
        presentAuthenticationInteface()
    }
}


// MARK: - Private API(s)
//
private extension SignupVerificationViewController {

    func presentAuthenticationInteface() {
        let authViewController = AuthViewController()
        authViewController.authenticator = authenticator
        view.window?.transition(to: authViewController)
    }
}


// MARK: - Localization
//
private enum Localization {
    static let messageTemplate = NSLocalizedString("We’ve sent an email to %1$@. Please check your inbox and follow the instructions.", comment: "Signup Body Text")
    static let support = NSLocalizedString("Didn’t get an email? Please contact %1$@.", comment: "Signup Support Text")
    static let back = NSLocalizedString("Go Back", comment: "Back Button Title")
}


private enum Fonts {
    static let regularMessageFont = NSFont.systemFont(ofSize: 13)
    static let boldMessageFont = NSFont.boldSystemFont(ofSize: 13)
}
