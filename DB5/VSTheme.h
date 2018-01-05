//
//  VSTheme.h
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef NS_ENUM(NSUInteger, VSTextCaseTransform) {
    VSTextCaseTransformNone,
    VSTextCaseTransformUpper,
    VSTextCaseTransformLower
};


@class VSAnimationSpecifier;

@interface VSTheme : NSObject

- (id)initWithDictionary:(NSDictionary *)themeDictionary;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) VSTheme *parentTheme; /*can inherit*/

- (BOOL)boolForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (NSNumber *)numberForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;
- (NSImage *)imageForKey:(NSString *)key; /*Via UIImage imageNamed:*/
- (NSColor *)colorForKey:(NSString *)key; /*123ABC or #123ABC: 6 digits, leading # allowed but not required*/
- (NSEdgeInsets)edgeInsetsForKey:(NSString *)key; /*xTop, xLeft, xRight, xBottom keys*/
- (NSFont *)fontForKey:(NSString *)key; /*x and xSize keys*/
- (NSFont *)fontWithSystemSizeForKey:(NSString *)key; /*x and xSize keys*/
- (CGPoint)pointForKey:(NSString *)key; /*xX and xY keys*/
- (CGSize)sizeForKey:(NSString *)key; /*xWidth and xHeight keys*/
- (NSTimeInterval)timeIntervalForKey:(NSString *)key;

- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key; /*lowercase or uppercase -- returns VSTextCaseTransformNone*/


- (void)clearCaches;

@end
