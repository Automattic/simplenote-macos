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

    /// Drops all the known settings
    ///
    func reset() {
        defaults.removeObject(forKey: .analyticsEnabled)
    }
}


// MARK: - Actual Options!
//
extension Options {

    /// Indicates if Analytics should be enabled. Empty value defaults to `false`
    ///
    var analyticsEnabled: Bool {
        get {
            defaults.bool(forKey: .analyticsEnabled)
        }
        set {
            defaults.set(newValue, forKey: .analyticsEnabled)
        }
    }

    /// Stores the name of the selected theme. Null indicates that the system's default theme should be picked, when possible
    ///
    var theme: String? {
        get {
            defaults.string(forKey: .theme)
        }
        set {
            defaults.set(newValue, forKey: .theme)
            SPTracker.trackSettingsThemeUpdated(newValue)
            NotificationCenter.default.post(name: .ThemeDidChange, object: nil)
        }
    }
}
