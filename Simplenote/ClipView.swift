import Foundation


// MARK: - ClipView
//
class ClipView: NSClipView {

    /// Extra ContentInsets to be applied over the default `contentInsets``
    ///
    var extendedContentInsets = NSEdgeInsetsZero {
        didSet {
            needsLayout = true
        }
    }


    // MARK: - Overridden

    override var contentInsets: NSEdgeInsets {
        get {
            var insets = super.contentInsets
            insets.top    += extendedContentInsets.top
            insets.bottom += extendedContentInsets.bottom
            insets.left   += extendedContentInsets.left
            insets.right  += extendedContentInsets.right
            return insets
        }
        set {
            super.contentInsets = newValue
        }
    }
}
