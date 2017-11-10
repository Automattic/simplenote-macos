//
//  ColorGradientView.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/27/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPGradientView.h"
#import "VSThemeManager.h"
@implementation SPGradientView
@synthesize startingColor;
@synthesize middleColor;
@synthesize endingColor;
@synthesize angle;
@synthesize gradientProportion;

+ (SPGradientView *)horizontalDividerForRect:(NSRect)rect
{
    SPGradientView *gradient = [[SPGradientView alloc] initWithFrame:rect];
    gradient.startingColor = [[[VSThemeManager sharedManager] theme] colorForKey:@"dividerColor"];
    //gradient.middleColor = [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];
    //gradient.endingColor = [NSColor colorWithCalibratedWhite:0.85 alpha:0.25];
    gradient.gradientProportion = 1.0;
    gradient.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin;

    return gradient;
}

+ (SPGradientView *)horizontalDividerInView:(NSView *)view location:(CGPoint)location
{
    CGRect frame = NSMakeRect(location.x, location.y, view.frame.size.width-location.x*2-location.x/2+5, 1.0);
    return [self horizontalDividerForRect:frame];
}

+ (SPGradientView *)horizontalDividerWithWidth:(CGFloat)width paddingX:(CGFloat)paddingX locationY:(CGFloat)locationY
{
    CGRect frame = NSMakeRect(paddingX, locationY, width-paddingX*2, 1.0);
    return [self horizontalDividerForRect:frame];
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self applyStyle];
        self.angle = 0;
        self.gradientProportion = 1.0;
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
    if (endingColor == nil || ([startingColor isEqual:endingColor] && middleColor == nil)) {
        NSGradient* aGradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:startingColor];
        [aGradient drawInRect:self.bounds angle:angle];
    } else if (middleColor == nil) {
        NSGradient* aGradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:endingColor];
        [aGradient drawInRect:self.bounds angle:angle];
    } else {
        CGFloat gradientWidth = ceil(self.bounds.size.width / 2.0 * gradientProportion);
        CGRect firstRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, gradientWidth, self.bounds.size.height);
        CGRect lastRect = CGRectMake(self.bounds.size.width-gradientWidth, self.bounds.origin.y, gradientWidth, self.bounds.size.height);
        
        NSGradient* firstGradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:middleColor];
        [firstGradient drawInRect:firstRect angle:angle];

        NSGradient* secondGradient = [[NSGradient alloc] initWithStartingColor:middleColor endingColor:endingColor];
        [secondGradient drawInRect:lastRect angle:angle];

        if (gradientProportion < 1.0) {
            CGRect middleRect = CGRectMake(firstRect.size.width, self.bounds.origin.y, self.bounds.size.width*(1.0-gradientProportion), self.bounds.size.height);
            
            [middleColor set];
            NSRectFill(middleRect);
        }
    }
}

- (void)applyStyle
{
    startingColor = [[[VSThemeManager sharedManager] theme] colorForKey:@"dividerColor"];
}

@end
