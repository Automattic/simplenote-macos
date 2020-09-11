//
//  NoteListViewController.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/28/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "NoteListViewController.h"
#import "Note.h"
#import "NoteEditorViewController.h"
#import "SimplenoteAppDelegate.h"
#import "NotesArrayController.h"
#import "TagListViewController.h"
#import "SPTableView.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"

@import Simperium_OSX;


@interface NoteListViewController ()
@property (nonatomic, strong) IBOutlet NSArrayController    *arrayController;
@property (nonatomic, strong) IBOutlet BackgroundView       *backgroundView;
@property (nonatomic, strong) IBOutlet BackgroundView       *topDividerView;
@property (nonatomic, strong) IBOutlet NSTextField          *statusField;
@property (nonatomic, strong) IBOutlet NSProgressIndicator  *progressIndicator;
@property (nonatomic, strong) IBOutlet SPTableView          *tableView;
@property (nonatomic, strong) IBOutlet NSView               *searchView;
@property (nonatomic, strong) IBOutlet NSSearchField        *searchField;
@property (nonatomic, strong) IBOutlet NSButton             *addNoteButton;
@property (nonatomic, strong) IBOutlet NSMenu               *noteListMenu;
@property (nonatomic, strong) IBOutlet NSMenu               *trashListMenu;
@property (nonatomic, strong) NSString                      *oldTags;
@property (nonatomic, assign) BOOL                          searching;
@property (nonatomic, assign) BOOL                          viewingTrash;
@property (nonatomic, assign) BOOL                          preserveSelection;
@end

@implementation NoteListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.oldTags = @"";
    self.arrayController.managedObjectContext = self.mainContext;

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notesArrayDidChange:)
                                                 name: kNotesArrayDidChangeNotification
                                               object: self.arrayController];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notesArraySelectionDidChange:)
                                                 name: kNotesArraySelectionDidChangeNotification
                                               object: self.arrayController];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(displayModeDidChange:)
                                                 name: NoteListDisplayModeDidChangeNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(sortModeDidChange:)
                                                 name: NoteListSortModeDidChangeNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didBeginViewingTag:)
                                                 name: TagListDidBeginViewingTagNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didBeginViewingTrash:)
                                                 name: TagListDidBeginViewingTrashNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didEmptyTrash:)
                                                 name: TagListDidEmptyTrashNotification
                                               object: nil];

    [self setupProgressIndicator];
    [self setupSearchBar];
    [self setupTableView];
    [self setupTopDivider];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self applyStyle];
}

- (void)loadNotes
{
    [self.arrayController fetch:self];
}

- (void)reloadSynchronously
{
    [self.arrayController fetchWithRequest:nil merge:NO error:nil];
}

// TODO: Work in Progress. Decouple with a delegate please
//
- (NoteEditorViewController *)noteEditorViewController
{
    return [[SimplenoteAppDelegate sharedDelegate] noteEditorViewController];
}

- (NSManagedObjectContext*)mainContext
{
    return [[SimplenoteAppDelegate sharedDelegate] managedObjectContext];
}

- (void)reset
{
    [self.searchField setStringValue:@""];
}

- (void)setNotesPredicate:(NSPredicate *)predicate
{
    [self.arrayController setFetchPredicate:predicate];
    self.arrayController.sortDescriptors = [self sortDescriptors];
    [self.arrayController rearrangeObjects];
    [self.tableView reloadData];

    // The re-fetch won't happen until next run loop
    [self performSelector:@selector(predicateDidChange) withObject:nil afterDelay:0];
}

- (NSArray *)sortDescriptors
{
    NSString *sortKey = nil;
    BOOL ascending = NO;
    SEL sortSelector = nil;

    if ([[Options shared] alphabeticallySortNotes]) {
        sortKey = @"content";
        ascending = YES;
        sortSelector = @selector(caseInsensitiveCompare:);
    } else {
        sortKey = @"modificationDate";
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending selector:sortSelector];
    NSSortDescriptor *pinnedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pinned" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:pinnedSortDescriptor, sortDescriptor, nil];

    return sortDescriptors;
}

