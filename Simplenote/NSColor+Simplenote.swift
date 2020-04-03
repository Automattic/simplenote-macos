import Foundation


// MARK: - HTML Colors
//
extension NSColor {

    private static let defaultAlpha = CGFloat(1.0)

    /// Initializes a new UIColor instance with the specified HexString Code.
    ///
    convenience init(hexString: String, alpha: CGFloat = defaultAlpha) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = .zero
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}
