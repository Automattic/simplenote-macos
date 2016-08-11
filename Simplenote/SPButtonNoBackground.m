//
//  BackgroundlessButton.m
//  Simplenote
//
//  Created by Tom Witkin on 7/6/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPButtonNoBackground.h"

@implementation SPButtonNoBackground

- (void)drawRect:(NSRect)dirtyRect
{
    [self setBordered:NO];
    [super drawRect:dirtyRect];
}

@end
