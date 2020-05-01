//
//  DefaultBackgroudView.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/27/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPBackgroundView.h"
#import "Simplenote-Swift.h"

@implementation SPBackgroundView

- (void)setFillColor:(NSColor *)fillColor
{
    _fillColor = fillColor;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if (!self.fillColor) {
        return;
    }

    [self.fillColor setFill];
    NSRectFill(dirtyRect);
}

@end
