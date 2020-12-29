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
        migrateLegacyOptions()
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

    /// Tags: Alphabetical Sort
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

    /// Analytics
    ///
    var analyticsEnabled: Bool {
        get {
            defaults.bool(forKey: .analyticsEnabled)
        }
        set {
            defaults.set(newValue, forKey: .analyticsEnabled)
        }
    }

    /// Editor: Full Width
    ///
    @objc
    var editorFullWidth: Bool {
        get {
            defaults.bool(forKey: .editorFullWidth)
        }
        set {
            defaults.set(newValue, forKey: .editorFullWidth)
            NotificationCenter.default.post(name: .EditorDisplayModeDidChange, object: nil)
        }
    }

    /// Flag used to run First Launch initialization (such as Welcome Note creation)
    ///
    @objc
    var initialSetupComplete: Bool {
        get {
            defaults.bool(forKey: .initialSetupComplete)
        }
        set {
            defaults.set(newValue, forKey: .initialSetupComplete)
        }
    }

    /// Notes List: Condensed
    ///
    @objc
    var notesListCondensed: Bool {
        get {
            defaults.bool(forKey: .notesListCondensed)
        }
        set {
            defaults.set(newValue, forKey: .notesListCondensed)
            NotificationCenter.default.post(name: .NoteListDisplayModeDidChange, object: nil)
        }
    }

    /// Notes List: Sort Mode
    ///
    var notesListSortMode: SortMode {
        get {
            let payload = defaults.integer(forKey: .notesListSortMode)
            return SortMode(rawValue: payload) ?? .modifiedNewest
        }
        set {
            defaults.set(newValue.rawValue, forKey: .notesListSortMode)
            NotificationCenter.default.post(name: .NoteListSortModeDidChange, object: nil)
        }
    }

    /// Theme Name: Null indicates that the system's default theme should be picked
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


// MARK: - Migrations
//
private extension Options {

    func migrateLegacyOptions() {
        guard defaults.containsObject(forKey: .notesListSortMode) == false else {
            return
        }

        let legacySortAlphabetically = defaults.bool(forKey: .notesListSortModeLegacy)
        let newMode: SortMode = legacySortAlphabetically ? .alphabeticallyAscending : .modifiedNewest

        defaults.set(newMode.rawValue, forKey: .notesListSortMode)
        defaults.removeObject(forKey: .notesListSortModeLegacy)
    }
}
