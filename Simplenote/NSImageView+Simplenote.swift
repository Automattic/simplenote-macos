import Foundation


// MARK: - NSImageView+ Simplenote
//
extension NSImageView {

    /// Tints the stored image with the specified color
    ///
    func tintImage(color: NSColor) {
        if #available(macOS 10.14, *) {
            contentTintColor = color
            return
        }

        image = image?.tinted(with: color)
    }
}
