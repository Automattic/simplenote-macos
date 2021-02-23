//
//  SimplenoteAppDelegate.h
//  Simplenote
//
//  Created by Michael Johnston on 11-08-22.
//  Copyright (c) 2011 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import Simperium_OSX;


@class MainWindowController;
@class NoteListViewController;
@class NoteEditorViewController;
@class TagListViewController;
@class SplitViewController;
@class AccountVerificationCoordinator;
@class VersionsController;
@class NoteEditorMetadataCache;

NS_ASSUME_NONNULL_BEGIN

#pragma mark ====================================================================================
#pragma mark SimplenoteAppDelegate
#pragma mark ====================================================================================

@interface SimplenoteAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, SimperiumDelegate>

@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator        *persistentStoreCoordinator;
@property (strong, nonatomic, readonly) NSManagedObjectModel                *managedObjectModel;
@property (strong, nonatomic, readonly) NSManagedObjectContext              *managedObjectContext;
@property (strong, nonatomic) Simperium                                     *simperium;

@property (assign, nonatomic, readonly) BOOL                                exportUnlocked;

@property (strong, nonatomic) MainWindowController                          *mainWindowController;
@property (strong, nonatomic) SplitViewController                           *splitViewController;
@property (strong, nonatomic) TagListViewController                         *tagListViewController;
@property (strong, nonatomic) NoteListViewController                        *noteListViewController;
@property (strong, nonatomic) NoteEditorViewController                      *noteEditorViewController;

@property (strong, nonatomic) AccountVerificationCoordinator                *verificationCoordinator;
@property (strong, nonatomic) VersionsController                            *versionsController;

@property (strong, nonatomic) NoteEditorMetadataCache                       *noteEditorMetadataCache;

+ (SimplenoteAppDelegate *)sharedDelegate;

- (IBAction)signOutAction:(nullable id)sender;
- (IBAction)toggleSidebarAction:(nullable id)sender;
- (IBAction)ensureMainWindowIsVisible:(nullable id)sender;
- (IBAction)aboutAction:(nullable id)sender;
- (IBAction)privacyAction:(nullable id)sender;
- (IBAction)helpAction:(nullable id)sender;

- (void)selectAllNotesTag;
- (void)selectNoteWithKey:(NSString *)simperiumKey;

@end

NS_ASSUME_NONNULL_END
