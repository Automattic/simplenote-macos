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

    /// Indicates if Tags must be sort Alphabetically
    ///
    var alphabeticallySortTags: Bool {
        get {
            defaults.bool(forKey: .alphabeticallySortTags)
        }
        set {
            defaults.set(newValue, forKey: .alphabeticallySortTags)
            NotificationCenter.default.post(name: .TagSortModeDidChange, object: nil)
        }
    }

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

    /// Indicates if the Notes List must render in condensed mode
    ///
    @objc
    var condensedNotesList: Bool {
        get {
            defaults.bool(forKey: .condensedNotesList)
        }
        set {
            defaults.set(newValue, forKey: .condensedNotesList)
        }
    }

    /// Stores the name of the selected theme. Null indicates that the system's default theme should be picked, when possible
    ///
    var themeName: String? {
        get {
            defaults.string(forKey: .themeName)
        }
        set {
            defaults.set(newValue, forKey: .themeName)
            SPTracker.trackSettingsThemeUpdated(newValue)
            NotificationCenter.default.post(name: .ThemeDidChange, object: nil)
        }
    }
}
