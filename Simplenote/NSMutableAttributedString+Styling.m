#import "NSMutableAttributedString+Styling.h"
#import "Simplenote-Swift.h"
#import "SPTextView.h"


@implementation NSMutableAttributedString (Styling)

- (NSArray<SPTextAttachment *> *)processChecklistsWithColor:(NSColor *)color
{
    NSMutableArray *attachments = [NSMutableArray new];
    if (self.length == 0) {
        return attachments;
    }

    NSRegularExpression *regex = [NSRegularExpression regexForListMarkers];

    NSString *noteString = self.string.copy;
    NSArray *matches = [[[regex matchesInString:noteString
                                        options:0
                                          range:self.fullRange] reverseObjectEnumerator] allObjects];
    
    if (matches.count == 0) {
        return attachments;
    }

    for (NSTextCheckingResult *match in matches) {
        if (NSRegularExpression.regexForListMarkersExpectedNumberOfRanges != match.numberOfRanges) {
            continue;
        }

        NSRange checkboxRange = [match rangeAtIndex:NSRegularExpression.regexForListMarkersReplacementRangeIndex];
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
