//
//  NSApplication+Helpers.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 12/15/14.
//  Copyright (c) 2014 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSApplication (Helpers)

+ (BOOL)isRunningYosemiteOrHigher;
+ (BOOL)isRunningMavericksOrLower;

@end
