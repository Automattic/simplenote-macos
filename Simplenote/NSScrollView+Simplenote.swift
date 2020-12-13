import Foundation
import AppKit


// MARK: - NSScrollView + Simplenote
//
extension NSScrollView {

    @objc
    func scrollToTop() {
        let target = NSPoint(x: .zero, y: contentView.contentInsets.top * -1)
        documentView?.scroll(target)
    }
}
