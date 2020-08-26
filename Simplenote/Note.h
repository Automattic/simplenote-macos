//
//  Note.h
//  Simplenote
//
//  Created by Michael Johnston on 01/07/08.
//  Copyright 2008 Simperium. All rights reserved.
//

@import Simperium_OSX;

@interface Note : SPManagedObject {
	NSString *content;
	NSString *modificationDatePreview;
	NSString *creationDatePreview;
	NSString *shareURL;
	NSString *publishURL;
	NSDate *creationDate;
	NSDate *modificationDate;
	BOOL pinned;
    BOOL markdown;
	int lastPosition;
	NSString *tags;
	NSString *systemTags;
    NSMutableArray *tagsArray;
    NSMutableArray *systemTagsArray;
	NSString *remoteId;
	BOOL deleted;
	BOOL shared;
	BOOL published;
	BOOL unread;	
	NSDictionary *versions;
}

@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * publishURL;
@property (nonatomic, copy) NSDate * modificationDate;
@property int lastPosition;
@property (nonatomic, copy) NSString * tags;
@property (nonatomic, strong) NSMutableArray *tagsArray;


// What's going on:
//
//  -   Since Simplenote's inception, logic deletion flag was a simple boolean called `deleted`
//  -   Collision with NSManagedObject's `deleted` flag wasn't picked up
//  -   Eventually CLANG enhanced checks allowed us to notice there's a collision
//
//  Proper fix involves a heavy modification in Simperium, which would allow us to keep the `deleted` "internal"
//  property name, while exposing a different property setter / getter, and thus, avoiding the collision.
//
// In This thermonuclear massive super workaround, we're simply silencing the warning.
//
// Proper course of action should be taken as soon as the next steps for Simperium are outlined.
//
// TODO: JLP Dec.27.2019.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
@property BOOL deleted;
#pragma clang diagnostic pop

@property (nonatomic, copy) NSString * shareURL;
@property (nonatomic, copy) NSDate * creationDate;
@property (nonatomic, copy) NSString * systemTags;
@property (copy, nonatomic) NSString *modificationDatePreview;
@property (copy, nonatomic) NSString *creationDatePreview;
@property (copy, nonatomic) NSString *titlePreview;
@property (copy, nonatomic) NSString *bodyPreview;
@property (assign, nonatomic) BOOL pinned;
@property (assign, nonatomic) BOOL markdown;
@property (assign, nonatomic) BOOL shared;
@property (assign, nonatomic) BOOL published;
@property (assign, nonatomic) BOOL unread;

- (NSString *)localID;
- (void)updateTagsArray;
- (void)updateSystemTagsArray;
- (BOOL)hasTag:(NSString *)tag;
- (void)addTag:(NSString *)tag;
- (void)addSystemTag:(NSString *)tag;
- (void)stripSystemTag:(NSString *)tag;
- (BOOL)hasSystemTag:(NSString *)tag;
- (void)setTagsFromList:(NSArray *)tagList;
- (void)stripTag:(NSString *)tag;
- (void)ensurePreviewStringsAreAvailable;
- (void)createPreview;

@end
