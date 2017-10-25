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
#import "NSColor+Simplenote.h"
#import "NSApplication+Helpers.h"
@import Simperium_OSX;


@implementation SPToolbarView

- (VSTheme *)theme {

    return [[VSThemeManager sharedManager] theme];
}

- (void)awakeFromNib {
    NSButtonCell *addNoteCell = [addButton cell];
    [addNoteCell setHighlightsBy:NSContentsCellMask];
    
    NSButtonCell *shareNoteCell = [self.actionButton cell];
    [shareNoteCell setHighlightsBy:NSContentsCellMask];

    NSButtonCell *sidebarCell = [sidebarButton cell];
    [sidebarCell setHighlightsBy:NSContentsCellMask];
    
    NSButtonCell *restoreCell = [restoreButton cell];
    [restoreCell setHighlightsBy:NSContentsCellMask];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNoteLoaded:) name:SPNoNoteLoadedNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteLoaded:) name:SPNoteLoadedNotificationName object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trashDidLoad:) name:kDidBeginViewingTrash object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsDidLoad:) name:kTagsDidLoad object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trashDidEmpty:) name:kDidEmptyTrash object:nil];
    
    [addButton setWantsLayer:YES];
    [searchBox setWantsLayer:YES];
    [splitter setWantsLayer:YES];

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
        separator.size.height   = 1.0f / [[NSScreen mainScreen] backingScaleFactor];
        
        CGContextBeginPath(context);

        [[[[VSThemeManager sharedManager] theme] colorForKey:@"dividerColor"] setFill];
        CGContextFillRect(context, separator);
    }    
}

- (void)enableButtons:(BOOL)enabled {
    [self.actionButton setEnabled:enabled];
    // Must set actionButton image each time we enable it again?
    [self applyActionButtonStyle];
    [restoreButton setEnabled:enabled];
}

- (void)noNoteLoaded:(id)sender {
    [self enableButtons:NO];
}

- (void)noteLoaded:(id)sender {
    [self enableButtons:YES];
}

- (void)configureForTrash:(BOOL)trash {
    [[self.actionButton itemAtIndex:0] setEnabled:!trash];
    [addButton setEnabled:!trash];
    
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
    [restoreButton setEnabled:NO];
}

- (void)moveView:(NSView *)view x:(CGFloat)x y:(CGFloat)y {
    [[view animator] setFrame:NSMakeRect(view.frame.origin.x + x, view.frame.origin.y + y, view.frame.size.width, view.frame.size.height)];
    [view setNeedsLayout:YES];
}

- (void)setFullscreen:(BOOL)fullscreen {
    // Account for fullscreen button going away
    int moveRightX = fullscreen ? 36 : -36;
    [self moveView:self.actionButton x:moveRightX y:0];

// This was hiding the button, actually!
//     Account for traffic lights going away
//    int moveLeftDistance = fullscreen ? -80 : 80;
//    [self moveView:sidebarButton x:moveLeftDistance y:0];
}

- (void)setSplitPositionLeft:(CGFloat)left right:(CGFloat)right {
    CGFloat distance = right - splitter.frame.origin.x;
    
    if (distance == 0)
        return;
    
    BOOL collapsed = left <= 1;
    CGRect searchFrame = searchBox.frame;
    searchFrame.origin.x = collapsed ? 48 : 156;
    searchFrame.size.width = collapsed ? 160 : 190;
    [[searchBox animator] setFrame: searchFrame];
    
    [self moveView:addButton x:distance y:0];
    [self moveView:splitter x:distance y:0];
}

#pragma mark - Theme

- (void)applyStyle {
    [self applyActionButtonStyle];
    [self applySearchBoxStyle];
}

- (void)applyActionButtonStyle {
    BOOL isDarkTheme = [[[VSThemeManager sharedManager] theme] isDark];
    NSString *actionButtonName = [@"button_action" stringByAppendingString:isDarkTheme ? @"_dark" : @""];
    
    NSMenuItem *imageItem = [[NSMenuItem alloc] init];
    [imageItem setImage:[NSImage imageNamed:actionButtonName]];
    [[self.actionButton cell] setMenuItem:imageItem];
}

- (void)applySearchBoxStyle {
    [searchBox setFillColor:[self.theme colorForKey:@"tableViewBackgroundColor"]];
}

@end
