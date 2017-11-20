//
//  NSObject+Simplenote.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 5/13/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "NSObject+Simplenote.h"
#import <objc/runtime.h>


@implementation NSObject (Simplenote)

+ (BOOL)sp_respondsToSelector:(SEL)aSelector
{
    return [self respondsToSelector:aSelector];
}

@end
