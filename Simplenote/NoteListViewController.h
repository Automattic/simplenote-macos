//
//  NoteListViewController.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/28/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Note.h"
#import "SPNoteCellView.h"
#import "NoteListViewController.h"
#import "SPTokenField.h"
#import "SPGradientView.h"
@import Simperium_OSX;

@class NoteEditorViewController;
@class SPTableView;

@interface NoteListViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, SimperiumDelegate, NSMenuDelegate>
{
    IBOutlet NSWindow *window;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSArrayController *arrayController;
    IBOutlet NoteEditorViewController *noteEditorViewController;
    IBOutlet NSTextView *noteEditor;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *statusField;
    IBOutlet NSMenu *sortMenu;
    IBOutlet NSMenu *previewLinesMenu;
    IBOutlet NSMenuItem *previewLinesMenuItem;
    NSString *oldTags;
    BOOL preserveSelection;
    BOOL viewingTrash;
    BOOL awake;
    CGFloat rowHeight;
}

@property (strong, nonatomic) IBOutlet SPTableView      *tableView;
@property (strong, nonatomic) IBOutlet NSSearchField    *searchField;
@property (strong, nonatomic) IBOutlet NSButton         *noteListToolbarButton;
@property (assign, nonatomic) BOOL                      searching;

- (void)loadNotes;
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
- (void)applyStyle;

@end
