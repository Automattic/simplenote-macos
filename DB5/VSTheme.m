//
//  VSTheme.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSTheme.h"
#import "NSObject+Simplenote.h"


static BOOL stringIsEmpty(NSString *s);
static NSColor *colorWithHexString(NSString *hexString);


@interface VSTheme ()

@property (nonatomic, strong) NSDictionary *themeDictionary;
@property (nonatomic, strong) NSCache *colorCache;
@property (nonatomic, strong) NSCache *fontCache;
@property (nonatomic, strong) NSCache *userSizedFontCache;
@property (nonatomic, strong) NSFont *systemBodyFont;

@end


@implementation VSTheme


#pragma mark Init

- (id)initWithDictionary:(NSDictionary *)themeDictionary {
	
	self = [super init];
	if (self == nil)
		return nil;
	
	_themeDictionary = themeDictionary;

	[self clearCaches];
    
	return self;
}


- (void)clearCaches {
    
    _colorCache = [NSCache new];
	_fontCache = [NSCache new];
	_userSizedFontCache = [NSCache new];

    NSFontDescriptor *titleDescriptor = [NSFontDescriptor fontDescriptorWithFontAttributes:nil];
    _systemBodyFont = [NSFont fontWithDescriptor:titleDescriptor
                                            size:0.0];
}

- (id)objectForKey:(NSString *)key {

    id obj = [self.themeDictionary valueForKeyPath:key];
    if (obj == nil && self.parentTheme != nil)
        obj = [self.parentTheme objectForKey:key];
    
    // check to see if the returned value was a key
    if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj hasPrefix:@"@"])
        obj = [self objectForKey:[obj substringFromIndex:1]];
    
    
	return obj;
}


- (BOOL)boolForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	if (obj == nil)
		return NO;
	return [obj boolValue];
}


- (NSString *)stringForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	if (obj == nil)
		return nil;
	if ([obj isKindOfClass:[NSString class]])
		return obj;
	if ([obj isKindOfClass:[NSNumber class]])
		return [obj stringValue];
	return nil;
}


- (NSInteger)integerForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	if (obj == nil)
		return 0;
	return [obj integerValue];
}


- (CGFloat)floatForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	if (obj == nil)
		return  0.0f;
	return [obj floatValue];
}

- (NSNumber *)numberForKey:(NSString *)key {

	return [NSNumber numberWithFloat:[self floatForKey:key]];
}

- (NSTimeInterval)timeIntervalForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	if (obj == nil)
		return 0.0;
	return [obj doubleValue];
}


- (NSImage *)imageForKey:(NSString *)key {
	
	NSString *imageName = [self stringForKey:key];
	if (stringIsEmpty(imageName))
		return nil;
	
	return [NSImage imageNamed:imageName];
}


- (NSColor *)colorForKey:(NSString *)key {
    
    // Special overrides for macOS Mojave
    if (@available(macOS 10.14, *)) {
        if ([key isEqualToString:@"dividerColor"]) {
            return NSColor.separatorColor;
        } else if ([key isEqualToString:@"tableViewBackgroundColor"]) {
            return NSColor.controlBackgroundColor;
        } else if ([key isEqualToString:@"textColor"] || [key isEqualToString:@"noteHeadlineFontColor"]) {
            return NSColor.textColor;
        } else if ([key isEqualToString:@"secondaryTextColor"] || [key isEqualToString:@"noteBodyFontPreviewColor"]) {
            return NSColor.secondaryLabelColor;
        }
    }
    
	NSColor *cachedColor = [self.colorCache objectForKey:key];
	if (cachedColor != nil)
		return cachedColor;
    
	NSString *colorString = [self stringForKey:key];
	NSColor *color = colorWithHexString(colorString);
	if (color == nil)
		color = [NSColor blackColor];

	[self.colorCache setObject:color forKey:key];

	return color;
}


- (NSEdgeInsets)edgeInsetsForKey:(NSString *)key {

	CGFloat left = [self floatForKey:[key stringByAppendingString:@"Left"]];
	CGFloat top = [self floatForKey:[key stringByAppendingString:@"Top"]];
	CGFloat right = [self floatForKey:[key stringByAppendingString:@"Right"]];
	CGFloat bottom = [self floatForKey:[key stringByAppendingString:@"Bottom"]];

	NSEdgeInsets edgeInsets = NSEdgeInsetsMake(top, left, bottom, right);
	return edgeInsets;
}


