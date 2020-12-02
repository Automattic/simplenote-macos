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

    /// Returns the Bounding Rect for the Window's Semaphore (Close / Minimize / Zoom)
    ///
    var semaphoreBoundingRect: CGRect? {
        let types: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
        var bounds: CGRect?

        for type in types {
            guard let buttonFrame = standardWindowButton(type)?.frame else {
                continue
            }

            guard let oldBounds = bounds else {
                bounds = buttonFrame
                continue
            }

            var newBounds = oldBounds.union(buttonFrame)
            newBounds.origin.y = min(newBounds.origin.y, buttonFrame.origin.y)
            newBounds.origin.x = min(newBounds.origin.x, buttonFrame.origin.x)
            bounds = newBounds
        }

        return bounds
    }
}
