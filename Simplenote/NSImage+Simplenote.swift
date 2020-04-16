import Foundation


// MARK: - NSImage + Simplenote
//
extension NSImage {

    /// Returns a copy of the receiver, tinted with the specified color
    ///
    @objc(tintedWithColor:)
    func tinted(with color: NSColor) -> NSImage {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return self
        }

        return NSImage(size: size, flipped: false) { bounds in
            guard let context = NSGraphicsContext.current?.cgContext else {
                return false
            }

            color.set()
            context.clip(to: bounds, mask: cgImage)
            context.fill(bounds)

            return true
        }
    }
}
