import Foundation


// MARK - Simplenote Methods
//
extension NSAppearance {

    /// Indicates if the receiver is on the Dark Side
    ///
    @available(OSX 10.14, *)
    var isDark: Bool {
        name == .darkAqua
    }
}
