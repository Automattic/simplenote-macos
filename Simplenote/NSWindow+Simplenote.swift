import Foundation
import AppKit


// MARK: - NSWindow + Simplenote
//
extension NSWindow {

    func move(below view: NSView) {
        let source = view.locationInScreen
        let origin = NSPoint(x: source.x - frame.width, y: source.y - frame.height)
        setFrameOrigin(origin)
    }
}
