//
//  SPTextView.m
//  Simplenote
//
//  Created by Michael Johnston on 8/7/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPTextView.h"
#import "NSMutableAttributedString+Styling.h"
#import "Simplenote-Swift.h"

#define kMaxEditorWidth 750 // Note: This matches the Electron apps max editor width

@implementation SPTextView

// Workaround NSTextView not allowing clicks
// http://stackoverflow.com/a/10308359/1379066
- (void)mouseDown:(NSEvent *)theEvent
{
    // Notify delegate that this text view was clicked and then
    // handled the click natively as well.
    [[self textViewDelegate] didClickTextView:self];
    
    if ([self checkForChecklistClick:theEvent]) {
        return;
    }
    
    [super mouseDown:theEvent];
}

- (id<SPTextViewDelegate>)textViewDelegate
{
    return [self.delegate conformsToProtocol:@protocol(SPTextViewDelegate)] ? (id<SPTextViewDelegate>)self.delegate : nil;
}

- (void)drawRect:(NSRect)dirtyRect {
    CGFloat viewWidth = self.frame.size.width;
    CGFloat insetX = [self shouldCalculateInset:viewWidth] ? [self getAdjustedInsetX:viewWidth] : kMinEditorPadding;
    [self setTextContainerInset: NSMakeSize(insetX, kMinEditorPadding)];
    
    [super drawRect:dirtyRect];
}

- (BOOL)shouldCalculateInset: (CGFloat)viewWidth {
    return viewWidth > kMaxEditorWidth && ![[Options shared] editorFullWidth];
}

- (CGFloat)getAdjustedInsetX: (CGFloat)viewWidth {
    CGFloat adjustedInset = (viewWidth - kMaxEditorWidth) / 2;
    
    return lroundf(adjustedInset) + kMinEditorPadding;
}

- (BOOL)checkForChecklistClick:(NSEvent *)event
{
    // Location of the tap in text-container coordinates
    NSLayoutManager *layoutManager = self.layoutManager;
    CGPoint location = [event locationInWindow];
    NSPoint viewPoint = [self convertPoint:location fromView:nil];
    viewPoint.x -= self.textContainerInset.width;
    viewPoint.y -= self.textContainerInset.height;
    
    // Find the character that's been tapped on
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:viewPoint
                                           inTextContainer:self.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < self.textStorage.length) {
        NSRange range;
        if ([self.attributedString attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&range]) {
            id value = [self.attributedString attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&range];
            // A checkbox was tapped!
            SPTextAttachment *attachment = (SPTextAttachment *)value;
            BOOL wasChecked = attachment.isChecked;
            [attachment setIsChecked:!wasChecked];
     
            NSNotification *note = [NSNotification notificationWithName:NSTextDidChangeNotification object:nil];
            [self.delegate textDidChange:note];
            [self setNeedsLayout:YES];
            [self.layoutManager invalidateDisplayForCharacterRange:range];
            
            return YES;
        }
    }
    
    return NO;
}

@end
