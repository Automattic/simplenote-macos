#import "SPHorizontalScrollView.h"

@implementation SPHorizontalScrollView

- (void)scrollWheel:(NSEvent *)event
{
    /// Whenever the scroll event happens on the Y axis, we'll generate a new Scroll Event, instead, and we'll remap the deltaY.
    /// Why: we need to support Scroll Wheel events, performed with a mouse (with a single axis).
    ///
    if (fabs(event.deltaX) > fabs(event.deltaY)) {
        [super scrollWheel:event];
        return;
    }

    CGEventRef cgEvent = CGEventCreateCopy(event.CGEvent);
    CGEventSetIntegerValueField(cgEvent, kCGScrollWheelEventDeltaAxis2, event.deltaY);

    NSEvent *darkEvent = [NSEvent eventWithCGEvent:cgEvent];
    CFRelease(cgEvent);

    [super scrollWheel:darkEvent];
}

- (void)tile
{
    /// Notes:
    ///  1.     Since we're overriding `scrollWheel:` we must set the `horizontalScroller.hidden = NO`. Otherwise scrolling won't work.
    ///  2.     In this override we're making sure the NSScroller does not affect layout!
    ///
    ///  References:
    ///     https://developer.apple.com/reference/appkit/nsview#//apple_ref/occ/clm/NSView/isCompatibleWithResponsiveScrolling
    ///     https://stackoverflow.com/questions/31186430/scrolling-in-nsscrollview-stops-when-overwriting-scrollwheel-function
    ///
    [super tile];
    [self.contentView setFrame:self.bounds];
    [self.horizontalScroller setHidden:YES];
}

@end
