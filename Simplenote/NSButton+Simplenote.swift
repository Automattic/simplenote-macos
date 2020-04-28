import Foundation


// MARK: - NSImageView+ Simplenote
//
extension NSButton {

    /// Tints the stored image with the specified color
    ///
    @objc
    func tintImage(color: NSColor) {
        if #available(macOS 10.14, *) {
            contentTintColor = color
            return
        }

        image = image?.tinted(with: color)
    }
}
