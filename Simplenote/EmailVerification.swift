import Foundation



// MARK: - EmailVerification
//          There is only one condition in which an account is verified
//          - The email verification token exists, is secure, and matches the email for the account as the app knows it
//            (either from login or from the response of the init call).
//
//          If those three conditions hold (two for now) then it’s verified. If any of those fail then it’s not verified
//
enum EmailVerificationStatus: Equatable {
    case sent
    case verified
}


// MARK: - EmailVerification
//
struct EmailVerification {
    let username: String?
    let timestamp: Int?
    let signature: String?
}


// MARK: - Public API(s)
//
extension EmailVerification {

    init?(payload: [AnyHashable: Any]) {
        guard let tokenAsJSON = payload[EmailVerificationKeys.token.rawValue] as? String,
              let tokenAsData = tokenAsJSON.data(using: .utf8),
              let token = try? JSONSerialization.jsonObject(with: tokenAsData, options: []) as? [String: Any]
        else {
            return nil
        }

        username = token[EmailVerificationKeys.username.rawValue] as? String
        timestamp = token[EmailVerificationKeys.timestamp.rawValue] as? Int
        signature = payload[EmailVerificationKeys.signature.rawValue] as? String
    }
}


// MARK: - CodingKeys
//
private enum EmailVerificationKeys: String {
    case token
    case username
    case timestamp = "verified_at"
    case signature = "token_signature"
}
