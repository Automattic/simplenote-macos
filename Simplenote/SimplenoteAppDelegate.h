//
//  SimplenoteAppDelegate.h
//  Simplenote
//
//  Created by Michael Johnston on 11-08-22.
//  Copyright (c) 2011 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VSTheme.h"
#import "SPBackgroundView.h"
@import Simperium_OSX;


@class NoteListViewController;
@class NoteEditorViewController;
@class TagListViewController;
@class SPToolbarView;

#pragma mark ====================================================================================
#pragma mark SimplenoteAppDelegate
#pragma mark ====================================================================================

@interface SimplenoteAppDelegate : NSObject <NSApplicationDelegate, NSSplitViewDelegate, NSWindowDelegate> {
    IBOutlet NSMenu *themeMenu;
    IBOutlet NSMenuItem *focusModeMenuItem;
    IBOutlet SPBackgroundView *backgroundView;
}

@property (strong, nonatomic, readonly) IBOutlet NSWindow                 *window;

@property (strong, nonatomic, readonly) IBOutlet TagListViewController    *tagListViewController;
@property (strong, nonatomic, readonly) IBOutlet NoteListViewController   *noteListViewController;
@property (strong, nonatomic, readonly) IBOutlet NoteEditorViewController *noteEditorViewController;

@property (strong, nonatomic, readonly) Simperium                         *simperium;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator      *persistentStoreCoordinator;
@property (strong, nonatomic, readonly) NSManagedObjectModel              *managedObjectModel;
@property (strong, nonatomic, readonly) NSManagedObjectContext            *managedObjectContext;

+ (SimplenoteAppDelegate *)sharedDelegate;

- (IBAction)signOutAction:(id)sender;
- (IBAction)emptyTrashAction:(id)sender;
- (IBAction)toggleSidebarAction:(id)sender;
- (IBAction)changeThemeAction:(id)sender;
- (IBAction)ensureMainWindowIsVisible:(id)sender;
- (IBAction)aboutAction:(id)sender;
- (IBAction)privacyAction:(id)sender;
- (IBAction)helpAction:(id)sender;

- (void)selectAllNotesTag;
- (void)selectNoteWithKey:(NSString *)simperiumKey;
- (NSString *)selectedTagName;
- (NSInteger)numDeletedNotes;
- (BOOL)isMainWindowVisible;

@end
