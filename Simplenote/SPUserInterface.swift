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
        if isSystemThemeSelected {
            return isSystemInDarkMode
        }

        return Options.shared.themeName == ThemeOption.dark.themeName
    }

    /// Indicates if the System Theme is selected: Starting from +10.14, whenever the theme's name is nil
    ///
    @objc
    static var isSystemThemeSelected: Bool {
        return Options.shared.themeName == nil
    }

    /// Indicates if macOS is in Dark Mode
    ///
    static var isSystemInDarkMode: Bool {
        /// Note:
        ///  -   Yes. We must restort to UserDefaults to check if the system is in Dark Mode.
        ///  -   Reason: `NSApp.effectiveAppearance.isDark` might fall out of sync, in specific conditions, such as...
        ///         1.  systemAppearance setting in Simplenote
        ///         2.  Switching back and forth from Light / Dark (macOS 10.15)
        ///
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
