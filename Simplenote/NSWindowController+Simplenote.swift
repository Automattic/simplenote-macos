import Foundation
import AppKit


// MARK: - NSWindowController Simplenote Methods
//
extension NSWindowController {

    /// Returns an instance of the receiver, instantiated from the specified Storyboard
    ///
    static func instantiate<T: NSWindowController>(fromStoryboardNamed name: NSStoryboard.Name) -> T {
        guard let output = NSStoryboard(name: name, bundle: nil).instantiateInitialController() as? T else {
            fatalError()
        }

        return output
    }

    /// Displays the receiver's window at the left hand side of the specified point
    ///
    func showWindow(by point: NSPoint) {
        guard let window = window else {
            fatalError()
        }

        let origin = NSPoint(x: point.x - window.frame.width, y: point.y - window.frame.height)
        window.setFrameOrigin(origin)
        showWindow(nil)
    }
}
