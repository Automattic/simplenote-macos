//
//  MMScrollView.m
//  MiniMail
//
//  Created by DINH Viêt Hoà on 24/08/10.
//  Copyright 2011 Sparrow SAS. All rights reserved.
//

#import "MMScrollView.h"

@implementation MMScrollView

- (void) tile
{
	NSRect frame;
	CGFloat height;
    
	[[self contentView] setFrame:[self bounds]];
    height = [self bounds].size.height;
	frame = NSMakeRect([self bounds].size.width - 15, 0, 15, height);
	[[self verticalScroller] setFrame:frame];


    // The following (legacy) workaround triggers a layout loop in 10.12. Disabling this behavior for 10.12 and upwards.
    // Ref. https://github.com/Automattic/simplenote-macos/issues/369
    //
    if (@available(macOS 10.12, *)) {
        return;
    }

	[[self verticalScroller] retain];
	[[self verticalScroller] removeFromSuperview];
	[self addSubview:[self verticalScroller]];
	[[self verticalScroller] release];
}

@end
