import Foundation


// MARK: - NSWindow + Simplenote
//
extension NSWindow {

    /// Returns the receiver's TitleBar Height
    /// - Important: The SDK has a private API named `titlebarHeight`, and we `actually MUST` to namespace this..
    ///
    @objc
    var simplenoteTitlebarHeight: CGFloat {
        frame.height - contentLayoutRect.height
    }
}
