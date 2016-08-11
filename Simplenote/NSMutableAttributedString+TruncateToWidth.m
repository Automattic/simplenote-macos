//
//  NSMutableAttributedString+TruncateToWidth.m
//  Simplenote
//
//  Created by Rainieri Ventura on 4/5/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "NSMutableAttributedString+TruncateToWidth.h"

@implementation NSMutableAttributedString (TruncateToWidth)


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



@end
