import Foundation


// MARK: - AuthViewController: Interface
//
extension AuthViewController {

    /// Displays / Hides components, based on the ViewController Mode (SignUp / LogIn)
    ///
    @objc
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
}


// MARK: - Metrics
//
private enum Metrics {
    static let passwordHeight = CGFloat(40)
    static let forgotHeight = CGFloat(20)
    static let wordPressHeight = CGFloat(72)
}
