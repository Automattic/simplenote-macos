import Foundation

// MARK: - MagicLinkAuthenticator
//
struct MagicLinkAuthenticator {
    let authenticator: SPAuthenticator

    func handle(url: URL) -> Bool {
        guard
            url.host == RequestSignupURL.host,
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let email = queryItems.base64DecodedValue(for: RequestSignupURL.emailField),
            let token = queryItems.value(for: RequestSignupURL.tokenField),
            !email.isEmpty,
            !token.isEmpty
        else {
            return false
        }

        authenticator.authenticate(withUsername: email, token: token)
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
private struct RequestSignupURL {
    static let host = "login"
    static let emailField = "email"
    static let tokenField = "token"
}
