//
//  NSApplication+Helpers.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 12/15/14.
//  Copyright (c) 2014 Simperium. All rights reserved.
//

#import "NSApplication+Helpers.h"

@implementation NSApplication (Helpers)

+ (BOOL)isRunningYosemiteOrHigher
{
    return floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9;
}

+ (BOOL)isRunningMavericksOrLower
{
    return floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9;
}

@end
