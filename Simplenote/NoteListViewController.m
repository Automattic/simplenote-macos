//
//  NoteListViewController.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/28/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "NoteListViewController.h"
#import "SPTableRowView.h"
#import "SPNoteCellView.h"
#import "Note.h"
#import "NoteEditorViewController.h"
#import "SimplenoteAppDelegate.h"
#import "NotesArrayController.h"
#import "TagListViewController.h"
#import "SPTableView.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"
#import "SPTracker.h"

@import Simperium_OSX;

CGFloat const kNoteRowHeight = 64;
CGFloat const kNoteListTopMargin = 12;
CGFloat const kNoteRowHeightCompact = 24;

NSString * const kAlphabeticalSortPref = @"kAlphabeticalSortPreferencesKey";
NSString * const kPreviewLinesPref = @"kPreviewLinesPref";

@implementation NoteListViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // awakeFromNib is called each time a cell is created; work around that (must be careful
    // not to register for notifications multiple times)
    // http://stackoverflow.com/a/7187492/1379066
    if (awake) {
        return;
    }
    
    oldTags = @"";

    // Set the active preferences in the menu
    int sortPrefPosition = [[NSUserDefaults standardUserDefaults] boolForKey:kAlphabeticalSortPref] ? 1 : 0;
    [self updateSortMenuForPosition:sortPrefPosition];
    int previewLinesPosition = [[NSUserDefaults standardUserDefaults] boolForKey:kPreviewLinesPref] ? 1 : 0;
    [self updatePreviewLinesMenuForPosition:previewLinesPosition];
    
    [progressIndicator setWantsLayer:YES];
    [progressIndicator setAlphaValue:0.5];
    [progressIndicator setHidden:YES];
    
    NSButtonCell *noteListToolbarCell = [self.noteListToolbarButton cell];
    [noteListToolbarCell setHighlightsBy:NSContentsCellMask];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notesArrayDidChange:)
                                                 name: kNotesArrayDidChangeNotification
                                               object: arrayController];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notesArraySelectionDidChange:)
                                                 name: kNotesArraySelectionDidChangeNotification
                                               object: arrayController];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didBeginViewingTrash:)
                                                 name: kDidBeginViewingTrash
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willFinishViewingTrash:)
                                                 name: kWillFinishViewingTrash
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didEmptyTrash:)
                                                 name: kDidEmptyTrash
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willAddNewNote:)
                                                 name: SPWillAddNewNoteNotificationName
                                               object: nil];
    
    awake = YES;

    self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    self.tableView.backgroundColor = [NSColor clearColor];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self applyStyle];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadNotes
{
    [arrayController fetch:self];
}

- (void)reset
{
    [self.searchField setStringValue:@""];
}

- (void)setNotesPredicate:(NSPredicate *)predicate
{
    [arrayController setFetchPredicate:predicate];
    arrayController.sortDescriptors = [self sortDescriptors];
    [arrayController rearrangeObjects];
    [self.tableView reloadData];

    // The re-fetch won't happen until next run loop
    [self performSelector:@selector(predicateDidChange) withObject:nil afterDelay:0];
}

- (NSArray *)sortDescriptors
{
    NSString *sortKey = nil;
    BOOL ascending = NO;
    SEL sortSelector = nil;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAlphabeticalSortPref]) {
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
    if ([[arrayController arrangedObjects] count] == 0) {
        [noteEditorViewController displayNote:nil];
        [statusField setHidden:NO];
    }
}

- (void)setWaitingForIndex:(BOOL)waiting
{
    if (waiting) {
        [progressIndicator setHidden:NO];
        [progressIndicator startAnimation:nil];
    } else {
        [progressIndicator setHidden:YES];
        [progressIndicator stopAnimation:nil];
    }
}


#pragma mark - Table view

