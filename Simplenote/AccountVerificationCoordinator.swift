import Foundation


// MARK: - AccountVerificationCoordinator
//
@objc
class AccountVerificationCoordinator: NSObject {

    /// Controller: Active only when the user is logged in
    ///
    private var verificationController: AccountVerificationController?

    /// NSViewController instance which will present the Account Verification
    ///
    private var parentViewController: NSViewController


    /// Designated Initializer
    /// -   parentViewController: ViewController that will be presenting Account Verification
    ///
    init(parentViewController: NSViewController) {
        self.parentViewController = parentViewController
    }

    /// Should be invoked whenever Simperium logs in
    ///
    @objc
    func processDidLogin(email: String?) {
        guard let email = email, !email.isEmpty else {
            return
        }

        verificationController = AccountVerificationController(email: email)
        verificationController?.onStateChange = { [weak self] (oldState, state) in
            switch (oldState, state) {
            case (.unknown, .unverified):
                self?.presentVerificationViewController(configuration: .review)
                break

            case (.unknown, .verificationInProgress):
                self?.presentVerificationViewController(configuration: .verify)
                break

            case (.unverified, .verified), (.verificationInProgress, .verified):
                self?.dismissVerificationViewController()
                break

            default:
                break
            }
        }
    }

    /// Resets the internal state
    ///
    @objc
    func processDidLogout() {
        dismissVerificationViewController()
        verificationController = nil
    }

    /// Refreshes the Internal State
    /// - verification: Represents the remote Verification Entity
    ///
    @objc
    func refreshState(verification: [AnyHashable: Any]?) {
        verificationController?.update(with: verification)
    }
}


// MARK: - User Interface Helpers
//
private extension AccountVerificationCoordinator {

    var verificationViewController: AccountVerificationViewController? {
        let presentedViewControllers = parentViewController.presentedViewControllers?.first { $0 is AccountVerificationViewController }
        return presentedViewControllers as? AccountVerificationViewController
    }

    func presentVerificationViewController(configuration: AccountVerificationConfiguration) {
        guard let controller = verificationController, verificationViewController == nil else {
            return
        }

        let viewController = AccountVerificationViewController(configuration: configuration, controller: controller)
        parentViewController.presentAsSheet(viewController)
    }

    func dismissVerificationViewController() {
        verificationViewController?.dismiss(self)
    }
}
