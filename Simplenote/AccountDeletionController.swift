import Foundation

@objc
class AccountDeletionController: NSObject {
    private var accountDeletionRequestDate: Date?

    var hasValidDeletionRequest: Bool {
        guard let expirationDate = accountDeletionRequestDate?.increased(byDays: 1) else {
            return false
        }

        return Date() < expirationDate
    }

    @objc
    func requestAccountDeletion(for user: SPUser, with window: Window) {
        let alert = NSAlert(messageText: Constants.deleteAccount, informativeText: Constants.confirmAlertMessage)

        alert.alertStyle = .critical
        alert.addButton(withTitle: Constants.deleteAccountButton)
        alert.addButton(withTitle: Constants.cancel)

        alert.beginSheetModal(for: window) { (modalResponse) in
            if modalResponse == .alertFirstButtonReturn {
                self.onConfirmAccountDeletion(for: user, for: window)
            }
        }
    }

    @objc
    private func onConfirmAccountDeletion(for user: SPUser, for window: Window) {
        AccountRemote().requestDelete(user) { [weak self] (result) in
            switch result {
            case .success:
                self?.accountDeletionRequestDate = Date()
                NSAlert.presentAlert(withMessageText: Constants.succesAlertTitle,
                                     informativeText: Constants.successMessage(email: user.email),
                                     for: window)
            case .failure:
                NSAlert.presentAlert(withMessageText: Constants.errorTitle,
                                     informativeText: Constants.errorMessage,
                                     for: window)
            }
        }
    }

    @objc
    func clearRequestToken() {
        accountDeletionRequestDate = nil
    }
}

private struct Constants {
    static let deleteAccount = NSLocalizedString("Delete Account", comment: "Delete account title and action")
    static let confirmAlertMessage = NSLocalizedString("By deleting your account, all notes created with this account will be permanently deleted. This action is not reversible.", comment: "Delete account confirmation alert message")
    static let deleteAccountButton = NSLocalizedString("Request Account Deletion", comment: "Title for account deletion confirm button")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel button title")

    static let succesAlertTitle = NSLocalizedString("Check Your Email", comment: "Title for delete account succes alert")
    static let successAlertMessage = NSLocalizedString("An email has been sent to %@. Check your inbox and follow the instructions to confirm account deletion.\n\nYour account won't be deleted until we receive your confirmation.", comment: "Delete account confirmation instructions")

    static let errorTitle = NSLocalizedString("Error", comment: "Deletion Error Title")
    static let errorMessage = NSLocalizedString("An error occured. Please, try again. If the problem continues, contact us at support@simplenote.com for help.", comment: "Deletion error message")

    static func successMessage(email: String) -> String {
        String(format: successAlertMessage, email)
    }
}
