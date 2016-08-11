//
//  NSAttributedString+Styling.h
//  Simplenote
//
//  Created by Tom Witkin on 7/6/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Styling)

- (NSAttributedString *)headlinedAttributedStringWithHeadlineFont:(NSFont *)headlineFont
                                                    headlineColor:(NSColor *)headlineColor
                                                         bodyFont:(NSFont *)bodyFont
                                                        bodyColor:(NSColor *)bodyColor;

@end
