//
//  NSString+Simplenote.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 5/13/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "NSString+Simplenote.h"

@implementation NSString (Simplenote)

- (BOOL)sp_containsString:(NSString *)aString
{
    NSRange range = [self rangeOfString:aString];
    return range.location != NSNotFound;
}

@end
