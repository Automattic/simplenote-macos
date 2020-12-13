import Foundation


// MARK: - NSBox.BoxType
//
extension NSBox.BoxType {

    /// Sidebar Box Type: We'll disable Desktop Tinting whenever we're in Light Mode
    ///
    static var simplenoteSidebarBoxType: NSBox.BoxType {
        SPUserInterface.isDark ? .primary : .custom
    }
}
