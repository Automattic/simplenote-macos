import Foundation


// MARK: - NSBezierPath + Simplenote
//
extension NSBezierPath {

    /// Initializes a Bezier Path that only renders the specified corners as rounded
    ///
    convenience init(roundedRect rect: NSRect, byRoundingCorners corners: RectCorner, radius: CGFloat) {
        self.init()

        let maximumRadius = min(rect.width, rect.height) * 0.5
        let targetRadius = min(max(radius, 0), maximumRadius)

        let origin = NSPoint(x: rect.minX, y: rect.minY + targetRadius)
        let topLeftOrigin = NSPoint(x: rect.minX, y: rect.minY)
        let topLeftRadius = corners.contains(.topLeft) ? targetRadius : .zero

        let topRightOrigin = NSPoint(x: rect.maxX, y: rect.minY)
        let topRightRadius = corners.contains(.topRight) ? targetRadius : .zero

        let bottomRightOrigin = NSPoint(x: rect.maxX, y: rect.maxY)
        let bottomRightRadius = corners.contains(.bottomRight) ? targetRadius : .zero

        let bottomLeftOrigin = NSPoint(x: rect.minX, y: rect.maxY)
        let bottomLeftRadius = corners.contains(.bottomLeft) ? targetRadius : .zero

        move(to: origin)
        appendArc(from: topLeftOrigin,      to: topRightOrigin,     radius: topLeftRadius)
        appendArc(from: topRightOrigin,     to: bottomRightOrigin,  radius: topRightRadius)
        appendArc(from: bottomRightOrigin,  to: bottomLeftOrigin,   radius: bottomRightRadius)
        appendArc(from: bottomLeftOrigin,   to: topLeftOrigin,      radius: bottomLeftRadius)
        close()
    }
}


// MARK: - RectCorner
//
struct RectCorner: OptionSet {
    let rawValue: UInt
}

extension RectCorner {
    static let topLeft      = RectCorner(rawValue: 1 << 1)
    static let topRight     = RectCorner(rawValue: 1 << 2)
    static let bottomLeft   = RectCorner(rawValue: 1 << 3)
    static let bottomRight  = RectCorner(rawValue: 1 << 4)
}
