//
//  DefaultBackgroudView.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/27/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPBackgroundView.h"
#import "NSColor+Simplenote.h"
#import "VSThemeManager.h"

@implementation SPBackgroundView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    [[[[VSThemeManager sharedManager] theme] colorForKey:@"tableViewBackgroundColor"] setFill];
    NSRectFill(dirtyRect);
}

@end
