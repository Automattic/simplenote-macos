import Foundation
import AppKit

// MARK: - NSScrollView + Simplenote
//
extension NSScrollView {

    /// Indicates if we're at the upper edge of the contents
    ///
    var isScrolledToTop: Bool {
        contentView.bounds.origin.y == contentView.contentInsets.top * -1
    }

    /// Scrolls the receiver to the upper edge
    ///
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