- (NSInteger)rowForNoteKey:(NSString *)key
{
    NSInteger row = 0;
    for (Note *note in [arrayController arrangedObjects]) {
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

- (void)selectRow:(NSInteger)row
{
    if (row >= 0) {
        [arrayController setSelectionIndex:row];
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
    SPTableRowView *rowView = [[SPTableRowView alloc]initWithFrame:NSZeroRect];
    rowView.drawBorder = NO;
    return rowView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return rowHeight;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    SPNoteCellView *view = [tableView makeViewWithIdentifier:@"CustomCell" owner:self];
    Note *note = [[arrayController arrangedObjects] objectAtIndex:row];
    view.note = note;
    view.contentPreview.delegate = self.tableView;

    return view;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    BOOL shouldSelect = YES;
    if (preserveSelection && [self rowForNoteKey:noteEditorViewController.note.simperiumKey] != row) {
        shouldSelect = NO;
    }
    
    return shouldSelect;
}

- (NSArray *)selectedNotes
{
    return [[arrayController arrangedObjects] objectsAtIndexes:[self.tableView selectedRowIndexes]];
}

- (void)notesArrayDidChange:(NSNotification *)notification
{
    NSUInteger numNotes = [[arrayController arrangedObjects] count];
    
    // As soon as at least one note is added, select it
    if (numNotes > 0 && noteEditorViewController.note == nil) {
        [self selectRow:0];
    }
    
    [statusField setHidden:numNotes > 0];
    
    if (numNotes == 0)
        [noteEditorViewController displayNote:nil];
    else if (self.searching) {
        [self selectRow:0];
    }
}

- (void)notesArraySelectionDidChange:(NSNotification *)notification
{
    // Check for empty list and clear editor contents if necessary
    if ([[arrayController arrangedObjects] count] == 0) {
        [noteEditorViewController displayNote:nil];
    }
    
    NSInteger selectedRow = [self.tableView selectedRow];
    
    if (selectedRow < 0) {
        return;
    }

    if ([self.tableView numberOfSelectedRows] == 1) {
        Note *note = [[arrayController arrangedObjects] objectAtIndex:selectedRow];
        if (![note.simperiumKey isEqualToString: noteEditorViewController.note.simperiumKey]) {
            [SPTracker trackListNoteOpened];
            [noteEditorViewController displayNote:note];
        }
    } else {
        [noteEditorViewController displayNotes:[self selectedNotes]];
    }
}

- (void)reloadDataAndPreserveSelection
{
    preserveSelection = YES;
    // Reset the fetch predicate
    [arrayController setFetchPredicate:[arrayController fetchPredicate]];
    arrayController.sortDescriptors = [self sortDescriptors];
    [self.tableView reloadData];
    preserveSelection = NO;
    
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
            oldTags = note.tags;
        }
    }
}

- (void)noteKeysAdded:(NSSet *)keys
{
    [arrayController setFetchPredicate:[arrayController fetchPredicate]];
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
            [oldTags rangeOfString:tag].location != NSNotFound) {
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

- (void)didBeginViewingTrash:(NSNotification *)notification
{
    [SPTracker trackListTrashPressed];
    viewingTrash = YES;
}

- (void)willFinishViewingTrash:(NSNotification *)notification
{
    viewingTrash = NO;
}

- (void)didEmptyTrash:(NSNotification *)notification
{
    if ([[arrayController arrangedObjects] count] == 0) {
        [noteEditorViewController displayNote:nil];
        [statusField setHidden:NO];
    }
}

- (void)willAddNewNote:(NSNotification *)notification
{
    [self.searchField setStringValue:@""];
    [[self.searchField.cell cancelButtonCell] performClick:self];
    [self.searchField resignFirstResponder];
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
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    NSInteger currentRow = [self rowForNoteKey:note.simperiumKey];
    
    note.deleted = YES;
    [appDelegate.simperium save];
    
    // Select the next note, and handle deleting the last row
    if (currentRow == [self.tableView numberOfRows]) {
        currentRow -=1;
    }
	
    [self selectRow:currentRow];
}

- (void)deleteAction:(id)sender
{
    for (Note *selectedNote in [self selectedNotes]) {
        [self deleteNote:selectedNote];
    }
}

- (IBAction)sortPrefAction:(id)sender
{
    NSMenuItem *menuItem = (NSMenuItem*)sender;

    BOOL alphabeticalEnabled = menuItem.tag == 1;
    
    [SPTracker trackSettingsAlphabeticalSortEnabled:alphabeticalEnabled];
    
    [[NSUserDefaults standardUserDefaults] setBool:alphabeticalEnabled forKey:kAlphabeticalSortPref];
    [self updateSortMenuForPosition:menuItem.tag];
    [self reloadDataAndPreserveSelection];
}

- (void)updateSortMenuForPosition:(NSInteger)position
{
    for (NSMenuItem *menuItem in sortMenu.itemArray) {
        if (menuItem.tag == position) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }
}

- (IBAction)previewLinesAction:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    if (item.state == NSOnState) {
        return;
    }

    [self updatePreviewLinesMenuForPosition:item.tag];
    [self reloadDataAndPreserveSelection];

    // Only track when condensed setting is enabled
    if (item.tag == 1) {
        [SPTracker trackSettingsListCondensedEnabled];
    }
}

- (void)updatePreviewLinesMenuForPosition:(NSInteger)position
{
    for (NSMenuItem *menuItem in previewLinesMenu.itemArray) {
        if (menuItem.tag == position) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }

    rowHeight = (position == 1) ? kNoteRowHeightCompact : kNoteRowHeight;
    [[NSUserDefaults standardUserDefaults] setBool:(position == 1) forKey:kPreviewLinesPref];
}

- (void)searchAction:(id)sender
{
    [self.view.window makeFirstResponder:self.searchField];
}

#pragma mark - NSMenuValidation delegate

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    // Disable menu items when viewing trash
    return !viewingTrash;
}



#pragma mark - Theme

- (void)applyStyle
{
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    statusField.textColor = [theme colorForKey:@"emptyListViewFontColor"];
}

- (IBAction)filterNotes:(id)sender {
    NSString *searchText = [self.searchField stringValue];
    
    NSMutableArray *predicateList = [[NSMutableArray alloc] init];
    [predicateList addObject: [NSPredicate predicateWithFormat: @"deleted == %@", [NSNumber numberWithBool:viewingTrash]]];
    
    NSString *selectedTag = [[SimplenoteAppDelegate sharedDelegate] selectedTagName];
    if (selectedTag.length > 0) {
        // Match against "tagName" (JSON formatted)
        NSString *tagName = selectedTag;
        
        tagName = [tagName stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
        tagName = [tagName stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
        
        // individual tags are surrounded by quotes, thus adding quotes to the selected tag
        // ensures only the correct notes are shown
        NSString *match = [[NSString alloc] initWithFormat:@"\"%@\"", tagName];
        [predicateList addObject: [NSPredicate predicateWithFormat: @"tags CONTAINS[c] %@",match]];
    }
    
    if (searchText.length > 0) {
        NSArray *searchStrings = [searchText componentsSeparatedByString:@" "];
        for (NSString *word in searchStrings) {
            if (word.length == 0) {
                continue;
            }
            [predicateList addObject: [NSPredicate predicateWithFormat:@"content CONTAINS[c] %@", word]];
        }
    }
    
    NSPredicate *compound = [NSCompoundPredicate andPredicateWithSubpredicates:predicateList];
    [self setNotesPredicate:compound];
}

@end
