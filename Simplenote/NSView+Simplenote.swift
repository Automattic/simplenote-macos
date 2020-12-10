import Foundation


// MARK: - NSView + Simplenote
//
extension NSView {

    var isFirstResponder: Bool {
        window?.firstResponder == self
    }
}
