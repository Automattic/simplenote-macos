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


@implementation SPTextView

- (nullable Storage *)simplenoteStorage
{
    return [self.textStorage isKindOfClass:[Storage class]] ? (Storage *)self.textStorage : nil;
}

- (NSDictionary *)typingAttributes
{
    return (self.simplenoteStorage != nil) ? self.simplenoteStorage.typingAttributes : super.typingAttributes;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([self checkForChecklistClick:theEvent]) {
        return;
    }
    
    [super mouseDown:theEvent];
}

- (void)paste:(id)sender
{
    [super paste:sender];
    [self processLinksInDocumentAsynchronously];
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