- (void)predicateDidChange
{
    if (self.allNotes.count != 0) {
        return;
    }

    [self.noteEditorViewController displayNote:nil];
    [self.statusField setHidden:NO];
}

- (void)setWaitingForIndex:(BOOL)waiting
{
    if (waiting) {
        [self.progressIndicator setHidden:NO];
        [self.progressIndicator startAnimation:nil];
    } else {
        [self.progressIndicator setHidden:YES];
        [self.progressIndicator stopAnimation:nil];
    }
}


#pragma mark - Table view

- (NSInteger)rowForNoteKey:(NSString *)key
{
    NSInteger row = 0;
    for (Note *note in [self.arrayController arrangedObjects]) {
        if ([note.simperiumKey isEqualToString:key])
            return row;
        row += 1;
    }
    
    return -1;
}

- (void)reloadRowForNoteKey:(NSString *)key
{
    NSInteger row = [self rowForNoteKey:key];
    
    if (row >= 0) {
        [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
}

- (void)selectFirstRow
{
    [self selectRow:0];
}

- (void)selectRow:(NSInteger)row
{
    if (row >= 0) {
        [self.arrayController setSelectionIndex:row];
    }
}

- (void)scrollToRow:(NSInteger)row
{
    if (row >= 0) {
        [self.tableView scrollRowToVisible:row];
    }
}

- (void)selectRowForNoteKey:(NSString *)key
{
    NSInteger row = [self rowForNoteKey:key];
    [self selectRow:row];
    [self scrollToRow:row];
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    TableRowView *rowView = [TableRowView new];
    rowView.selectedBackgroundColor = [NSColor simplenoteSecondarySelectedBackgroundColor];
    return rowView;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Note *note = [self.arrayController.arrangedObjects objectAtIndex:row];
    return [self noteTableViewCellForNote:note];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    BOOL shouldSelect = YES;
    if (self.preserveSelection && [self rowForNoteKey:self.noteEditorViewController.note.simperiumKey] != row) {
        shouldSelect = NO;
    }
    
    return shouldSelect;
}

- (NSArray *)selectedNotes
{
    return [self.allNotes objectsAtIndexes:[self.tableView selectedRowIndexes]];
}

- (NSArray<Note *> *)allNotes
{
    return self.arrayController.arrangedObjects;
}

- (void)notesArrayDidChange:(NSNotification *)notification
{
    NSUInteger numNotes = self.allNotes.count;
    
    // As soon as at least one note is added, select it
    if (numNotes > 0 && self.noteEditorViewController.note == nil) {
        [self selectRow:0];
    }
    
    self.statusField.hidden = numNotes > 0;
    
    if (numNotes == 0) {
        [self.noteEditorViewController displayNote:nil];
    } else if (self.searching) {
        [self selectRow:0];
    }
}

- (void)notesArraySelectionDidChange:(NSNotification *)notification
{
    // Check for empty list and clear editor contents if necessary
    if (self.allNotes.count == 0) {
        [self.noteEditorViewController displayNote:nil];
    }
    
    NSInteger selectedRow = [self.tableView selectedRow];
    
    if (selectedRow < 0) {
        return;
    }

    if ([self.tableView numberOfSelectedRows] == 1) {
        Note *note = [[self.arrayController arrangedObjects] objectAtIndex:selectedRow];
        if (![note.simperiumKey isEqualToString: self.noteEditorViewController.note.simperiumKey]) {
            [SPTracker trackListNoteOpened];
            [self.noteEditorViewController displayNote:note];
        }
    } else {
        [self.noteEditorViewController displayNotes:[self selectedNotes]];
    }
}

- (void)reloadDataAndPreserveSelection
{
    self.preserveSelection = YES;
    // Reset the fetch predicate
    [self.arrayController setFetchPredicate:self.arrayController.fetchPredicate];
    self.arrayController.sortDescriptors = [self sortDescriptors];
    [self.tableView reloadData];
    self.preserveSelection = NO;
    
    // Force array change logic to run in the next run loop
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self notesArrayDidChange:nil];
    });
}

