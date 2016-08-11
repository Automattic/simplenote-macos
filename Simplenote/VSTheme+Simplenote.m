//
//  VSTheme+Simplenote.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 4/30/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "VSTheme+Simplenote.h"

@implementation VSTheme (Simplenote)

- (BOOL)isDark
{
    static NSString *SPDarkThemeKey = @"dark";
    return [self boolForKey:SPDarkThemeKey];
}

@end
