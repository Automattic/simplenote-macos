import Foundation


// MARK - Simplenote Methods
//
extension NSAppearance {

    /// Indicates if the receiver is on the Dark Side
    ///
    var isDark: Bool {
        name == .darkAqua || name == .vibrantDark
    }

    /// Returns the NSAppearance that matches Simplenote's Settings
    ///
    @objc
    static var simplenoteAppearance: NSAppearance? {
        let name: NSAppearance.Name = SPUserInterface.isDark ? .vibrantDark : .aqua
        return NSAppearance(named: name)
    }
}
