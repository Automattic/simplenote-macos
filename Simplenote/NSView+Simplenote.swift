import Foundation


// MARK: - NSView + Simplenote Methods
//
extension NSView {

    /// Returns the absolute location onscreen.
    /// - Note: If the window cannot be unwrapped, will simply return the location in the "top superview"
    ///
    var locationInScreen: NSPoint {
        let maximumLocation = NSPoint(x: bounds.maxX, y: bounds.maxY)
        let locationInWindow = convert(maximumLocation, to: nil)

        return window?.convertPoint(toScreen: locationInWindow) ?? locationInWindow
    }
}
