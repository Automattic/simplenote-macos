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
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"
#import "NSColor+Simplenote.h"
@import Simperium_OSX;


@implementation SPToolbarView

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSButtonCell *addNoteCell = [addButton cell];
    [addNoteCell setHighlightsBy:NSContentsCellMask];
    
    NSButtonCell *shareNoteCell = [self.actionButton cell];
    [shareNoteCell setHighlightsBy:NSContentsCellMask];
    
    [shareButton sendActionOn:NSEventMaskLeftMouseDown];

    [self startListeningToNotifications];
    [self applyStyle];
}

#pragma mark - Notifications

- (void)startListeningToNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(noNoteLoaded:) name:SPNoNoteLoadedNotificationName object:nil];
    [nc addObserver:self selector:@selector(noteLoaded:) name:SPNoteLoadedNotificationName object:nil];
    [nc addObserver:self selector:@selector(trashDidLoad:) name:kDidBeginViewingTrash object:nil];
    [nc addObserver:self selector:@selector(tagsDidLoad:) name:kTagsDidLoad object:nil];
    [nc addObserver:self selector:@selector(trashDidEmpty:) name:kDidEmptyTrash object:nil];
}

- (void)noNoteLoaded:(NSNotification *)sender
{
    [self enableButtons:NO];
}

- (void)noteLoaded:(NSNotification *)sender
{
    [self enableButtons:YES];
}

- (void)trashDidLoad:(NSNotification *)notification
{
    [self configureForTrash:YES];
}

- (void)tagsDidLoad:(NSNotification *)notification
{
    [self configureForTrash:NO];
}

- (void)trashDidEmpty:(NSNotification *)notification
{
    [trashButton setEnabled:NO];
}


#pragma mark - Private

- (void)enableButtons:(BOOL)enabled
{
    [self.actionButton setEnabled:enabled];
    [shareButton setEnabled:enabled];
    [trashButton setEnabled:enabled];
    [restoreButton setEnabled:enabled];
    [historyButton setEnabled:enabled];
    [previewButton setEnabled:enabled];
}

- (void)configureForTrash:(BOOL)trash
{
    [self.actionButton setEnabled:!trash];
    [shareButton setHidden:trash];
    [addButton setEnabled:!trash];
    [historyButton setHidden:trash];
    [trashButton setHidden:trash];
    [restoreButton setHidden:!trash];
    [noteEditor setEditable:!trash];
    [noteEditor setSelectable:!trash];
}


#pragma mark - Theme

- (void)applyStyle
{
    // Dark theme finally well supported in Mojave! No tweaks needed.
    if (@available(macOS 10.14, *)) {
        return;
    }
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    [searchField setTextColor:[theme colorForKey:@"textColor"]];

    NSAppearanceName name = theme.isDark ? NSAppearanceNameVibrantDark : NSAppearanceNameAqua;
    searchField.appearance = [NSAppearance appearanceNamed:name];
}

@end
