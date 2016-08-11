//
//  SPPopUpButtonCell.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 4/27/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "SPPopUpButtonCell.h"

static NSSize const SPPopUpButtonArrowSize  = {7.0f, 3.0f};
static CGFloat const SPPopUpButtonLineWidth = 1.5f;


@implementation SPPopUpButtonCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.arrowColor     = [NSColor blackColor];
    }
    return self;
}

- (void)drawBorderAndBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (!self.arrowColor) {
        return;
    }
    
    NSBezierPath *path      = [[NSBezierPath alloc] init];
    path.lineWidth          = SPPopUpButtonLineWidth;
    
    NSRect drawFrame        = cellFrame;
    drawFrame.origin.x      = (NSWidth(drawFrame) - SPPopUpButtonArrowSize.width) * 0.5f;
    drawFrame.origin.y      = (NSHeight(drawFrame) - SPPopUpButtonArrowSize.height) * 0.5f;
    drawFrame.size.width    = SPPopUpButtonArrowSize.width;
    drawFrame.size.height   = SPPopUpButtonArrowSize.height;
    drawFrame               = NSIntegralRect(drawFrame);
    
    NSPoint p1 = NSMakePoint(NSMinX(drawFrame), NSMinY(drawFrame));
    NSPoint p2 = NSMakePoint(NSMidX(drawFrame), NSMaxY(drawFrame));
    NSPoint p3 = NSMakePoint(NSMaxX(drawFrame), NSMinY(drawFrame));
    
    [path moveToPoint:p1];
    [path lineToPoint:p2];
    [path lineToPoint:p3];
    
    [self.arrowColor setStroke];
    [path stroke];
}

@end
