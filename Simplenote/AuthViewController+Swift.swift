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
        usernameField.placeholderString = Localization.emailPlaceholder
        usernameField.delegate = self

        passwordField.placeholderString = Localization.passwordPlaceholder
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
        usernameField.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    @objc
    var passwordText: String {
        passwordField.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}


// MARK: - Refreshing
//
extension AuthViewController {

    @objc(refreshInterfaceWithAnimation:)
    func refreshInterface(animated: Bool) {
        clearAuthenticationError()
        refreshButtonTitles()
        refreshEnabledComponents()
        refreshVisibleComponents(animated: animated)
    }

    func refreshButtonTitles() {
        let actionText    = signingIn ? Localization.signInAction   : Localization.signUpAction
        let tipText       = signingIn ? Localization.signUpTip      : Localization.signInTip
        let switchText    = signingIn ? Localization.signUpAction   : Localization.signInAction

        actionButton.title         = actionText
        switchTipField.stringValue = tipText.uppercased()
        switchActionButton.title   = switchText.uppercased()
    }

    /// Makes sure unused components (in the current mode) are effectively disabled
    ///
    func refreshEnabledComponents() {
        passwordField.isEnabled = signingIn
        forgotPasswordButton.isEnabled = signingIn
        wordPressSSOButton.isEnabled = signingIn
    }

    /// Shows / Hides relevant components, based on the specified state
    ///
    func refreshVisibleComponents(animated: Bool) {
        if animated {
            refreshVisibleComponentsWithAnimation()
        } else {
            refreshVisibleComponentsWithoutAnimation()
        }
    }

    /// Shows / Hides relevant components, based on the specified state
    /// - Note: Trust me on this one. It's cleaner to have specific methods, rather than making a single one support the `animated` flag.
    ///         Notice that AppKit requires us to go thru `animator()`.
    ///
    func refreshVisibleComponentsWithoutAnimation() {
        passwordFieldHeightConstraint.constant   = Metrics.passwordHeight(signingIn: signingIn)
        forgotPasswordHeightConstraint.constant  = Metrics.forgotHeight(signingIn: signingIn)
        wordPressSSOHeightConstraint.constant    = Metrics.wordPressHeight(signingIn: signingIn)
        
        let fields      = [passwordField, forgotPasswordButton, wordPressSSOButton].compactMap { $0 }
        let alphaStart  = signingIn ? AppKitConstants.alpha0_0 : AppKitConstants.alpha1_0
        let alphaEnd    = signingIn ? AppKitConstants.alpha1_0 : AppKitConstants.alpha0_0

        fields.updateAlphaValue(AppKitConstants.alpha0_0)
    }

    /// Animates Visible / Invisible components, based on the specified state
    ///
    func refreshVisibleComponentsWithAnimation() {
        let fields      = [passwordField, forgotPasswordButton, wordPressSSOButton].compactMap { $0 }
        let alphaStart  = signingIn ? AppKitConstants.alpha0_0 : AppKitConstants.alpha1_0
        let alphaEnd    = signingIn ? AppKitConstants.alpha1_0 : AppKitConstants.alpha0_0

        fields.updateAlphaValue(alphaStart)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = AppKitConstants.duration0_2

            passwordFieldHeightConstraint.animator().constant   = Metrics.passwordHeight(signingIn: signingIn)
            forgotPasswordHeightConstraint.animator().constant  = Metrics.forgotHeight(signingIn: signingIn)
            wordPressSSOHeightConstraint.animator().constant    = Metrics.wordPressHeight(signingIn: signingIn)

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

    /// Marks the Username Field as the First Responder
    ///
    @objc
    func ensureUsernameIsFirstResponder() {
        usernameField?.textField.becomeFirstResponder()
        view.needsDisplay = true
    }
}


// MARK: - Action Handlers
//
extension AuthViewController {

    @objc
    func didUpdateAuthenticationMode() {
        guard isViewLoaded else {
            return
        }

        refreshInterface(animated: true)
        ensureUsernameIsFirstResponder()
    }

