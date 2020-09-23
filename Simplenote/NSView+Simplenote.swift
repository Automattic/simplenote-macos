import Foundation


// MARK: - NSView + Simplenote Methods
//
extension NSView {

    /// Converts the specified NSRect into Screen Coordinates
    /// - Note: The `rect` is assumed to be in the receiver's coordinate system. Capisce?
    ///
    func convertToScreen(_ rect: NSRect) -> NSRect {
        let windowCoordinates = convert(rect, to: nil)
        guard let window = window else {
            return windowCoordinates
        }

        return window.convertToScreen(windowCoordinates)
    }
}
