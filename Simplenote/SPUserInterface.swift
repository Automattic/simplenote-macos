import Foundation
import AppKit


// MARK: - Simplenote's Theme
//
@objcMembers
class SPUserInterface: NSObject {

    /// Ladies and gentlemen, this is a singleton.
    ///
    static let shared = SPUserInterface()

    /// Indicates if the User Interface is in Dark Mode
    ///
    static var isDark: Bool {
        guard isSystemThemeSelected else {
            return Options.shared.theme == "dark"
        }

        return isSystemInDarkMode
    }

    /// Indicates if the System Theme is selected: Starting from +10.14, whenever the theme's name is nil
    ///
    static var isSystemThemeSelected: Bool {
        guard #available(macOS 10.14, *) else {
            return false
        }

        return Options.shared.theme == nil
    }

    /// Indicates if macOS is in Dark Mode
    ///
    static var isSystemInDarkMode: Bool {
        guard #available(macOS 10.14, *) else {
            return false
        }

        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
}

