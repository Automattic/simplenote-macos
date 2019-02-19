#import "StatusChecker.h"
#import "Note.h"
@import Simperium_OSX;



#pragma mark ================================================================================
#pragma mark Workaround: Exposing Private SPBucket methods
#pragma mark ================================================================================

@interface SPBucket ()
- (BOOL)hasLocalChangesForKey:(NSString *)key;
@end


#pragma mark ================================================================================
#pragma mark Constants
#pragma mark ================================================================================

static NSString *kEntityName = @"Note";


#pragma mark ================================================================================
#pragma mark StatusChecker
#pragma mark ================================================================================

@implementation StatusChecker

+ (int)getUnsentChangeCount:(Simperium *)simperium
{    
    if (simperium.user.authenticated == false) {
        return 0;
    }

    SPBucket *bucket = [simperium bucketForName:kEntityName];
    NSArray *allNotes = [bucket allObjects];
    NSDate *startDate = [NSDate date];

    NSLog(@"<> Status Checker: Found %ld Entities [%f seconds elapsed]", (unsigned long)allNotes.count, startDate.timeIntervalSinceNow);
    
    // Compare the Ghost Content string, against the Entity Content
    int localChangeCount = 0;
    for (Note *note in allNotes) {
        if ([bucket hasLocalChangesForKey:note.simperiumKey]) {
            localChangeCount++;
        }
    }

    return localChangeCount;
}

+ (NSString *)getUnsyncedNoteTitles:(Simperium *)simperium
{
    if (simperium.user.authenticated == false) {
        return @"";
    }
    
    SPBucket *bucket = [simperium bucketForName:kEntityName];
    NSArray *allNotes = [bucket allObjects];
    NSDate *startDate = [NSDate date];
    
    NSLog(@"<> Status Checker: Found %ld Entities [%f seconds elapsed]", (unsigned long)allNotes.count, startDate.timeIntervalSinceNow);
    
    // Compare the Ghost Content string, against the Entity Content
    NSString *unsyncedNoteTitles = @"";
    for (Note *note in allNotes) {
        if ([bucket hasLocalChangesForKey:note.simperiumKey]) {
            NSString *titleWithLineBreak = [NSString stringWithFormat:@"\u2022 %@\n", note.titlePreview];
            unsyncedNoteTitles = [unsyncedNoteTitles stringByAppendingString:titleWithLineBreak];
        }
    }
    
    return unsyncedNoteTitles;
}

@end
