import Foundation

// MARK: - Represents a Theme Menu Option
//
enum ThemeOption: Int, CaseIterable {
    case light = 0
    case dark = 1
    case system = 2
}

// MARK: - Properties
//
extension ThemeOption {

    /// Returns the Tag name associated with a given Theme
    ///
    var themeName: String? {
        switch self {
        case .light:
            return "default"
        case .dark:
            return "dark"
        case .system:
            return nil
        }
    }

    /// Description for each theme option
    var description: String {
        switch self {
        case .light:
            return NSLocalizedString("Light", comment: "Light theme name")
        case .dark:
            return NSLocalizedString("Dark", comment: "Dark theme name")
        case .system:
            return NSLocalizedString("System Appearance", comment: "Default system theme name")
        }
    }
}
