//
//  NoteListViewController.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/28/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Note.h"
#import "NoteListViewController.h"
#import "SPTokenField.h"

@import Simperium_OSX;

@class BackgroundView;
@class NoteEditorViewController;
@class SPTableView;

@interface NoteListViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, SimperiumDelegate, NSMenuDelegate>
{
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSMenu *sortMenu;
    IBOutlet NSMenu *previewLinesMenu;
    IBOutlet NSMenuItem *previewLinesMenuItem;
    NSString *oldTags;
    BOOL preserveSelection;
}

@property (strong, nonatomic) IBOutlet NSArrayController    *arrayController;
@property (strong, nonatomic) IBOutlet BackgroundView       *backgroundView;
@property (strong, nonatomic) IBOutlet BackgroundView       *topDividerView;
@property (strong, nonatomic) IBOutlet NSTextField          *statusField;
@property (strong, nonatomic) IBOutlet NSProgressIndicator  *progressIndicator;
@property (strong, nonatomic) IBOutlet SPTableView          *tableView;
@property (strong, nonatomic) IBOutlet NSSearchField        *searchField;
@property (strong, nonatomic) IBOutlet NSButton             *addNoteButton;
@property (assign, nonatomic) BOOL                          searching;
@property (assign, nonatomic) BOOL                          viewingTrash;

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
- (IBAction)sortPrefAction:(id)sender;
- (IBAction)previewLinesAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)filterNotes:(id)sender;
- (void)noteKeysWillChange:(NSSet *)keys;
- (void)noteKeyDidChange:(NSString *)key memberNames:(NSArray *)memberNames;

@end
