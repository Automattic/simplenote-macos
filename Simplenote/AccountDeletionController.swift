import Foundation

@objc
class AccountDeletionController: NSObject {
    private var accountDeletionRequestDate: Date?
    private var user: SPUser?

    var deletionTokenHasExpired: Bool {
        guard let requestDate = accountDeletionRequestDate,
              let expirationDate = requestDate.increased(byDays: 1) else {
            return true
        }

        return Date() > expirationDate
    }

    @objc
    func deleteAccount(for user: SPUser) {
        self.user = user


        let response = presentAccountDeletionConfirmationAlert()

        if response == .alertFirstButtonReturn {
            onConfirmAccountDeletion()
        }
    }

    private func presentAccountDeletionConfirmationAlert() -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = Constants.deleteAccount
        alert.informativeText = Constants.confirmAlertMessage
        alert.alertStyle = .critical

        alert.addButton(withTitle: Constants.deleteAccountButton)
        alert.addButton(withTitle: Constants.cancel)

        return alert.runModal()
    }

    @objc
    private func onConfirmAccountDeletion() {
        guard let user = user else {
            return
        }

        AccountRemote().requestDelete(user) { [weak self] (result) in
            switch result {
            case .success:
                self?.accountDeletionRequestDate = Date()
                self?.presentSuccessAlert(for: user.email)
            case .failure(let error):
                self?.handleError(error)
            }
        }

        NSApplication.shared.stopModal()
    }

    private func presentSuccessAlert(for userEmail: String) {
        let alert = NSAlert()
        alert.messageText = Constants.succesAlertTitle
        alert.informativeText = Constants.successMessage(email: userEmail)

        alert.runModal()
    }

    private func handleError(_ error: RemoteError) {
        var code: Int
        var description: String

        switch error {
        case .requestError(let statusCode, let error):
            code = statusCode
            description = error?.localizedDescription ?? Constants.genericErrorMessage
        default:
            code = Constants.genericErrorCode
            description = Constants.genericErrorMessage
        }

        let alert = NSAlert()
        alert.messageText = Constants.errorTitle
        alert.informativeText = Constants.errorMessage
        alert.runModal()
        NSLog("An error has occured with account deletion.  Error code: \(code) description: \(description)")
    }
}

private struct Constants {
    static let deleteAccount = NSLocalizedString("Delete Account", comment: "Delete account title and action")
    static let confirmAlertMessage = NSLocalizedString("By deleting your account, all notes created with this account will be permanently deleted. This action is not reversible", comment: "Delete account confirmation alert message")
    static let deleteAccountButton = NSLocalizedString("Request Account Deletion", comment: "Title for account deletion confirm button")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel button title")

    static let succesAlertTitle = NSLocalizedString("Check Your Email", comment: "Title for delete account succes alert")
    static let successAlertMessage = NSLocalizedString("An email has been sent to %@ Check your inbox and follow the instructions to confirm account deletion.\n\nYour account won't be deleted until we receive your confirmation", comment: "Delete account confirmation instructions")
    static let ok = NSLocalizedString("Ok", comment: "Confirm alert message")

    static let errorTitle = NSLocalizedString("Error", comment: "Deletion Error Title")
    static let errorMessage = NSLocalizedString("An error occured. Please, try again. If the problem continues, contact us at support@simplenote.com for help.", comment: "Deletion error message")
    static let genericErrorCode = 0
    static let genericErrorMessage = "Generic Error"

    static func successMessage(email: String) -> String {
        String(format: successAlertMessage, email)
    }
}
