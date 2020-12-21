//
//  NoteListViewController.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/28/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Note.h"
@import Simperium_OSX;

@class BackgroundView;
@class SPTableView;


NS_ASSUME_NONNULL_BEGIN

@interface NoteListViewController : NSViewController <NSTableViewDataSource, NSTextFieldDelegate, SimperiumDelegate, NSMenuDelegate>

@property (nonatomic, strong, readonly) IBOutlet NSArrayController      *arrayController;
@property (nonatomic, strong, readonly) IBOutlet NSBox                  *backgroundBox;
@property (nonatomic, strong, readonly) IBOutlet NSTextField            *titleLabel;
@property (nonatomic, strong, readonly) IBOutlet NSTextField            *statusField;
@property (nonatomic, strong, readonly) IBOutlet NSProgressIndicator    *progressIndicator;
@property (nonatomic, strong, readonly) IBOutlet NSScrollView           *scrollView;
@property (nonatomic, strong, readonly) IBOutlet NSClipView             *clipView;
@property (nonatomic, strong, readonly) IBOutlet SPTableView            *tableView;
@property (nonatomic, strong, readonly) IBOutlet NSVisualEffectView     *headerEffectView;
@property (nonatomic, strong, readonly) IBOutlet NSButton               *addNoteButton;
@property (nonatomic, strong, readonly) IBOutlet NSMenu                 *noteListMenu;
@property (nonatomic, strong, readonly) IBOutlet NSMenu                 *trashListMenu;
@property (nonatomic, strong, nullable) NSLayoutConstraint              *titleSemaphoreLeadingConstraint;

@property (nonatomic, assign, readonly) BOOL                            viewingTrash;
@property (nonatomic, strong, nullable) NSString                        *searchKeyword;

- (void)reloadSynchronously;
- (void)setWaitingForIndex:(BOOL)waiting;
- (NSArray<Note *> *)selectedNotes;
- (void)setNotesPredicate:(NSPredicate *)predicate;
- (BOOL)displaysNoteForKey:(NSString *)key;
- (NSInteger)rowForNoteKey:(NSString *)key;
- (void)selectRow:(NSInteger)row;
- (void)selectRowForNoteKey:(NSString *)key;
- (void)reloadRowForNoteKey:(NSString *)key;
- (void)reloadDataAndPreserveSelection;
- (void)deleteNote:(Note *)note;
- (IBAction)deleteAction:(id)sender;
- (void)noteKeysWillChange:(NSSet *)keys;
- (void)noteKeyDidChange:(NSString *)key memberNames:(NSArray *)memberNames;

@end

NS_ASSUME_NONNULL_END
