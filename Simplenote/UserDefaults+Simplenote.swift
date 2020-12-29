import Foundation


// MARK: - Simplenote UserDefaults Keys
//
extension UserDefaults {
    enum Key: String {
        case alphabeticallySortTags = "kTagSortPreferencesKey"
        case analyticsEnabled
        case editorFullWidth = "kEditorWidthPreferencesKey"
        case initialSetupComplete = "SPFirstLaunch"
        case lastKnownVersion
        case notesListCondensed = "kPreviewLinesPref"
        case notesListSortMode
        case notesListSortModeLegacy = "kAlphabeticalSortPreferencesKey"
        case themeName = "VSThemeManagerThemePrefKey"
    }
}


// MARK: - Convenience Methods
//
extension UserDefaults {

    /// Returns the Booolean associated with the specified Key.
    ///
    func bool(forKey key: Key) -> Bool {
        return bool(forKey: key.rawValue)
    }

    /// Returns the Integer (if any) associated with the specified Key.
    ///
    func integer(forKey key: Key) -> Int {
        return integer(forKey: key.rawValue)
    }

    /// Returns the Object (if any) associated with the specified Key.
    ///
    func object<T>(forKey key: Key) -> T? {
        return value(forKey: key.rawValue) as? T
    }

    /// Returns the String (if any) associated with the specified Key.
    ///
    func string(forKey key: Key) -> String? {
        return value(forKey: key.rawValue) as? String
    }

    /// Stores the Key/Value Pair.
    ///
    func set<T>(_ value: T?, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }

    /// Nukes any object associated with the specified Key.
    ///
    func removeObject(forKey key: Key) {
        removeObject(forKey: key.rawValue)
    }

    /// Indicates if there's an entry for the specified Key.
    ///
    func containsObject(forKey key: Key) -> Bool {
        return value(forKey: key.rawValue) != nil
    }

    /// Subscript Accessible via our new Key type!
    ///
    subscript<T>(key: Key) -> T? {
        get {
            return value(forKey: key.rawValue) as? T
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    /// Subscript: "Type Inference Fallback". To be used whenever the type cannot be automatically inferred!
    ///
    subscript(key: Key) -> Any? {
        get {
            return value(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }
}
