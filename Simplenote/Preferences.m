#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Preferences.h"


@implementation Preferences

@dynamic ghostData;
@dynamic simperiumKey;

@dynamic analytics_enabled;

- (void)awakeFromLocalInsert
{
    [super awakeFromLocalInsert];
    self.analytics_enabled = @(false);
}

@end
