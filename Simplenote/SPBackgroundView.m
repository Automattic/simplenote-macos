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

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    [[NSColor simplenoteBackgroundColor] setFill];
    NSRectFill(dirtyRect);
}

@end