#pragma mark - Notification handlers

- (void)noteKeysWillChange:(NSSet *)keys
{
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    
    // Track recently deleted tags so we can update notes list if currently selected tag matches recently deleted tag
    for (NSString *key in keys) {
        Note *note = [[[appDelegate simperium] bucketForName:@"Note"] objectForKey:key];
        if (note.tags) {
            self.oldTags = note.tags;
        }
    }
}

- (void)noteKeysAdded:(NSSet *)keys
{
    [self.arrayController setFetchPredicate:[self.arrayController fetchPredicate]];
    [self.tableView reloadData];
}

- (void)noteKeyDidChange:(NSString *)key memberNames:(NSArray *)memberNames
{
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    NSString *tag = [appDelegate selectedTagName];

    BOOL needsReloadData = NO;
    if (tag) {
        Note *note = [[[appDelegate simperium] bucketForName:@"Note"] objectForKey:key];
        
        // Update notes list if note has new tag that matches currently selected tag OR
        // if note had tag deleted from the currently selected tag
        if ([note.tags rangeOfString:tag].location != NSNotFound ||
            [self.oldTags rangeOfString:tag].location != NSNotFound) {
            needsReloadData = YES;
        }
    }
    
    // Remote deletions don't update the array controller automatically, so refresh manually
    if ([memberNames indexOfObject:@"deleted"] != NSNotFound) {
        needsReloadData = YES;
    }
    
    if (needsReloadData) {
        [self reloadDataAndPreserveSelection];
    }
    
    // Previews in the note list won't update automatically, so do it manually
    [self reloadRowForNoteKey:key];
}

- (void)didBeginViewingTag:(NSNotification *)notification
{
    self.viewingTrash = NO;
    [self selectedTaglistRowWasUpdated];
}

- (void)didBeginViewingTrash:(NSNotification *)notification
{
    [SPTracker trackListTrashPressed];
    self.viewingTrash = YES;
    [self selectedTaglistRowWasUpdated];
}

- (void)didEmptyTrash:(NSNotification *)notification
{
    if (self.allNotes.count != 0) {
        return;
    }

    [self.noteEditorViewController displayNote:nil];
    [self.statusField setHidden:NO];
}

- (void)selectedTaglistRowWasUpdated
{
    [self refreshTableViewMenu];
    [self refreshEnabledActions];
    [self refreshPredicate];
    [self selectFirstRow];
}


#pragma mark - NSSearchFieldDelegate

- (void)controlTextDidBeginEditing:(NSNotification *)notification
{
    [SPTracker trackListNotesSearched];
    self.searching = YES;
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    [self selectRow:0];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    self.searching = NO;
}

#pragma mark - Actions

- (void)deleteNote:(Note *)note
{
    [SPTracker trackListNoteDeleted];
    
    [self performPerservingSelectedIndexWithBlock:^{
        note.deleted = YES;
        [[[SimplenoteAppDelegate sharedDelegate] simperium] save];
    }];
}

- (void)deleteAction:(id)sender
{
    for (Note *selectedNote in [self selectedNotes]) {
        [self deleteNote:selectedNote];
    }
}

- (IBAction)newNoteWasPressed:(id)sender
{
    // TODO: Move the New Note Handler to a (New) NoteController!
    [self.noteEditorViewController newNoteWasPressed:sender];
}

- (void)searchAction:(id)sender
{
    [self.view.window makeFirstResponder:self.searchField];
}


#pragma mark - IBActions

- (IBAction)filterNotes:(id)sender
{
    [self refreshPredicate];
}

@end
