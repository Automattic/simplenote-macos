#import <Cocoa/Cocoa.h>



@class Simperium;

#pragma mark ================================================================================
#pragma mark StatusChecker
#pragma mark ================================================================================

@interface StatusChecker : NSObject

+ (BOOL)hasUnsentChanges:(Simperium *)simperium;

@end
