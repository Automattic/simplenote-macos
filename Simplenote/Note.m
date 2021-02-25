//
//  Note.m
//
//  Created by Michael Johnston on 01/07/08.
//  Copyright 2008 Simperium. All rights reserved.
//

#import "Note.h"
#import "NSString+Metadata.h"
#import "JSONKit+Simplenote.h"
#import "SimplenoteAppDelegate.h"
#import "Simplenote-Swift.h"


@interface Note (PrimitiveAccessors)
- (NSString *)primitiveContent;
- (void)setPrimitiveContent:(NSString *)newContent;
@end

@implementation Note
@synthesize creationDatePreview;
@synthesize modificationDatePreview;
@synthesize titlePreview;
@synthesize bodyPreview;
@synthesize tagsArray;
@dynamic content;
@dynamic creationDate;
@dynamic deleted;
@dynamic lastPosition;
@dynamic modificationDate;
@dynamic publishURL;
@dynamic shareURL;
@dynamic systemTags;
@dynamic tags;
@dynamic pinned;
@dynamic markdown;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    [self createPreview];
    [self updateTagsArray];
    [self updateSystemTagsArray];
    [self updateSystemTagFlags];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.content = @"";
    self.publishURL = @"";
    self.shareURL = @"";
    self.creationDate = [NSDate date];
    self.modificationDate = [NSDate date];
    self.tags = @"[]";
    self.systemTags = @"[]";
    [self updateSystemTagsArray];
    [self updateTagsArray];
}

- (void)didTurnIntoFault
{
    [super didTurnIntoFault];
}



#pragma mark - Properties

// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSString *)localID
{
    NSManagedObjectID *key = [self objectID];
    if ([key isTemporaryID]) {
        return nil;
    }
    
    return [[key URIRepresentation] absoluteString];
}

- (NSComparisonResult)compareModificationDate:(Note *)note
{
    if (pinned && !note.pinned) {
        return NSOrderedAscending;
    } else if (!pinned && note.pinned) {
        return NSOrderedDescending;
    }

	return [note.modificationDate compare:self.modificationDate];
}

- (NSComparisonResult)compareModificationDateReverse:(Note *)note {
    if (pinned && !note.pinned) {
        return NSOrderedAscending;
    } else if (!pinned && note.pinned) {
        return NSOrderedDescending;
    }

	return [self.modificationDate compare:note.modificationDate];
}

- (NSComparisonResult)compareCreationDate:(Note *)note
{
    if (pinned && !note.pinned) {
        return NSOrderedAscending;
    } else if (!pinned && note.pinned) {
        return NSOrderedDescending;
    }
    
	return [note.creationDate compare:self.creationDate];
}

- (NSComparisonResult)compareCreationDateReverse:(Note *)note
{
    if (pinned && !note.pinned) {
        return NSOrderedAscending;
    } else if (!pinned && note.pinned) {
        return NSOrderedDescending;
    }

	return [self.creationDate compare:note.creationDate];
}

- (NSComparisonResult)compareAlpha:(Note *)note
{
    if (pinned && !note.pinned) {
        return NSOrderedAscending;
    } else if (!pinned && note.pinned) {
        return NSOrderedDescending;
    }

	return [self.content caseInsensitiveCompare:note.content];
}

- (NSComparisonResult)compareAlphaReverse:(Note *)note
{
    if (pinned && !note.pinned) {
        return NSOrderedAscending;
    } else if (!pinned && note.pinned) {
        return NSOrderedDescending;
    }
    
	return [note.content caseInsensitiveCompare:self.content];
}

- (void)ensurePreviewStringsAreAvailable
{
    if (self.titlePreview != nil) {
        return;
    }

    [self createPreview];
}

- (BOOL)deleted
{
    BOOL b;
    [self willAccessValueForKey:@"deleted"];
    b = deleted;
    [self didAccessValueForKey:@"deleted"];
    
	return b;
}

- (void)setDeleted:(BOOL)b
{
    if (b == deleted) {
        return;
    }
    
    [self willChangeValueForKey:@"deleted"];
    deleted = b;
    [self didChangeValueForKey:@"deleted"];
}

- (BOOL)shared
{
	return shared;
}

- (void)setShared:(BOOL)bShared
{
    if (bShared) {
        [self addSystemTag:@"shared"];
    } else {
        [self stripSystemTag:@"shared"];
    }
    
	shared = bShared;
}

- (BOOL)published
{
	return published;
}

- (void)setPublished:(BOOL) bPublished {
    if (bPublished) {
        [self addSystemTag:@"published"];
    } else {
        [self stripSystemTag:@"published"];
    }
    
	published = bPublished;
}

- (BOOL)unread {
	return unread;
}

- (void)setUnread:(BOOL) bUnread
{
    if (bUnread) {
        [self addSystemTag:@"unread"];
    } else {
        [self stripSystemTag:@"unread"];
    }
    
	unread = bUnread;
}

- (void)setTags:(NSString *)newTags
{
    if ((!tags && !newTags) || (tags && newTags && [tags isEqualToString:newTags])) {
        return;
    }
    
    [self willChangeValueForKey:@"tags"];
    NSString *newString = [newTags copy];
    [self setPrimitiveValue:newString forKey:@"tags"]; 
    [self updateTagsArray];
    [self didChangeValueForKey:@"tags"];
}

