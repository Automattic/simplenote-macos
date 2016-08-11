//
//  NSMutableAttributedString+TruncateToWidth.h
//  Simplenote
//
//  Created by Rainieri Ventura on 4/5/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (TruncateToWidth)

- (NSMutableAttributedString*)stringByTruncatingToWidth:(CGFloat)width withFont:(NSFont *)font;

@end
