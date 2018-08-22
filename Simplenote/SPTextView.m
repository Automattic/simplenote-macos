//
//  SPTextView.m
//  Simplenote
//
//  Created by Michael Johnston on 8/7/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPTextView.h"

#define kMaxEditorWidth 750 // Note: This matches the Electron apps max editor width

@implementation SPTextView

// Workaround NSTextView not allowing clicks
// http://stackoverflow.com/a/10308359/1379066
- (void)mouseDown:(NSEvent *)theEvent
{
    // Notify delegate that this text view was clicked and then
    // handled the click natively as well.
    [[self textViewDelegate] didClickTextView:self];
    [super mouseDown:theEvent];
}

- (id<SPTextViewDelegate>)textViewDelegate
{
    return [self.delegate conformsToProtocol:@protocol(SPTextViewDelegate)] ? (id<SPTextViewDelegate>)self.delegate : nil;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGFloat viewWidth = self.frame.size.width;
    CGFloat insetX = [self shouldCalculateInset:viewWidth] ? [self getAdjustedInsetX:viewWidth] : kMinEditorPadding;
    [self setTextContainerInset: NSMakeSize(insetX, kMinEditorPadding)];
}

- (BOOL)shouldCalculateInset: (CGFloat)viewWidth {
    return viewWidth > kMaxEditorWidth && ![[NSUserDefaults standardUserDefaults] boolForKey:kEditorWidthPreferencesKey];
}

- (CGFloat)getAdjustedInsetX: (CGFloat)viewWidth {
    NSInteger adjustedInset = (viewWidth - kMaxEditorWidth) / 2;
    
    return adjustedInset + kMinEditorPadding;
}

@end
