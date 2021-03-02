import Foundation


// MARK: - AuthViewController: Interface Initialization
//
extension AuthViewController {

    @objc
    func setupInterface() {
        // Error Label
        errorField.stringValue = ""
        errorField.textColor = .red

        // Fields
        usernameField.setPlaceholderString(Localization.emailPlaceholder)
        usernameField.delegate = self

        passwordField.setPlaceholderString(Localization.passwordPlaceholder)
        passwordField.delegate = self

        // Forgot Password!
        forgotPasswordButton.title = Localization.forgotAction.uppercased()
        forgotPasswordButton.contentTintColor = .simplenoteBrandColor

        // Toggle Signup: Tip
        switchTipField.textColor = .simplenoteTertiaryTextColor

        // Toggle Signup: Action
        switchActionButton.contentTintColor = .simplenoteBrandColor

        // WordPress SSO
        wordPressSSOButton.image = NSImage(named: .wordPressLogo)?.tinted(with: .simplenoteBrandColor)
        wordPressSSOButton.title = Localization.dotcomSSOAction
        wordPressSSOButton.contentTintColor = .simplenoteTertiaryTextColor
    }
}


// MARK: - Dynamic Properties
//
extension AuthViewController {

    @objc
    var usernameText: String {
        usernameField.stringValue()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    @objc
    var passwordText: String {
        passwordField.stringValue()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}


// MARK: - Refreshing
//
extension AuthViewController {

    @objc
    func refreshFields() {
        guard isViewLoaded else {
            return;
        }

        clearAuthenticationError()
        refreshButtonTitles()
        refreshVisibleComponentsWithAnimation()
    }

    @objc
    func refreshButtonTitles() {
        let actionText    = signingIn ? Localization.signInAction   : Localization.signUpAction
        let tipText       = signingIn ? Localization.signUpTip      : Localization.signInTip
        let switchText    = signingIn ? Localization.signUpAction   : Localization.signInAction

        actionButton.title         = actionText
        switchTipField.stringValue = tipText.uppercased()
        switchActionButton.title   = switchText.uppercased()
    }

    /// Displays / Hides components, based on the ViewController Mode (SignUp / LogIn)
    ///
    func refreshVisibleComponentsWithAnimation() {
        let mustHide = !signingIn

        let fields      = [passwordField, forgotPasswordButton, wordPressSSOButton].compactMap { $0 }
        let alphaStart  = mustHide ? AppKitConstants.alpha1_0 : AppKitConstants.alpha0_0
        let alphaEnd    = mustHide ? AppKitConstants.alpha0_0 : AppKitConstants.alpha1_0

        fields.updateAlphaValue(alphaStart)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = AppKitConstants.duration0_2

            passwordFieldHeightConstraint.animator().constant   = mustHide ? .zero : Metrics.passwordHeight
            forgotPasswordHeightConstraint.animator().constant  = mustHide ? .zero : Metrics.forgotHeight
            wordPressSSOHeightConstraint.animator().constant    = mustHide ? .zero : Metrics.wordPressHeight

            fields.updateAlphaValue(alphaEnd)
            view.layoutSubtreeIfNeeded()
        }
    }

    /// Drops any Errors onscreen
    ///
    @objc
    func clearAuthenticationError() {
        errorField.stringValue = ""
    }
}


// MARK: - Metrics
//
private enum Metrics {
    static let passwordHeight = CGFloat(40)
    static let forgotHeight = CGFloat(20)
    static let wordPressHeight = CGFloat(72)
}


// MARK: - Localization
//
private enum Localization {
    static let emailPlaceholder = NSLocalizedString("Email", comment: "Placeholder text for login field")
    static let passwordPlaceholder = NSLocalizedString("Password", comment: "Placeholder text for password field")
    static let signInAction = NSLocalizedString("Log In", comment: "Title of button for logging in")
    static let signUpAction = NSLocalizedString("Sign Up", comment: "Title of button for signing up")
    static let signInTip = NSLocalizedString("Already have an account?", comment: "Link to sign in to an account")
    static let signUpTip = NSLocalizedString("Need an account?", comment: "Link to create an account")
    static let forgotAction = NSLocalizedString("Forgot your Password?", comment: "Forgot Password Button")
    static let dotcomSSOAction = NSLocalizedString("Log in with WordPress.com", comment: "button title for wp.com sign in button")
}
