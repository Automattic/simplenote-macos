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


@class SPToolbarView;

#pragma mark ====================================================================================
#pragma mark SimplenoteAppDelegate
#pragma mark ====================================================================================

@interface SimplenoteAppDelegate : NSObject <NSApplicationDelegate, NSSplitViewDelegate, NSWindowDelegate> {
    IBOutlet NSMenu *themeMenu;
    IBOutlet NSMenuItem *focusModeMenuItem;
    IBOutlet SPBackgroundView *backgroundView;
}

@property (strong, nonatomic) IBOutlet NSWindow                 *window;
@property (strong, nonatomic) IBOutlet SPToolbarView            *toolbar;

@property (strong, nonatomic) Simperium                         *simperium;
@property (strong, nonatomic) NSPersistentStoreCoordinator      *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel              *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext            *managedObjectContext;

+ (SimplenoteAppDelegate *)sharedDelegate;

- (IBAction)signOutAction:(id)sender;
- (IBAction)emptyTrashAction:(id)sender;
- (IBAction)toggleSidebarAction:(id)sender;
- (IBAction)changeThemeAction:(id)sender;
- (IBAction)ensureMainWindowIsVisible:(id)sender;
- (IBAction)aboutAction:(id)sender;

- (void)selectAllNotesTag;
- (void)selectNoteWithKey:(NSString *)simperiumKey;
- (NSString *)selectedTagName;
- (NSInteger)numDeletedNotes;
- (BOOL)isMainWindowVisible;

@end
