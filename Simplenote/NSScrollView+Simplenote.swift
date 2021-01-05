import Foundation
import AppKit


// MARK: - NSScrollView + Simplenote
//
extension NSScrollView {

    @objc(scrollToTopWithAnimation:)
    func scrollToTop(animated: Bool = false) {
        let target = NSPoint(x: .zero, y: contentView.contentInsets.top * -1)

        if animated {
            contentView.animator().setBoundsOrigin(target)
            return
        }

        documentView?.scroll(target)
    }
}
