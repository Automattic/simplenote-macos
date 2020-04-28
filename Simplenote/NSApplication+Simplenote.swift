import Foundation


// MARK: - Simplenote Methods
//
extension NSApplication {

    /// Indicates if we're running on macOS 10.14 or greater
    ///
    @objc
    static var runningOnMojaveOrLater: Bool {
        guard #available(macOS 10.14, *) else {
            return false
        }

        return true
    }
}
