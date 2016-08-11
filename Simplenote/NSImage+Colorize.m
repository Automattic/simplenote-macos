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

+ (NSImage *)imageNamed:(NSString *)imageName colorizeWithColor:(NSColor *)color
{
    NSImage *image = [[NSImage imageNamed:imageName] copy];
    NSRect iconRect = NSMakeRect(0.0, 0.0, image.size.width, image.size.height);
    [image lockFocus];
    [color set];
    NSRectFillUsingOperation(iconRect, NSCompositeSourceAtop);
    [image unlockFocus];
    [image drawInRect:iconRect fromRect:iconRect operation:NSCompositeSourceOver fraction:0.75];
    
    return image;
}

@end
