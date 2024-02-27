import Foundation

// MARK: - NSWindow + Simplenote
//
extension NSWindow {

    /// Indicates if the receiver is in Fullscreen
    ///
    var isFullscreen: Bool {
        styleMask.contains(.fullScreen)
    }

    /// Indicates if we're in RTL mode
    ///
    var isRTL: Bool {
        windowTitlebarLayoutDirection == .rightToLeft
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

    /// Returns the Horizontal Padding required in order to prevent overlaps between our controls and the Window's Semaphore
    /// - Note:
    ///     - Fullscreen: zero padding
    ///     - LTR: Semaphore's Maximum horizontal position
    ///     - RTL: Window's Width minus the Semaphore's Minimum horizontal location
    ///
    var semaphorePaddingX: CGFloat {
        guard isFullscreen == false, let semaphoreBounds = semaphoreBoundingRect else {
            return .zero
        }

        return isRTL ? (frame.width - semaphoreBounds.minX) : semaphoreBounds.maxX
    }

    /// Returns the Titlebar's Rect 
    ///
    var titlebarRect: NSRect {
        let layoutRect = contentLayoutRect
        return NSRect(x: layoutRect.minX, y: layoutRect.maxY, width: layoutRect.width, height: frame.height - layoutRect.height)
    }
}
