//
//  CustomTagView.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/30/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPTagCellView.h"
#import "NSImage+Colorize.h"
#import "NSString+Simplenote.h"
#import "VSThemeManager.h"


@interface SPTagCellView ()
@property (nonatomic, strong) NSTrackingArea    *trackingArea;
@property (nonatomic, strong) NSImage           *image;
@property (nonatomic, strong) NSImage           *imageHighlighted;
@property (nonatomic, assign) BOOL              highlighted;
@property (nonatomic, strong) IBOutlet NSBox    *dividerView;
@end

@implementation SPTagCellView

- (VSTheme *)theme {
    return [[VSThemeManager sharedManager] theme];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.autoresizesSubviews = YES;

    if (self.imageView.image) {
        NSString *highlightedImageName = [self.imageView.image.name stringByAppendingString:@"_highlighted"];
        self.imageHighlighted = [NSImage imageNamed:highlightedImageName];
    }

    [self applyStyle];
}

- (void)setMouseInside:(BOOL)value
{
    if (_mouseInside == value) {
        return;
    }
    
    _mouseInside = value;
    [self updateTextAndImageColors];
    [self setNeedsDisplay:YES];
}

- (void)ensureTrackingArea
{
    if (self.trackingArea == nil) {
        self.trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    }
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    [self ensureTrackingArea];
    if (![[self trackingAreas] containsObject:self.trackingArea]) {
        [self addTrackingArea:self.trackingArea];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseInside = YES;
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.mouseInside = NO;
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    BOOL selected = NO;
    if (self.superview && [self.superview isKindOfClass:[NSTableRowView class]]) {
        NSTableRowView *row = (NSTableRowView*)self.superview;
        selected = row.isSelected;
    }

    [self setSelected:selected];
}

- (void)updateTextAndImageColors
{
    self.textField.textColor    = _highlighted ? [self.theme colorForKey:@"tintColor"] : [self.theme colorForKey:@"textColor"];
    self.imageView.image        = self.highlighted ? self.imageHighlighted : self.image;

    CGFloat alphaValue          = !_highlighted && _mouseInside ? 0.6f : 1.0f;
    self.imageView.wantsLayer   = YES;
    self.imageView.alphaValue   = alphaValue;

    self.textField.wantsLayer   = YES;
    self.textField.alphaValue   = alphaValue;
}

- (void)setSelected:(BOOL)selected
{
    _highlighted = selected;
    [self updateTextAndImageColors];
}

- (void)applyStyle
{
    NSColor *textColor = [self.theme colorForKey:@"textColor"];
    NSFont *textFont = [NSFont systemFontOfSize:15.0];
    
    [self.textField setFont:textFont];
    [self.textField setTextColor:textColor];

    if (self.dividerView) {
        [self.dividerView setBorderColor:[self.theme colorForKey:@"dividerColor"]];
    }
    
    if (self.imageView.image) {
        NSString *imageName = [self.imageView.image.name stringByReplacingOccurrencesOfString:@"_highlighted" withString:@""];
        
        if (@available(macOS 10.14, *)) {
            // No imageName customization needed >= 10.14
        } else {
            if ([self.theme boolForKey:@"dark"] && ![imageName sp_containsString:@"dark"]) {
                imageName = [imageName stringByAppendingString:@"_dark"];
            } else if (![self.theme boolForKey:@"dark"] && [imageName sp_containsString:@"_dark"]) {
                imageName = [imageName stringByReplacingOccurrencesOfString:@"_dark" withString:@""];
            }
        }

        self.image = [NSImage imageNamed:imageName];

        [self updateTextAndImageColors];
    }
}

@end
