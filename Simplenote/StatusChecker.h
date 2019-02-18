#import <Cocoa/Cocoa.h>



@class Simperium;

#pragma mark ================================================================================
#pragma mark StatusChecker
#pragma mark ================================================================================

@interface StatusChecker : NSObject

+ (int)getUnsentChangeCount:(Simperium *)simperium;
+ (NSString *)getUnsyncedNoteTitles:(Simperium *)simperium;

@end