    @objc
    func performSignupRequest() {
        startSignupAnimation()
        setInterfaceEnabled(false)

        let email = usernameText
        SignupRemote().requestSignup(email: email) { [weak self] (result) in
            guard let self = `self` else {
                return
            }

            switch result {
            case .success:
                self.presentSignupVerification(email: email)
            case .failure(let result):
                self.showAuthenticationError(forCode: result.statusCode, responseString: nil)
            }

            self.stopSignupAnimation()
            self.setInterfaceEnabled(true)
        }
    }
}


// MARK: - Presenting!
//
extension AuthViewController {

    func presentSignupVerification(email: String) {
        let vc = SignupVerificationViewController(email: email, authenticator: authenticator)
        view.window?.transition(to: vc)
    }
}

// MARK: - Login Error Handling
//
extension AuthViewController {
    @objc
    func showCompromisedPasswordAlert(for window: NSWindow, completion: @escaping (NSApplication.ModalResponse) -> Void) {
        let alert = NSAlert()
        alert.messageText = Localization.compromisedPasswordAlert
        alert.informativeText = Localization.compromisedPasswordMessage
        alert.addButton(withTitle: Localization.changePasswordAction)
        alert.addButton(withTitle: Localization.dismissChangePasswordAction)

        alert.beginSheetModal(for: window, completionHandler: completion)
    }

    @objc
    func showUnverifiedEmailAlert(for window: NSWindow, completion: @escaping (NSApplication.ModalResponse) -> Void) {
        let alert = NSAlert()
        alert.messageText = Localization.unverifiedMessageText
        alert.informativeText = Localization.unverifiedInformativeText
        alert.addButton(withTitle: Localization.unverifiedActionText)
        alert.addButton(withTitle: Localization.cancelText)

        alert.beginSheetModal(for: window, completionHandler: completion)
    }

    @objc
    func sendVerificationMessage(for email: String, inWindow window: NSWindow) {
        setInterfaceEnabled(false)
        let progressIndicator = NSProgressIndicator.addProgressIndicator(to: view)

        AccountRemote().verify(email: email) { result in
            self.setInterfaceEnabled(true)
            progressIndicator.removeFromSuperview()

             var alert: NSAlert
             switch result {
             case .success:
                alert = NSAlert(messageText: Localization.verificationSentTitle, informativeText: String(format: Localization.verificationSentTemplate, email))
             case .failure:
                alert = NSAlert(messageText: Localization.unverifriedErrorTitle, informativeText: Localization.unverifiedErrorMessage)
             }
            alert.addButton(withTitle: Localization.cancelText)
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
    }
}

// MARK: - Metrics
//
private enum Metrics {
    static func passwordHeight(signingIn: Bool) -> CGFloat {
        signingIn ? CGFloat(40) : .zero
    }
    static func forgotHeight(signingIn: Bool) -> CGFloat {
        signingIn ? CGFloat(20) : .zero
    }
    static func wordPressHeight(signingIn: Bool) -> CGFloat {
        signingIn ? CGFloat(72) : .zero
    }
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
    static let compromisedPasswordAlert = NSLocalizedString("Compromised Password", comment: "Compromised passsword alert title")
    static let compromisedPasswordMessage = NSLocalizedString("This password has appeared in a data breach, which puts your account at high risk of compromise. To protect your data, you'll need to update your password before being able to log in again.", comment: "Compromised password alert message")
    static let changePasswordAction = NSLocalizedString("Change Password", comment: "Change password action")
    static let dismissChangePasswordAction = NSLocalizedString("Cancel", comment: "Dismiss change password alert action")
    static let unverifiedInformativeText = NSLocalizedString("You must verify your email before being able to login.", comment: "Erro for un verified email")
    static let unverifiedMessageText = NSLocalizedString("Account Verification Required", comment: "Email verification required alert title")
    static let cancelText = NSLocalizedString("Ok", comment: "Email unverified alert dismiss")
    static let unverifiedActionText = NSLocalizedString("Resend Verification Email", comment: "Send email verificaiton action")
    static let unverifriedErrorTitle = NSLocalizedString("Request Error", comment: "Request error alert title")
    static let unverifiedErrorMessage = NSLocalizedString("There was an preparing your verification email, please try again later", comment: "Request error alert message")
    static let verificationSentTitle = NSLocalizedString("Check your Email", comment: "Vefification sent alert title")
    static let verificationSentTemplate = NSLocalizedString("We’ve sent a verification email to %1$@. Please check your inbox and follow the instructions.", comment: "Confirmation that an email has been sent")
}