- (NSFont *)fontForKey:(NSString *)key {

	NSFont *cachedFont = [self.fontCache objectForKey:key];
	if (cachedFont != nil)
		return cachedFont;
    
	NSString *fontName = [self stringForKey:key];
	CGFloat fontSize = [self floatForKey:[key stringByAppendingString:@"Size"]];

	if (fontSize < 1.0f)
		fontSize = 15.0f;

	NSFont *font = nil;
    
	if (stringIsEmpty(fontName))
		font = [NSFont systemFontOfSize:fontSize];
	else
		font = [NSFont fontWithName:fontName size:fontSize];

	if (font == nil)
		font = [NSFont systemFontOfSize:fontSize];
    
	[self.fontCache setObject:font forKey:key];

	return font;
}

- (NSFont *)fontWithSystemSizeForKey:(NSString *)key {
    
    NSFont *cachedFont = [self.userSizedFontCache objectForKey:key];
	if (cachedFont != nil)
		return cachedFont;
    
	NSString *fontName = [self stringForKey:key];
	CGFloat fontSize = _systemBodyFont.pointSize;
    
	if (fontSize < 1.0f)
		fontSize = 15.0f;
    else if (fontSize > 26.0f) // implement max font size
        fontSize = 26.0f;
        
	NSFont *font = nil;
    
	if (stringIsEmpty(fontName))
		font = _systemBodyFont;
	else
		font = [NSFont fontWithName:fontName size:fontSize];
    
	if (font == nil)
		font = _systemBodyFont;
    
	[self.userSizedFontCache setObject:font forKey:key];
    
	return font;
}


- (CGPoint)pointForKey:(NSString *)key {

	CGFloat pointX = [self floatForKey:[key stringByAppendingString:@"X"]];
	CGFloat pointY = [self floatForKey:[key stringByAppendingString:@"Y"]];

	CGPoint point = CGPointMake(pointX, pointY);
	return point;
}


- (CGSize)sizeForKey:(NSString *)key {

	CGFloat width = [self floatForKey:[key stringByAppendingString:@"Width"]];
	CGFloat height = [self floatForKey:[key stringByAppendingString:@"Height"]];

	CGSize size = CGSizeMake(width, height);
	return size;
}


- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key {

	NSString *s = [self stringForKey:key];
	if (s == nil)
		return VSTextCaseTransformNone;

	if ([s caseInsensitiveCompare:@"lowercase"] == NSOrderedSame)
		return VSTextCaseTransformLower;
	else if ([s caseInsensitiveCompare:@"uppercase"] == NSOrderedSame)
		return VSTextCaseTransformUpper;

	return VSTextCaseTransformNone;
}

@end

static BOOL stringIsEmpty(NSString *s) {
	return s == nil || [s length] == 0;
}


static NSColor *colorWithHexString(NSString *hexString) {

	/*Picky. Crashes by design.*/
	
	if (stringIsEmpty(hexString))
		return [NSColor blackColor];

	NSMutableString *s = [hexString mutableCopy];
	[s replaceOccurrencesOfString:@"#" withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)s);

	NSString *redString = [s substringToIndex:2];
	NSString *greenString = [s substringWithRange:NSMakeRange(2, 2)];
	NSString *blueString = [s substringWithRange:NSMakeRange(4, 2)];

	unsigned int red = 0, green = 0, blue = 0;
	[[NSScanner scannerWithString:redString] scanHexInt:&red];
	[[NSScanner scannerWithString:greenString] scanHexInt:&green];
	[[NSScanner scannerWithString:blueString] scanHexInt:&blue];

    if ([NSColor sp_respondsToSelector:@selector(colorWithRed:green:blue:alpha:)]) {
        return [NSColor colorWithRed:(CGFloat)red/255.0f green:(CGFloat)green/255.0f blue:(CGFloat)blue/255.0f alpha:1.0f];
    }
         
    return [NSColor colorWithCalibratedRed:(CGFloat)red/255.0f green:(CGFloat)green/255.0f blue:(CGFloat)blue/255.0f alpha:1.0f];
}
