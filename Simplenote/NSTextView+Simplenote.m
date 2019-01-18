//
//  NSTextView+Simplenote.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/25/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "NSTextView+Simplenote.h"
#import "NSString+Bullets.h"



#pragma mark ====================================================================================
#pragma mark NSTextView (Simplenote)
#pragma mark ====================================================================================

@implementation NSTextView (Simplenote)

const int ChecklistItemLength = 3;

- (BOOL)applyAutoBulletsAfterTabPressed
{
    return [self applyAutoBulletsForKeyPress:YES];
}

- (BOOL)applyAutoBulletsAfterReturnPressed
{
    return [self applyAutoBulletsForKeyPress:NO];
}

- (BOOL)applyAutoBulletsForKeyPress: (BOOL)isTabPress
{
    // Determine what kind of bullet we should insert
    NSRange currentRange                = self.selectedRange;
    NSString *rawString                 = self.string;
    NSRange lineRange                   = [rawString lineRangeForRange:currentRange];
    NSString *lineString                = [rawString substringWithRange:lineRange];
    NSString *cleanLineString           = [lineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *textAttachmentCode = @"\U0000fffc"; // Represents the glyph of an NSTextAttachment
    NSArray *const bullets              = @[@"*", @"-", @"+", textAttachmentCode];
    NSString *stringToAppendToNewLine   = nil;
    
    for (NSString *bullet in bullets) {
        if ([cleanLineString hasPrefix:bullet]) {
            stringToAppendToNewLine = [bullet isEqualToString:textAttachmentCode] ? @"- [ ] " : bullet;
            break;
        }
    }
    
    // Stop right here... if there's no bullet!
    if (!stringToAppendToNewLine) {
        return NO;
    }
    
    NSUInteger bulletLength             = stringToAppendToNewLine.length;
    BOOL isApplyingChecklist            = [cleanLineString hasPrefix:textAttachmentCode];
    NSInteger indexOfBullet             = [lineString rangeOfString:isApplyingChecklist
                                           ? textAttachmentCode
                                           : stringToAppendToNewLine].location;
    NSString *insertionString           = nil;
    NSRange insertionRange              = lineRange;
    
    // Tab entered: Move the bullet along
    if (isTabPress) {
        if (isApplyingChecklist) {
            return NO;
        }
        // Proceed only if the user is entering Tab's right by the first one
        //  -   Something
        //     ^
        //
        NSInteger const IndentationIndexDelta = 2;
        
        if (currentRange.location != lineRange.location + indexOfBullet + IndentationIndexDelta) {
            return NO;
        }
        
        insertionString                 = [NSString.tabString stringByAppendingString:lineString];
        currentRange.location           += NSString.tabString.length;
        
    // Empty Line: Remove the bullet
    } else if (cleanLineString.length == 1) {
        insertionString                 = [NSString newLineString];
        currentRange.location           -= lineRange.length - (isApplyingChecklist ? 1 :  bulletLength);
    // Attempt to apply the bullet
    } else  {
        // Substring: [0 - Bullet]
        if (isApplyingChecklist) {
            NSRange bulletPrefixRange       = NSMakeRange(0, [lineString rangeOfString:textAttachmentCode].location);
            stringToAppendToNewLine         = [[lineString substringWithRange:bulletPrefixRange] stringByAppendingString:stringToAppendToNewLine];
        } else {
            NSRange bulletPrefixRange       = NSMakeRange(0, [lineString rangeOfString:stringToAppendToNewLine].location + 1);
            stringToAppendToNewLine         = [lineString substringWithRange:bulletPrefixRange];
        }
        
        // Do we need to append a whitespace?
        if (lineRange.length > indexOfBullet + bulletLength && !isApplyingChecklist) {
            unichar bulletTrailing      = [lineString characterAtIndex:indexOfBullet + bulletLength];
            
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:bulletTrailing]) {
                NSString *trailing      = [NSString stringWithFormat:@"%c", bulletTrailing];
                stringToAppendToNewLine = [stringToAppendToNewLine stringByAppendingString:trailing];
            }
        }
        
        // Replace!
        insertionString                 = [[NSString newLineString] stringByAppendingString:stringToAppendToNewLine];
        insertionRange                  = currentRange;
        currentRange.location           += isApplyingChecklist ? [stringToAppendToNewLine length] - ChecklistItemLength : insertionString.length;
    }
    
    // Apply the Replacements
    [self insertText:insertionString replacementRange:insertionRange];
    
    // Update the Selected Range (If needed)
    if (currentRange.length == 0) {
        [self setSelectedRange:currentRange];
    }
    
    // Signal that the text was changed!
    NSNotification *note = [NSNotification notificationWithName:NSTextDidChangeNotification object:nil];
    [self.delegate textDidChange:note];
    
    return YES;
}

- (NSRange)visibleTextRange
{
    NSLayoutManager *layoutManager  = self.layoutManager;
    NSTextContainer *textContainer  = self.textContainer;
    NSPoint containerOrigin         = self.textContainerOrigin;
    
    // Convert from view coordinates to container coordinates
    NSRect theRect      = self.visibleRect;
    theRect             = NSOffsetRect(theRect, -containerOrigin.x, -containerOrigin.y);
 
    NSRange glyphRange  = [layoutManager glyphRangeForBoundingRect:theRect inTextContainer:textContainer];
    NSRange charRange   = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    
    return charRange;
}

@end
