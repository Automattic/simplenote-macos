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

    /// Returns the MaximumLocation.x for the Window's Semaphore (Close / Minimize / Zoom)
    ///
    var semaphoreMaximumLocationX: CGFloat? {
        let types: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
        let locations = types.compactMap { standardWindowButton($0)?.frame.maxX }

        return locations.max()
    }
}
