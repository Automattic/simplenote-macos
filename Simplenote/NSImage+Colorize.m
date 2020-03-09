//
//  NSImage+Colorize.m
//  Simplenote
//
//  Created by Michael Johnston on 7/14/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "NSImage+Colorize.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSImage (Colorize)

- (NSImage *)colorizedWithColor:(NSColor *)color
{
    NSImage *image = [self copy];
    NSRect iconRect = NSMakeRect(0.0, 0.0, image.size.width, image.size.height);
    [image lockFocus];
    [color set];
    NSRectFillUsingOperation(iconRect, NSCompositingOperationSourceAtop);
    [image unlockFocus];
    [image drawInRect:iconRect fromRect:iconRect operation:NSCompositingOperationSourceOver fraction:0.75];
    
    return image;
}

@end
