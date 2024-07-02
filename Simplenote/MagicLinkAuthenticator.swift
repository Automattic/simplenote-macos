import Foundation


// MARK: - Notifications
//
extension NSNotification.Name {
    static let magicLinkAuthWillStart = NSNotification.Name("magicLinkAuthWillStart")
    static let magicLinkAuthDidSucceed = NSNotification.Name("magicLinkAuthDidSucceed")
    static let magicLinkAuthDidFail = NSNotification.Name("magicLinkAuthDidFail")
}


// MARK: - MagicLinkAuthenticator
//
struct MagicLinkAuthenticator {
    let authenticator: SimperiumAuthenticatorProtocol
    let loginRemote: LoginRemoteProtocol
    
    init(authenticator: SimperiumAuthenticatorProtocol, loginRemote: LoginRemoteProtocol = LoginRemote()) {
        self.authenticator = authenticator
        self.loginRemote = loginRemote
    }

    func handle(url: URL) -> Bool {
        guard let host = url.host, AllowedHosts.all.contains(host) else {
            return false
        }

        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            return false
        }

        if attemptLoginWithToken(queryItems: queryItems) {
            return true
        }

        return attemptLoginWithAuthCode(queryItems: queryItems)
    }
}

// MARK: - Private API(s)
//
private extension MagicLinkAuthenticator {

    @discardableResult
    func attemptLoginWithToken(queryItems: [URLQueryItem]) -> Bool {
        guard let email = queryItems.base64DecodedValue(for: Constants.emailField),
              let token = queryItems.value(for: Constants.tokenField),
              !email.isEmpty, !token.isEmpty else {
            return false
        }

        authenticator.authenticate(withUsername: email, token: token)
        return true
    }

    @discardableResult
    func attemptLoginWithAuthCode(queryItems: [URLQueryItem]) -> Bool {
        guard let authKey = queryItems.value(for: Constants.authKeyField),
              let authCode = queryItems.value(for: Constants.authCodeField),
              !authKey.isEmpty, !authCode.isEmpty
        else {
            return false
        }

        NSLog("[MagicLinkAuthenticator] Requesting SyncToken for \(authKey) and \(authCode)")
        NotificationCenter.default.post(name: .magicLinkAuthWillStart, object: nil)
        
        Task { @MainActor in
            do {
                let confirmation = try await loginRemote.requestLoginConfirmation(authKey: authKey, authCode: authCode)
              
                NSLog("[MagicLinkAuthenticator] Should auth with token \(confirmation.syncToken)")
                authenticator.authenticate(withUsername: confirmation.username, token: confirmation.syncToken)

                NotificationCenter.default.post(name: .magicLinkAuthDidSucceed, object: nil)
                SPTracker.trackUserConfirmedLoginLink()

            } catch {
                NSLog("[MagicLinkAuthenticator] Magic Link TokenExchange Error: \(error)")
                NotificationCenter.default.post(name: .magicLinkAuthDidFail, object: error)
            }
        }

        return true
    }
}

// MARK: - [URLQueryItem] Helper
//
private extension Array where Element == URLQueryItem {
    func value(for name: String) -> String? {
        first(where: { $0.name == name })?.value
    }

    func base64DecodedValue(for name: String) -> String? {
        guard let base64String = value(for: name),
              let data = Data(base64Encoded: base64String) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Constants
//
private struct AllowedHosts {
    static let hostForSimplenoteSchema = "login"
    static let hostForUniversalLinks = SimplenoteConstants.googleAppEngineHost
    static let all = [hostForSimplenoteSchema, hostForUniversalLinks]
}

private struct Constants {
    static let emailField = "email"
    static let tokenField = "token"
    static let authKeyField = "auth_key"
    static let authCodeField = "auth_code"
}
