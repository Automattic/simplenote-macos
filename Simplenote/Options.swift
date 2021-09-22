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
            defaults.bool(forKey: .editorFullWidth, defaultValue: true)
        }
        set {
            defaults.set(newValue, forKey: .editorFullWidth)
            NotificationCenter.default.post(name: .EditorDisplayModeDidChange, object: nil)
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
            return defaults.integer(forKey: .notesListSortMode).flatMap { mode in
                SortMode(rawValue: mode)
            } ?? .modifiedNewest
        }
        set {
            defaults.set(newValue.rawValue, forKey: .notesListSortMode)
            NotificationCenter.default.post(name: .NoteListSortModeDidChange, object: nil)
        }
    }

    /// StatusBar
    ///
    @objc
    var statusBarHidden: Bool {
        get {
            defaults.bool(forKey: .statusBarHidden)
        }
        set {
            defaults.set(newValue, forKey: .statusBarHidden)
            NotificationCenter.default.post(name: .StatusBarDisplayModeDidChange, object: nil)
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

    /// Font Size
    ///

    var fontSize: Int {
        get {
            defaults.integer(forKey: .fontSize) ?? Constants.normalFontSize
        }
        set {
            defaults.set(newValue, forKey: .fontSize)
            SPTracker.trackSettingsFontSizeUpdated()
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

private struct Constants {
    static let normalFontSize = 14
}
