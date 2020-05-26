#import "NSString+Condensing.h"

#define kMaxPreviewLength 500

@implementation NSString (Condensing)

- (void)generatePreviewStrings:(void (^)(NSString *titlePreview, NSString *bodyPreview))block
{
    NSString *trimmed = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Remove Markdown #'s from the title
    NSRange cutRange = [trimmed rangeOfString:@"# "];
    if (cutRange.location == 0) {
        trimmed = [trimmed substringFromIndex:NSMaxRange(cutRange)];
    }

    // Do we even have more than one line?
    NSInteger locationForBody = [trimmed rangeOfString: @"\n"].location;

    if (locationForBody == NSNotFound) {
        block(trimmed, nil);
        return;
    }

    // Split Title / Body
    NSString *title = [trimmed substringToIndex:locationForBody];
    NSString *body = [[trimmed substringFromIndex:locationForBody] stringByReplacingNewlinesWithSpaces];

    block(title, body);
}

- (NSString *)stringByReplacingNewlinesWithSpaces
{
    if (self.length == 0) {
        return self;
    }

    // Newlines: \n *AND* \r's!
    NSMutableArray *components = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];

    // Note: The following nukes everything that tests true for `isEquals`: Every single empty string is gone!
    [components removeObject:@""];

    return [components componentsJoinedByString:@" "];
}

- (NSString *)stringByGeneratingPreview
{
    NSString *aString = [NSString stringWithString:self];
    NSString *titlePreview;
    NSString *contentPreview;

    // Optimize to make sure a bunch of text doesn't get rendered but clipped in the previews
    if (aString.length > kMaxPreviewLength) {
        aString = [aString substringToIndex:kMaxPreviewLength];
    }

    NSString *contentTest = [aString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    NSRange firstNewline = [contentTest rangeOfString: @"\n"];
    if (firstNewline.location == NSNotFound) {
        titlePreview = contentTest;
        contentPreview = nil;
    } else {
        titlePreview = [contentTest substringToIndex:firstNewline.location];
        contentPreview = [[contentTest substringFromIndex: firstNewline.location+1] stringByReplacingOccurrencesOfString:@"\n\n" withString:@" \n"];

        // Remove leading newline if applicable
        NSRange nextNewline = [contentPreview rangeOfString: @"\n"];
        if (nextNewline.location == 0) {
            contentPreview = [contentPreview substringFromIndex:1];
        }
    }

    // Remove Markdown #'s
    if ([titlePreview hasPrefix:@"#"]) {
        NSRange cutRange = [titlePreview rangeOfString:@"# "];
        if (cutRange.location != NSNotFound) {
            titlePreview = [titlePreview substringFromIndex:cutRange.location + cutRange.length];
        }
    }

    if (contentPreview) {
        return [NSString stringWithFormat:@"%@\n%@", titlePreview, contentPreview];
    }

    return titlePreview;
}

@end

