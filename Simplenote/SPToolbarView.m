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

- (void)enableButtons:(BOOL)enabled {
    [self.actionButton setEnabled:enabled];
    [shareButton setEnabled:enabled];
    [trashButton setEnabled:enabled];
    [restoreButton setEnabled:enabled];
    [historyButton setEnabled:enabled];
    [previewButton setEnabled:enabled];
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
