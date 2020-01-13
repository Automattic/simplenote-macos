#import "NSString+Metadata.h"

@implementation NSString (Metadata)

- (NSArray *)stringArray
{
	NSMutableArray *list = [NSMutableArray arrayWithArray: [self componentsSeparatedByString:@" "]];
	NSMutableArray *discardedItems = [NSMutableArray array];
	NSString *str;
	
	for (str in list) {
        if ([str length] == 0) {
			[discardedItems addObject:str];
        }
	}
	
	[list removeObjectsInArray:discardedItems];

	return list;
}


- (BOOL)containsWholeWord:(NSString *)fullWord
{
    NSRange result = [self rangeOfString:fullWord];
    if (result.length > 0) {
        if (result.location > 0 && [[NSCharacterSet alphanumericCharacterSet] characterIsMember:[self characterAtIndex:result.location - 1]]) {
			// Preceding character is alphanumeric
			return NO;
        }
        if (result.location + result.length < [self length] && [[NSCharacterSet alphanumericCharacterSet] characterIsMember:[self characterAtIndex:result.location + result.length]]) {
			// Trailing character is alphanumeric
			return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)containsEmailAddress
{
    NSString *regEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    return [predicate evaluateWithObject:self];
}

@end
