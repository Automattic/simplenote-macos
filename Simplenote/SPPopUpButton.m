//
//  SPPopUpButton.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 4/27/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "SPPopUpButton.h"
#import "SPPopUpButtonCell.h"

@implementation SPPopUpButton

+ (Class)cellClass
{
    return [SPPopUpButtonCell class];
}

@end
