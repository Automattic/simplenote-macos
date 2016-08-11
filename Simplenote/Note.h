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
	NSString *titlePreview;
	NSString *contentPreview;
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
@property BOOL deleted;
@property (nonatomic, copy) NSString * shareURL;
@property (nonatomic, copy) NSDate * creationDate;
@property (nonatomic, copy) NSString * systemTags;
@property (copy, nonatomic) NSString *modificationDatePreview;
@property (copy, nonatomic) NSString *creationDatePreview;
@property (copy, nonatomic) NSString *titlePreview;
@property (copy, nonatomic) NSString *contentPreview;
@property (assign, nonatomic) BOOL pinned;
@property (assign, nonatomic) BOOL markdown;
@property (assign, nonatomic) BOOL shared;
@property (assign, nonatomic) BOOL published;
@property (assign, nonatomic) BOOL unread;

- (NSString *)dateString:(NSDate *)date brief:(BOOL)brief;
- (NSString *)creationDateString:(BOOL)brief;
- (NSString *)modificationDateString:(BOOL)brief;
- (NSString *)getDateString:(NSDate *)date brief:(BOOL)brief;

- (NSString *)localID;
- (void)updateTagsArray;
- (void)updateSystemTagsArray;
- (BOOL)hasTags;
- (BOOL)hasTag:(NSString *)tag;
- (void)addTag:(NSString *)tag;
- (void)addSystemTag:(NSString *)tag;
- (void)setSystemTagsFromList:(NSArray *)tagList;
- (void)stripSystemTag:(NSString *)tag;
- (BOOL)hasSystemTag:(NSString *)tag;
- (void)setTagsFromList:(NSArray *)tagList;
- (void)stripTag:(NSString *)tag;
- (void)createPreviews:(NSString *)aString;
- (NSDictionary *)noteDictionaryWithContent:(BOOL)include;
- (void)updateFromDictionary:(NSDictionary *)note fromServer:(BOOL)synced;
- (BOOL)isList;

@end
