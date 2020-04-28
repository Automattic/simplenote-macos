//
//  VSTheme.h
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface VSTheme : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)themeDictionary;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) VSTheme *parentTheme; /*can inherit*/

- (BOOL)boolForKey:(NSString *)key;
- (NSColor *)colorForKey:(NSString *)key; /*123ABC or #123ABC: 6 digits, leading # allowed but not required*/
- (NSFont *)fontForKey:(NSString *)key; /*x and xSize keys*/

- (void)clearCaches;

@end

NS_ASSUME_NONNULL_END

