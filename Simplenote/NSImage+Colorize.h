//
//  NSImage+Colorize.h
//  Simplenote
//
//  Created by Michael Johnston on 7/14/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Colorize)

+ (NSImage *)imageNamed:(NSString *)imageName colorizeWithColor:(NSColor *)color;

@end
