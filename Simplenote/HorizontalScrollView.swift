import Foundation
import Cocoa


// MARK: - HorizontalScrollView
//          This NSScrollView subclass remaps Vertical Scroll events into Horizontal Scroll events, in order to
//          support ScrollWheel events performed with a mouse (single axis device!).
//
class HorizontalScrollView: NSScrollView {

    override func scrollWheel(with event: NSEvent) {
        /// Whenever the scroll event happens on the Y axis, we'll generate a new Scroll Event, instead, and we'll remap the deltaY.
        /// Why: we need to support Scroll Wheel events, performed with a mouse (with a single axis).
        ///
        guard (abs(event.deltaX) <= abs(event.deltaY)), let cgEvent = event.cgEvent?.copy() else {
            super.scrollWheel(with: event)
            return
        }

        cgEvent.setIntegerValueField(.scrollWheelEventDeltaAxis2, value: Int64(event.deltaY))

        guard let darkEvent: NSEvent = NSEvent(cgEvent: cgEvent) else {
            super.scrollWheel(with: event)
            return
        }

        super.scrollWheel(with: darkEvent)
    }

    /// Notes:
    ///  1.     Since we're overriding `scrollWheel:` we must set the `horizontalScroller.hidden = NO`. Otherwise scrolling won't work.
    ///  2.     In this override we're making sure the NSScroller does not affect layout!
    ///
    ///  References:
    ///     https://developer.apple.com/reference/appkit/nsview#//apple_ref/occ/clm/NSView/isCompatibleWithResponsiveScrolling
    ///     https://stackoverflow.com/questions/31186430/scrolling-in-nsscrollview-stops-when-overwriting-scrollwheel-function
    ///
    override func tile() {
        super.tile()
        contentView.frame = bounds
        horizontalScroller?.isHidden = true
    }

    /// Scrolls to the left-most edge
    ///
    func resetScrollPosition() {
        let target = NSPoint(x: contentView.contentInsets.left * -1, y: .zero)
        contentView.setBoundsOrigin(target)
    }
}
