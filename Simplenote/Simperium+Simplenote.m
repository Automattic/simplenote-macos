#import "Simperium+Simplenote.h"
#import "Simplenote-Swift.h"
#import "SPConstants.h"


@implementation Simperium (Simplenote)

- (Preferences *)preferencesObject
{
    SPBucket *bucket = [self bucketForName:NSStringFromClass([Preferences class])];
    Preferences *preferences = [bucket objectForKey:SPSimperiumPreferencesObjectKey];
    if (preferences != nil) {
        return preferences;
    }

    return [bucket insertNewObjectForKey:SPSimperiumPreferencesObjectKey];
}

@end