// Maintain flags for performance purposes
- (void)updateSystemTagFlags
{
	pinned = [self hasSystemTag:@"pinned"];
	shared = [self hasSystemTag:@"shared"];
	published = [self hasSystemTag:@"published"];
	unread = [self hasSystemTag:@"unread"];
    markdown = [self hasSystemTag:@"markdown"];
}

- (void)setSystemTags:(NSString *)newTags
{
    if ((!systemTags && !newTags) || (systemTags && newTags && [systemTags isEqualToString:newTags])) {
        return;
    }
    
    [self willChangeValueForKey:@"systemTags"];
    NSString *newString = [newTags copy];
    [self setPrimitiveValue:newString forKey:@"systemTags"]; 
    [self updateSystemTagsArray];
	[self updateSystemTagFlags];
    [self didChangeValueForKey:@"systemTags"];    
}

- (BOOL)pinned {
    BOOL b;
    [self willAccessValueForKey:@"pinned"];
    b = pinned;
    [self didAccessValueForKey:@"pinned"];
    
	return b;
}

- (void)setPinned:(BOOL) bPinned
{
    if (bPinned) {
        [self addSystemTag:@"pinned"];
    } else {
        [self stripSystemTag:@"pinned"];
    }
    
    [self willChangeValueForKey:@"pinned"];
	pinned = bPinned;
    [self didChangeValueForKey:@"pinned"];
}

- (BOOL)markdown
{
    BOOL b;
    [self willAccessValueForKey:@"markdown"];
    b = markdown;
    [self didAccessValueForKey:@"markdown"];
    
	return b;
}

- (void)setMarkdown:(BOOL) bMarkdown
{
	if (bMarkdown) [self addSystemTag:@"markdown"]; else [self stripSystemTag:@"markdown"];
    [self willChangeValueForKey:@"markdown"];
	markdown = bMarkdown;
    [self didChangeValueForKey:@"markdown"];
}

- (int)lastPosition
{
    int i;
    [self willAccessValueForKey:@"lastPosition"];
    i = lastPosition;
    [self didAccessValueForKey:@"lastPosition"];
    
	return i;
}

- (void)setLastPosition:(int) newLastPosition
{
	if (lastPosition == newLastPosition) return;
    
    [self willChangeValueForKey:@"lastPosition"];
	lastPosition = newLastPosition;
    [self didChangeValueForKey:@"lastPosition"];
}

- (void)setShareURL:(NSString *)url
{
    if ((!shareURL && !url) || (shareURL && url && [shareURL isEqualToString:url])) return;
    
    [self willChangeValueForKey:@"shareURL"];
    NSString *newString = [url copy];
    [self setPrimitiveValue:newString forKey:@"shareURL"]; 
    [self didChangeValueForKey:@"shareURL"];
}

- (void)setPublishURL:(NSString *)url
{
    if ((!publishURL && !url) || (publishURL && url && [publishURL isEqualToString:url])) return;
    
    [self willChangeValueForKey:@"publishURL"];
    NSString *newString = [url copy];
    [self setPrimitiveValue:newString forKey:@"publishURL"]; 
    [self didChangeValueForKey:@"publishURL"];
}

- (void)setTagsFromList:(NSArray *)tagList
{
    [self setTags: [tagList JSONString]];
}

- (void)updateTagsArray
{
    tagsArray = tags.length > 0 ? [[tags objectFromJSONString] mutableCopy] : [NSMutableArray arrayWithCapacity:2];
}

- (BOOL)hasTag:(NSString *)tag {
    if (tags == nil || tags.length == 0) {
        return NO;
    }
    
    for (NSString *tagCheck in tagsArray) {
        if ([tagCheck caseInsensitiveCompare:tag] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

- (void)addTag:(NSString *)tag
{
	if (![self hasTag: tag]) {
        NSString *newTag = [tag copy];
        [tagsArray addObject:newTag];
        self.tags = [tagsArray JSONString];
    }
}

- (void)updateSystemTagsArray
{
    systemTagsArray = systemTags.length > 0 ? [[systemTags objectFromJSONString] mutableCopy] : [NSMutableArray arrayWithCapacity:2];
}

- (void)addSystemTag:(NSString *)tag
{
	if (![self hasSystemTag: tag]) {
        NSString *newTag = [tag copy];
        [systemTagsArray addObject:newTag];
        self.systemTags = [systemTagsArray JSONString];
    }
}

- (BOOL)hasSystemTag:(NSString *)tag
{
    if (systemTags == nil || systemTags.length == 0) {
        return NO;
    }
    
    for (NSString *tagCheck in systemTagsArray) {
        if ([tagCheck compare:tag] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

- (void)stripTag:(NSString *)tag
{
    if (tags.length == 0) {
        return;
    }
    
    NSMutableArray *tagsArrayCopy = [tagsArray copy];
    for (NSString *tagCheck in tagsArrayCopy) {
        if ([tagCheck compare:tag] == NSOrderedSame) {
            [tagsArray removeObject:tagCheck];
            continue;
        }
    }

	self.tags = [tagsArray JSONString];
}

- (void)stripSystemTag:(NSString *)tag
{
    if (systemTags.length == 0) {
        return;
    }
    
    NSMutableArray *systemTagsArrayCopy = [systemTagsArray copy];
    for (NSString *tagCheck in systemTagsArrayCopy) {
        if ([tagCheck compare:tag] == NSOrderedSame) {
            [systemTagsArray removeObject:tagCheck];
            continue;
        }
    }
    
	self.systemTags = [systemTagsArray JSONString];
}

@end
