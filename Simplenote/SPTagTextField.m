//
//  SPTagTextField.m
//  Simplenote
//
//  Created by Michael Johnston on 7/25/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPTagTextField.h"

@implementation SPTagTextField

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setDelegate:(id<NSTextFieldDelegate>)anObject
{
    [super setDelegate:anObject];
}

- (BOOL)resignFirstResponder
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return [self.delegate control:self textShouldBeginEditing:self.currentEditor];
}

@end
