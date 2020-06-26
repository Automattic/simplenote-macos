import Foundation
import AppKit


// MARK: - MetricsWindowController
//
class MetricsWindowController: NSWindowController {

    /// Closure to be executed  whenever the window is about to be dismissed
    ///
    var onClose: (() -> Void)?
}


// MARK: - NSWindowDelegate
//
extension MetricsWindowController: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        onClose?()
    }
}
