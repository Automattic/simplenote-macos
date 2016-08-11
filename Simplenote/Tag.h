//
//  Tag.h
//  Simplenote
//
//  Created by Michael Johnston on 10-04-19.
//  Copyright 2010 Simperium. All rights reserved.
//

@import Simperium_OSX;

@interface Tag : SPManagedObject {
	NSString *name;
	NSMutableArray *recipients;
	int count;
	NSNumber *index;
    NSString *share;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *recipients;
@property (nonatomic) int count;
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSString *share;

+ (Tag *)tagFromDictionary:(NSDictionary *)dict;
- (void)updateFromDictionary:(NSDictionary *)dict;
- (instancetype)initWithText:(NSString *)str;
- (instancetype)initWithText:(NSString *)str recipients:(NSArray *)emailList;
- (NSString *)textWithPrefix;
- (void)addRecipient:(NSString *)emailAddress;
- (NSDictionary *)tagDictionary;

@end
