//
//  NSColor+Simplenote.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 12/16/14.
//  Copyright (c) 2014 Simperium. All rights reserved.
//

#import "NSColor+Simplenote.h"


@implementation NSColor (Simplenote)

+ (NSColor *)colorForNoteSeparator
{
    return [NSColor colorWithCalibratedRed:220.0/255.0
                                     green:220.0/255.0
                                      blue:220.0/255.0
                                     alpha:1.0f];
}

+ (NSColor *)colorForCellSelection
{
    return [NSColor colorWithCalibratedRed:165.0/255.0
                                     green:190.0/255.0
                                      blue:234.0/255.0
                                     alpha:1.0f];
}

@end
