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
#import "VSThemeManager.h"

static CGFloat SPTagCellPopUpButtonAlpha    = 0.5f;

@interface SPTagCellView ()
@property (nonatomic, strong) SPPopUpButton     *button;
@property (nonatomic, strong) NSTrackingArea    *trackingArea;
@property (nonatomic, assign) BOOL              highlighted;
@property (nonatomic, assign) BOOL              mouseInside;
@end

@implementation SPTagCellView

- (VSTheme *)theme {
    return [[VSThemeManager sharedManager] theme];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.button];
    [self applyStyle];
}

- (SPPopUpButton *)button
{
    if (!_button) {
        CGRect textFrame = self.textField.frame;
        CGRect buttonFrame = CGRectMake(self.frame.size.width - textFrame.size.height,
                                        textFrame.origin.y,
                                        textFrame.size.height,
                                        textFrame.size.height
                                        );
        SPPopUpButton *button = [[SPPopUpButton alloc] initWithFrame:buttonFrame pullsDown:YES];
        button.bordered = NO;
        button.hidden = YES;
        button.alphaValue = SPTagCellPopUpButtonAlpha;
        _button = button;
    }
    
    return _button;
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

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseInside = YES;
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.mouseInside = NO;
    [[NSCursor arrowCursor] set];
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
// TODO: Background!
}

- (void)applyStyle
{
    NSColor *textColor = [self.theme colorForKey:@"textColor"];
    NSFont *textFont = [NSFont systemFontOfSize:15.0];
    
    [self.textField setFont:textFont];
    [self.textField setTextColor:textColor];
    [[self.button cell] setArrowColor:textColor];
    
    if (self.imageView.image) {
// TODO: Apply Tint Color

        [self updateTextAndImageColors];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.mouseInside = NO;
    [self applyStyle];
}

@end
