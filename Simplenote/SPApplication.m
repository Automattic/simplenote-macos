//
//  SPApplication.m
//  Simplenote
//
//  Created by Michael Johnston on 6/27/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPApplication.h"

@implementation SPApplication

- (void)sendEvent:(NSEvent *)event
{
    if ([event type] == NSEventTypeKeyDown) {
        if (([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask) == NSEventModifierFlagCommand) {
            if ([[event charactersIgnoringModifiers] isEqualToString:@"l"]) {
                if ([self sendAction:@selector(searchWasPressed:) to:nil from:self])
                    return;
            }
        }
    }
    [super sendEvent:event];
}

@end
