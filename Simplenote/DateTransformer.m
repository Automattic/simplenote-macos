//
//  DateTransformer.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/28/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "DateTransformer.h"
@import Simperium_OSX;

@implementation DateTransformer

+ (Class)transformedValueClass
{
    return [NSDate class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value {
    if (value != nil) {
        return [value sp_stringBeforeNow];
    }
    
    return @"No Date";
}

@end
