import Foundation


// MARK: - NSClipView
//
class ClipView: NSClipView {

    /// ClipView's default `hitTest` implementation returns `nil` whenever a view, **although visible**, falls within the area
    /// defined by the `contentInsets.top`.
    ///
    /// In this subclass we're simply forwarding the click event to the subclasses, when appropriate.
    ///
    override func hitTest(_ point: NSPoint) -> NSView? {
        if let subview = super.hitTest(point) {
            return subview
        }

        if point.y >= contentInsets.top {
            return nil
        }


        for subview in subviews {
            let translated = convert(point, to: subview)
            guard let result = subview.hitTest(translated) else {
                continue
            }

            return result
        }

        return nil
    }
}
