//
//  CustomToolbar.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/31/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPToolbarView.h"
#import "NoteListViewController.h"
#import "TagListViewController.h"
#import "SimplenoteAppDelegate.h"
#import "Note.h"
#import "NoteEditorBottomBar.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"
@import Simperium_OSX;

#define kSearchCollapsedMargin  62
#define kSearchCollapsedWidth   120
#define kSearchExpandedMargin   141
#define kSearchExpandedWidth    79
#define kFocusModeDuration      0.8f

@implementation SPToolbarView

- (VSTheme *)theme {

    return [[VSThemeManager sharedManager] theme];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    NSButtonCell *addNoteCell = [addButton cell];
    [addNoteCell setHighlightsBy:NSContentsCellMask];
    
    NSButtonCell *shareNoteCell = [self.actionButton cell];
    [shareNoteCell setHighlightsBy:NSContentsCellMask];
    
    [shareButton sendActionOn:NSEventMaskLeftMouseDown];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNoteLoaded:) name:SPNoNoteLoadedNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteLoaded:) name:SPNoteLoadedNotificationName object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trashDidLoad:) name:kDidBeginViewingTrash object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsDidLoad:) name:kTagsDidLoad object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trashDidEmpty:) name:kDidEmptyTrash object:nil];

    [self applyStyle];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if (_drawsBackground) {
        [[[[VSThemeManager sharedManager] theme] colorForKey:@"tableViewBackgroundColor"] setFill];
        NSRectFill(dirtyRect);
    }
    

    if (_drawsSeparator) {
        CGContextRef context    = [[NSGraphicsContext currentContext] graphicsPort];
        NSRect separator        = self.bounds;
        separator.size.height   = 1.0f;
        
        CGContextBeginPath(context);

        [[[[VSThemeManager sharedManager] theme] colorForKey:@"dividerColor"] setFill];
        CGContextFillRect(context, separator);
    }    
}

- (void)enableButtons:(BOOL)enabled {
    [self.actionButton setEnabled:enabled];
    [shareButton setEnabled:enabled];
    [trashButton setEnabled:enabled];
    [restoreButton setEnabled:enabled];
    [historyButton setEnabled:enabled];
    [previewButton setEnabled:enabled];
}

- (void)configureForFocusMode:(BOOL)enabled {
    [searchField setHidden:enabled];
    [addButton setHidden:enabled];
    [splitter setHidden:enabled];
}

- (void)noNoteLoaded:(id)sender {
    [self enableButtons:NO];
}

- (void)noteLoaded:(id)sender {
    [self enableButtons:YES];
}

- (void)configureForTrash:(BOOL)trash {
    [self.actionButton setEnabled:!trash];
    [shareButton setHidden:trash];
    [addButton setEnabled:!trash];
    [historyButton setHidden:trash];
    [trashButton setHidden:trash];
    [restoreButton setHidden:!trash];
    [noteEditor setEditable:!trash];
    [noteEditor setSelectable:!trash];
}

- (void)trashDidLoad:(NSNotification *)notification {
    [self configureForTrash:YES];
}

- (void)tagsDidLoad:(NSNotification *)notification {
    [self configureForTrash:NO];
}

- (void)trashDidEmpty:(NSNotification *)notification {
    [trashButton setEnabled:NO];
}

- (void)moveView:(NSView *)view x:(CGFloat)x y:(CGFloat)y {
    [view setFrame:NSMakeRect(view.frame.origin.x + x, view.frame.origin.y + y, view.frame.size.width, view.frame.size.height)];
    [view setNeedsLayout:YES];
}

- (void)setSplitPositionLeft:(CGFloat)left right:(CGFloat)right {
    CGFloat distance = right - splitter.frame.origin.x;
    if (distance == 0) {
        return;
    }

    BOOL collapsed = left <= 1;
    CGRect searchFrame = searchBox.frame;
    searchFrame.origin.x = collapsed ? kSearchCollapsedMargin : kSearchExpandedMargin;
    CGFloat searchFrameAdjustment = collapsed ? kSearchCollapsedWidth : kSearchExpandedWidth;
    searchFrame.size.width = tableViewController.view.frame.size.width - searchFrameAdjustment;
    [searchBox setFrame: searchFrame];
    
    [self moveView:addButton x:distance y:0];
    [self moveView:splitter x:distance y:0];
}

#pragma mark - Theme

- (void)applyStyle {
    [self applySearchBoxStyle];
    [splitter setFillColor:[self.theme colorForKey:@"dividerColor"]];
}

- (void)applySearchBoxStyle {
    if (@available(macOS 10.14, *)) {
        // Dark theme finally well supported in Mojave! No tweaks needed.
        return;
    }
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    [searchField setTextColor:[self.theme colorForKey:@"textColor"]];
    
    if (@available(macOS 10.10, *)) {
        if (theme.isDark) {
            searchField.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        } else {
            searchField.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        }
    }
}

@end
