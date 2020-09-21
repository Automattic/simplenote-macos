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

@interface NoteListViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, SimperiumDelegate, NSMenuDelegate>

@property (nonatomic, strong, readonly) IBOutlet NSArrayController      *arrayController;
@property (nonatomic, strong, readonly) IBOutlet BackgroundView         *backgroundView;
@property (nonatomic, strong, readonly) IBOutlet BackgroundView         *topDividerView;
@property (nonatomic, strong, readonly) IBOutlet NSTextField            *statusField;
@property (nonatomic, strong, readonly) IBOutlet NSProgressIndicator    *progressIndicator;
@property (nonatomic, strong, readonly) IBOutlet SPTableView            *tableView;
@property (nonatomic, strong, readonly) IBOutlet NSView                 *searchView;
@property (nonatomic, strong, readonly) IBOutlet NSSearchField          *searchField;
@property (nonatomic, strong, readonly) IBOutlet NSButton               *addNoteButton;

@property (nonatomic, strong, nullable) NSLayoutConstraint              *searchViewTopConstraint;
@property (nonatomic, assign, readonly) BOOL                            searching;
@property (nonatomic, assign, readonly) BOOL                            viewingTrash;

- (void)loadNotes;
- (void)reloadSynchronously;
- (void)reset;
- (void)setWaitingForIndex:(BOOL)waiting;
- (void)setNotesPredicate:(NSPredicate *)predicate;
- (NSInteger)rowForNoteKey:(NSString *)key;
- (void)selectRow:(NSInteger)row;
- (void)selectRowForNoteKey:(NSString *)key;
- (void)reloadRowForNoteKey:(NSString *)key;
- (void)reloadDataAndPreserveSelection;
- (void)deleteNote:(Note *)note;
- (IBAction)deleteAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)filterNotes:(id)sender;
- (void)noteKeysWillChange:(NSSet *)keys;
- (void)noteKeyDidChange:(NSString *)key memberNames:(NSArray *)memberNames;

@end

NS_ASSUME_NONNULL_END
