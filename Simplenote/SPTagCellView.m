//
//  CustomTagView.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/30/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPTagCellView.h"
#import "SPButtonNoBackground.h"
#import "SPPopUpButton.h"
#import "SPPopUpButtonCell.h"
#import "NSImage+Colorize.h"
#import "NSString+Simplenote.h"
#import "NSApplication+Helpers.h"
#import "VSThemeManager.h"


static NSRect SPTagCellPopUpButtonFrame     = {132.0f, 0.0f, 15.0f, 38.0f};
static CGFloat SPTagCellPopUpButtonAlpha    = 0.5f;


@interface SPTagCellView ()
@property (nonatomic, strong) SPPopUpButton     *button;
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

    [self addSubview:self.button];
    [self applyStyle];
}

- (SPPopUpButton *)button
{
    if (!_button) {
        SPPopUpButton *button = [[SPPopUpButton alloc] initWithFrame:SPTagCellPopUpButtonFrame pullsDown:YES];
        button.bordered = NO;
        button.autoresizingMask = NSViewMinXMargin;
        button.hidden = YES;
        button.alphaValue = SPTagCellPopUpButtonAlpha;
        _button = button;
    }
    
    return _button;
}

- (void)setDropdownMenu:(NSMenu *)menu
{
    if (menu == nil) {
        return;
    }
    
    self.button.menu = menu;
}

- (void)setMouseInside:(BOOL)value
{
    if (_mouseInside == value) {
        return;
    }
    
    _mouseInside = value;
    [self updateTextAndImageColors];
    [self setNeedsDisplay:YES];
    
    // Display the Menu -If it has at least one item!-
    if (self.button.menu.itemArray.count > 0) {
        [self.button setHidden:!_mouseInside];
    }
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

- (void)positionButtonRelativeToTextField
{
    NSDictionary *attributes = @{NSFontSizeAttribute: @14.0};
    NSSize tagSize = [self.textField.stringValue sizeWithAttributes:attributes];
    CGFloat buttonX = self.textField.frame.origin.x + tagSize.width + 10;
    [self.button setFrameOrigin:CGPointMake(buttonX, self.button.frame.origin.y)];
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

    if ([NSApplication isRunningYosemiteOrHigher]) {
        self.textField.wantsLayer   = YES;
        self.textField.alphaValue   = alphaValue;
    }
}

- (void)setSelected:(BOOL)selected
{
    BOOL changed = _highlighted != selected;

    _highlighted = selected;

    if (changed) {
        [self updateTextAndImageColors];
    }    
}

- (void)applyStyle
{
    NSColor *textColor = [self.theme colorForKey:@"textColor"];
    NSFont *textFont = [NSFont systemFontOfSize:15.0];
    
    [self.textField setFont:textFont];
    [self.textField setTextColor:textColor];
    [[self.button cell] setArrowColor:textColor];
    
    if (self.dividerView) {
        [self.dividerView setBorderColor:[self.theme colorForKey:@"dividerColor"]];
    }
    
    if (self.imageView.image) {
        NSString *imageName = [self.imageView.image.name stringByReplacingOccurrencesOfString:@"_highlighted" withString:@""];
        if ([self.theme boolForKey:@"dark"] && ![imageName sp_containsString:@"dark"]) {
            imageName = [imageName stringByAppendingString:@"_dark"];
        } else if (![self.theme boolForKey:@"dark"] && [imageName sp_containsString:@"_dark"]) {
            imageName = [imageName stringByReplacingOccurrencesOfString:@"_dark" withString:@""];
        }

        self.image = [NSImage imageNamed:imageName];

        [self updateTextAndImageColors];
    }
}

@end
