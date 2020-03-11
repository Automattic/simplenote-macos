//
//  NSMutableAttributedString+TruncateToWidth.h
//  Simplenote
//
//  Created by Rainieri Ventura on 4/5/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPTextAttachment;

@interface NSMutableAttributedString (Styling)

- (NSArray<SPTextAttachment *> *)processChecklistsWithColor:(NSColor *)color;

- (void)appendAttachment:(NSTextAttachment *)attachment;
- (void)appendString:(NSString *)aString;

@end
