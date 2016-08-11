//
//  NSView+Simplenote.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 9/2/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "NSView+Simplenote.h"

@implementation NSView (Simplenote)

- (BOOL)sp_isFirstResponder
{
    // I can't believe AppKit doesn't have this
    return self.window.firstResponder == self;
}

@end
