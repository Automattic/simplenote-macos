import Foundation


// MARK: - Simplenote Constants!
//
@objcMembers
class SimplenoteConstants: NSObject {

    /// You shall not pass (!!)
    ///
    private override init() { }

    /// Tag(s) Max Length
    ///
    static let maximumTagLength = 256

    /// Simplenote: Scheme
    ///
    static let simplenoteScheme = "simplenote"

    /// Simplenote: Interlink
    ///
    static let simplenoteInterlinkHost = "note"
    static let simplenoteInterlinkMaxTitleLength = 150

    /// URL(s)
    ///
    static let simplenoteSettingsURL = "https://app.simplenote.com/settings"
    static let simplenoteVerificationURL = "https://app.simplenote.com/account/verify-email/"
    static let simplenoteRequestSignupURL = "https://app.simplenote.com/request-signup"

    /// Reserved Object Keys
    ///
    static let welcomeNoteObjectKey = "welcomeNote-Mac"
}
