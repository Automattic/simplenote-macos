import Foundation


// MARK: - Represents a Theme Menu Option
//
enum ThemeOption: Int {
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
}
