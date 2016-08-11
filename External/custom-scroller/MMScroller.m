//
//  MMScroller.m
//  MiniMail
//
//  Created by DINH Viêt Hoà on 21/02/10.
//  Copyright 2011 Sparrow SAS. All rights reserved.
//

#import "MMScroller.h"
#import "MMDrawingUtils.h"
#import "VSThemeManager.h"

@interface MMScroller ()

- (void) _showKnob;
- (void) _updateKnob;
- (void) _updateKnobAfterDelay;

@end

@implementation MMScroller

@synthesize shouldClearBackground = _shouldClearBackground;

static CGFloat MNScrollerFrameCount = 10.f;
static CGFloat MNScrollerDelay = 0.3f;

- (id) initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	
	_oldValue = -1;
	
	return self;
}

- (void) dealloc
{
    for (NSTrackingArea *area in [self trackingAreas]) {
		[self removeTrackingArea:area];
    }
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super dealloc];
}

- (void)drawKnob
{
	CGFloat alphaValue;
	
	alphaValue = 0.5 * (float) _animationStep / (float) MNScrollerFrameCount;
    if ([self bounds].size.width < [self bounds].size.height) {
        NSColor *knobColor = [[[[VSThemeManager sharedManager] theme]
                               colorForKey:@"textColor"] colorWithAlphaComponent:alphaValue];
        [knobColor setFill];
        NSRect rect = [self rectForPart:NSScrollerKnob];
        rect.size.width = 6;
        rect.origin.x += 0;
        rect.origin.x += 6.0;
        MMFillRoundedRect(rect, 4, 4);
    }
    else {
        // horiz scrollbar
        [[NSColor colorWithCalibratedWhite:0.0 alpha:alphaValue] setFill];
        NSRect rect = [self rectForPart:NSScrollerKnob];
        rect.size.height = 6;
        rect.origin.y += 0;
        rect.origin.y += 6.0;
        MMFillRoundedRect(rect, 4, 4);
    }
}

- (void) drawRect:(NSRect)rect
{
    if (_shouldClearBackground) {
        NSEraseRect([self bounds]);
    }
    
	[self drawKnob];
}

- (void) setFloatValue:(float)value
{
	[super setFloatValue:value];
	if (_oldValue != value) {
		[self _showKnob];
		_oldValue = value;
	}
}

- (void) showScroller
{
    [self _showKnob];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	[super mouseMoved:theEvent];
	[self _showKnob];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	[super mouseEntered:theEvent];
	_animationStep = MNScrollerFrameCount;
	_disableFade = YES;
	[self _updateKnob];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	[super mouseExited:theEvent];
    [self _showKnob];
}

- (void) updateTrackingAreas
{
	NSTrackingArea * trackingArea;
	
    for (NSTrackingArea *area in [self trackingAreas]) {
		[self removeTrackingArea:area];
    }
	
	trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingMouseMoved owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	[trackingArea release];
}

- (void) _showKnob
{
	_animationStep = MNScrollerFrameCount;
    _disableFade = YES;
	[self _updateKnob];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_showKnobAfterDelay) object:nil];
    [self performSelector:@selector(_showKnobAfterDelay) withObject:nil afterDelay:0.5];
}

- (void) _showKnobAfterDelay
{
    _disableFade = NO;
	_animationStep = MNScrollerFrameCount;
	if (!_scheduled) {
		[self _updateKnob];
	}
}

- (void) _updateKnob
{
	[self setNeedsDisplay:YES];
	
	if (_animationStep > 0) {
		if (!_disableFade) {
			if (!_scheduled) {
				_scheduled = YES;
				[self performSelector:@selector(_updateKnobAfterDelay) withObject:nil afterDelay:MNScrollerDelay / MNScrollerFrameCount];
				_animationStep --;
			}
		}
	}
}

- (void) _updateKnobAfterDelay
{
	_scheduled = NO;
	[self _updateKnob];
}

@end
