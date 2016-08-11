//
//  ColorGradientView.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/27/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SPGradientView : NSView
{
    NSColor *startingColor;
    NSColor *middleColor;
    NSColor *endingColor;
    float gradientProportion;
    int angle;
}

// Define the variables as properties
@property (nonatomic, strong) NSColor *startingColor;
@property (nonatomic, strong) NSColor *middleColor;
@property (nonatomic, strong) NSColor *endingColor;
@property (assign) float gradientProportion;
@property (assign) int angle;

+ (SPGradientView *)horizontalDividerForRect:(NSRect)rect;
+ (SPGradientView *)horizontalDividerInView:(NSView *)view location:(CGPoint)location;
+ (SPGradientView *)horizontalDividerWithWidth:(CGFloat)width paddingX:(CGFloat)paddingX locationY:(CGFloat)locationY;
- (void)applyStyle;
@end