//
//  CustomTokenField.m
//  Simplenote
//
//  Created by Rainieri Ventura on 4/8/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPTokenField.h"

@interface SPTokenField()
@property (nonatomic, strong) NSArray *tokenCopies;
@end

@implementation SPTokenField

- (void)textDidBeginEditing:(NSNotification *)aNotification
{
    [super textDidBeginEditing:aNotification];
    self.tokenCopies = [self.objectValue copy];
}

- (void)textDidChange:(NSNotification *)obj
{
    [super textDidChange:obj];
    NSUInteger numTokens = [self.objectValue count];
    NSUInteger previousNumTokens = [self.tokenCopies count];

    if (previousNumTokens > numTokens) {
        if ([[self delegate] respondsToSelector:@selector(tokenFieldDidChange:)]) {
            [[self delegate] performSelector:@selector(tokenFieldDidChange:) withObject:self];
        }
    }
    
    self.tokenCopies = [self.objectValue copy];
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    [super textDidEndEditing:aNotification];

    // Tokens can get created when the control loses focus, but none of the expected events fire. Fire one
    // manually instead.
    if ([[self delegate] respondsToSelector:@selector(tokenFieldDidChange:)]) {
        [[self delegate] performSelector:@selector(tokenFieldDidChange:) withObject:self];
    }
}

@end
