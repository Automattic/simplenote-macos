import Foundation
import AppKit


// MARK: - Simplenote's Theme
//
class SPUserInterface: NSObject {

    /// Ladies and gentlemen, this is a singleton.
    ///
    @objc
    static let shared = SPUserInterface()

    /// Indicates if the User Interface is in Dark Mode
    ///
    @objc
    static var isDark: Bool {
        guard isSystemThemeSelected else {
            return Options.shared.themeName == ThemeOption.dark.themeName
        }

        return isSystemInDarkMode
    }

    /// Indicates if the System Theme is selected: Starting from +10.14, whenever the theme's name is nil
    ///
    @objc
    static var isSystemThemeSelected: Bool {
        guard #available(macOS 10.14, *) else {
            return false
        }

        return Options.shared.themeName == nil
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


// MARK: - Helpers
//
extension SPUserInterface {

    /// Returns the active ThemeOption, based on the `Options.theme` status (and / or) macOS's Dark Mode Status
    ///
    static var activeThemeOption: ThemeOption {
        if isSystemThemeSelected {
            return .system
        }

        return isDark ? .dark : .light
    }
}
