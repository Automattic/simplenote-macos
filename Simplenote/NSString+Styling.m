//
//  NSAttributedString+Styling.m
//  Simplenote
//
//  Created by Tom Witkin on 7/6/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "NSString+Styling.h"

@implementation NSString (Styling)

- (NSAttributedString *)headlinedAttributedStringWithHeadlineFont:(NSFont *)headlineFont
                                                    headlineColor:(NSColor *)headlineColor
                                                         bodyFont:(NSFont *)bodyFont
                                                        bodyColor:(NSColor *)bodyColor
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];

    
    NSRange firstLineRange = [self rangeOfString:@"\n"];
    
    NSMutableParagraphStyle *bodyStyle = [[NSMutableParagraphStyle alloc] init];
    [bodyStyle setLineSpacing:6.0];
    [bodyStyle setMinimumLineHeight:0];
    [bodyStyle setMaximumLineHeight:11];

    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    [titleStyle setLineSpacing:0.0];
    [titleStyle setParagraphSpacing:8];
    [titleStyle setMinimumLineHeight:0];
    [titleStyle setMaximumLineHeight:20];
    [titleStyle setAlignment:NSLeftTextAlignment];

    // set title font
    NSRange titleRange, bodyRange;
    NSInteger length = self.length;
    if (firstLineRange.location != NSNotFound) {
        titleRange = NSMakeRange(0, firstLineRange.location);

        bodyRange = NSMakeRange(firstLineRange.location, length - firstLineRange.location);
        [attributedString addAttributes:@{NSFontAttributeName: bodyFont,
                                          NSForegroundColorAttributeName: bodyColor,
                                          NSParagraphStyleAttributeName: bodyStyle}
                                  range:bodyRange];        
    } else
        titleRange = NSMakeRange(0, length);
    
    [attributedString addAttributes:@{NSFontAttributeName: headlineFont,
     NSForegroundColorAttributeName: headlineColor,
      NSParagraphStyleAttributeName: titleStyle}
                              range:titleRange];
    
    return attributedString;
}

@end
