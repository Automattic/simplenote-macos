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

const NSInteger RegexExpectedMatchGroups  = 3;
const NSInteger RegexGroupIndexContent    = 2;

- (NSArray<SPTextAttachment *> *)processChecklistsWithColor:(NSColor *)color
{
    NSMutableArray *attachments = [NSMutableArray new];
    if (self.length == 0) {
        return attachments;
    }
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kChecklistRegexPattern options:NSRegularExpressionAnchorsMatchLines error:&error];

    NSString *noteString = self.string.copy;
    NSArray *matches = [[[regex matchesInString:noteString
                                        options:0
                                          range:self.rangeOfEntireString] reverseObjectEnumerator] allObjects];
    
    if (matches.count == 0) {
        return attachments;
    }

    for (NSTextCheckingResult *match in matches) {
        if (match.numberOfRanges < RegexExpectedMatchGroups) {
            continue;
        }

        NSRange checkboxRange = [match rangeAtIndex:RegexGroupIndexContent];
        NSString *markdownTag = [noteString substringWithRange:match.range];
        BOOL isChecked = [markdownTag localizedCaseInsensitiveContainsString:@"x"];
        
        SPTextAttachment *attachment = [SPTextAttachment new];
        attachment.isChecked = isChecked;
        attachment.tintColor = color;
        [attachments addObject:attachment];

        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        [self replaceCharactersInRange:checkboxRange withAttributedString:attachmentString];
    }

    return attachments;
}

@end
