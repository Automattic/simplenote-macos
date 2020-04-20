import Foundation


// MARK: - Wraps access to all of the UserDefault Values
//
@objcMembers
class Options: NSObject {

    /// Shared Instance
    ///
    static let shared = Options()

    /// User Defaults: Convenience
    ///
    private let defaults: UserDefaults



    /// Designated Initializer
    ///
    /// - Note: Should be *private*, but for unit testing purposes, we're opening this up.
    ///
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
    }
}


// MARK: - Actual Options!
//
extension Options {

    /// Indicates if Analytics should be enabled
    ///
    var analyticsEnabled: Bool {
        get {
            return defaults.bool(forKey: .analyticsEnabled)
        }
        set {
            defaults.set(newValue, forKey: .analyticsEnabled)
        }
    }
}


// MARK: - Public Methods
//
extension Options {

    func reset() {
        defaults.removeObject(forKey: .analyticsEnabled)
    }
}
