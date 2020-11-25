import Foundation
import AppKit


// MARK: - NSScrollView + Simplenote
//
extension NSScrollView {

    @objc
    func scrollToTop() {
        let yOffset = contentView.bounds.origin.y - contentView.contentInsets.top
        let target = NSPoint(x: .zero, y: yOffset)
        documentView?.scroll(target)
    }
}
