#import "NSString+Metadata.h"

@implementation NSString (Metadata)

- (BOOL)containsEmailAddress
{
    NSString *regEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    return [predicate evaluateWithObject:self];
}

- (NSInteger)convertCursorLocation:(NSInteger)location toLocationInText:(NSString *)newText
{
    NSUInteger newCursorLocation = location;

    // Cases:
    // 0. All text after cursor (and possibly more) was removed ==> put cursor at end
    // 1. Text was added after the cursor ==> no change
    // 2. Text was added before the cursor ==> location advances
    // 3. Text was removed after the cursor ==> no change
    // 4. Text was removed before the cursor ==> location retreats
    // 5. Text was added/removed on both sides of the cursor ==> not handled

    NSInteger deltaLength = newText.length - self.length;

    // Case 0
    if (newText.length < location)
        return newText.length;

    BOOL beforeCursorMatches = NO;
    BOOL afterCursorMatches = NO;
    @try {
        beforeCursorMatches = [[self substringToIndex:location] compare:[newText substringToIndex:location]] == NSOrderedSame;
        afterCursorMatches = [[self substringFromIndex:location] compare:[newText substringFromIndex:location+deltaLength]] == NSOrderedSame;
    } @catch (NSException *e) {

    }

    // Cases 2 and 4
    if (!beforeCursorMatches && afterCursorMatches) {
        newCursorLocation += deltaLength;
    }

    // Cases 1, 3 and 5 have no change
    return newCursorLocation;
}

@end
