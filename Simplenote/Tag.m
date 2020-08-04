//
//  Tag.m
//  Simplenote
//
//  Created by Michael Johnston on 10-04-19.
//  Copyright 2010 Simperium. All rights reserved.
//

#import "Tag.h"
#import "JSONKit+Simplenote.h"

@interface Tag()
- (void)updateRecipients;
@end

@implementation Tag
@synthesize count;
@dynamic index;
@dynamic share;
@dynamic name;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self updateRecipients];
}

- (void)updateRecipients
{
    if (share.length > 0) {
        self.recipients = [share objectFromJSONString];
    } else {
        self.recipients = [NSMutableArray arrayWithCapacity:3];
    }
}

- (void)setRecipients:(NSMutableArray *)newRecipients
{
    // Update share instead; recipients will get updated in setShare: below via updateRecipients
    self.share = [newRecipients count] > 0 ? [newRecipients JSONString] : @"[]";
}

- (NSMutableArray *)recipients
{
	return recipients;
}

- (NSComparisonResult)compareIndex:(Tag *)tag
{
	int i1 = [[self index] intValue];
	int i2 = [[tag index] intValue];
	if (i1 >= 0 && i2 >= 0) {
		return [[self index] compare:[tag index]];
	} else {
		return NSOrderedSame;
	}	
}

- (void)addRecipient:(NSString *)emailAddress
{
    NSString *newEmailAddress = [emailAddress copy];
	[recipients addObject: newEmailAddress];
    self.share = [recipients JSONString];
}

@end
