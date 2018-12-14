//
//  NSMutableAttributedString+TruncateToWidth.m
//  Simplenote
//
//  Created by Rainieri Ventura on 4/5/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "NSMutableAttributedString+Styling.h"
#import "Simplenote-Swift.h"
#import "SPTextView.h"

@implementation NSMutableAttributedString (Styling)

- (NSMutableAttributedString*)stringByTruncatingToWidth:(CGFloat)width withFont:(NSFont *)font
{
    // Create copy that will be the returned result
    NSMutableAttributedString * truncatedString = self;
    
    [truncatedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [truncatedString length])];
    
    NSMutableAttributedString * ellipsis = [[NSMutableAttributedString alloc] initWithString:@"…"];
    
    [ellipsis addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [ellipsis length])];
    
    // Make sure string is longer than requested width
    if ([truncatedString size].width > width)
    {
        // Accommodate for ellipsis we'll tack on the end
        width -= [ellipsis size].width;
        
        // Get range for last character in string
        NSRange range = {truncatedString.length - 1, 1};
        
        // Loop, deleting characters until string fits within width
        while ([truncatedString size].width > width) 
        {
            // Delete character at end
            [truncatedString deleteCharactersInRange:range];
            
            // Move back another character
            range.location--;
        }
        
        // Append ellipsis
        [truncatedString replaceCharactersInRange:range withAttributedString:ellipsis];
    }
    
    return truncatedString;
}

// Replaces checklist markdown syntax with SPTextAttachment images in an attributed string
- (void)addChecklistAttachmentsForHeight:(CGFloat) height andColor: (NSColor *)color andVerticalOffset:(CGFloat)verticalOffset {
    if (self.length == 0) {
        return;
    }
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kChecklistRegexPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    
    // Work with a copy of the NSString value so we can calculate the correct indices
    NSString *noteString = self.string.copy;
    NSArray *matches = [regex matchesInString:noteString options:0 range:[noteString rangeOfString:noteString]];
    
    if (matches.count == 0) {
        return;
    }
    
    int positionAdjustment = 0;
    for (NSTextCheckingResult *match in matches) {
        NSString *markdownTag = [noteString substringWithRange:match.range];
        BOOL isChecked = [markdownTag containsString:@"x"];
        
        SPTextAttachment *attachment = [[SPTextAttachment alloc] initWithColor:color];
        [attachment setIsChecked: isChecked];
        
        attachment.bounds = CGRectMake(0, verticalOffset, height, height);
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSRange adjustedRange = NSMakeRange(match.range.location - positionAdjustment, match.range.length);
        [self replaceCharactersInRange:adjustedRange withAttributedString:attachmentString];
        
        positionAdjustment += markdownTag.length - 1;
    }
}

@end
