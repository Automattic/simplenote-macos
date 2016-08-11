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
    if ([event type] == NSKeyDown) {
        if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) {
            if ([[event charactersIgnoringModifiers] isEqualToString:@"l"]) {
                if ([self sendAction:@selector(searchAction:) to:nil from:self])
                    return;
            }
        }
    }
    [super sendEvent:event];
}

@end
