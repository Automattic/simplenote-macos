#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Preferences.h"


@implementation Preferences

@dynamic ghostData;
@dynamic simperiumKey;

@dynamic analytics_enabled;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.analytics_enabled = @(false);
}

@end
