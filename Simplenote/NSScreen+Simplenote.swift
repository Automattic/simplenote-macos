import Foundation


// MARK: - NSScreen Simplenote Methods
//
extension NSScreen {

    /// Returns the ratio between 1 point and 1 pixel in the current device.
    ///
    @objc
    var pointToPixelRatio: CGFloat {
        return 1.0 / backingScaleFactor
    }
}
