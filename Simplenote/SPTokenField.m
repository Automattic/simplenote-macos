//
//  CustomTokenField.m
//  Simplenote
//
//  Created by Rainieri Ventura on 4/8/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPTokenField.h"
#import "SimplenoteAppDelegate.h"
#import "Note.h"

@interface SPTokenField() {
    NSArray *tokenCopies;
}
@end

@implementation SPTokenField

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
        [charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@";, "]];
        [self setTokenizingCharacterSet:charSet];
        [self setCompletionDelay:0.1];
        [self setBordered:NO];
        [self setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin];
        [[self cell] setWraps:YES];
        [self setFocusRingType:NSFocusRingTypeNone];
    }
    return self;
}

- (void)textDidBeginEditing:(NSNotification *)aNotification
{
    [super textDidBeginEditing:aNotification];
    tokenCopies = [self.objectValue copy];
}

- (void)textDidChange:(NSNotification *)obj
{
    [super textDidChange:obj];
    NSUInteger numTokens = [self.objectValue count];
    NSUInteger previousNumTokens = [tokenCopies count];

    if (previousNumTokens > numTokens) {
        if ([[self delegate] respondsToSelector:@selector(tokenFieldDidChange:)]) {
            [[self delegate] performSelector:@selector(tokenFieldDidChange:) withObject:self];
        }
    }
    
    tokenCopies = [self.objectValue copy];
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
