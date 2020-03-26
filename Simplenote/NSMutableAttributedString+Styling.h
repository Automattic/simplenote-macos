//
//  NSMutableAttributedString+TruncateToWidth.h
//  Simplenote
//
//  Created by Rainieri Ventura on 4/5/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPTextAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Styling)

- (NSArray<SPTextAttachment *> *)processChecklistsWithColor:(NSColor *)color;

@end

NS_ASSUME_NONNULL_END
