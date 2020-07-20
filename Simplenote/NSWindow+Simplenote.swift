import Foundation


// MARK: - NSWindow + Simplenote
//
extension NSWindow {

    /// Returns the receiver's TitleBar Height
    ///
    var titlebarHeight: CGFloat {
        frame.height - contentLayoutRect.height
    }
}
