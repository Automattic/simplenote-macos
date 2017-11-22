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
#import "NSApplication+Helpers.h"
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

    if ([NSApplication isRunningMavericksOrLower]) {
        previewLinesMenuItem.hidden = YES;
    }
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
    if ([NSApplication isRunningMavericksOrLower]) {
        return (row == 0) ? (kNoteRowHeight + kNoteListTopMargin) : kNoteRowHeight;
    }
    
    return rowHeight;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    SPNoteCellView *view = [tableView makeViewWithIdentifier:@"CustomCell" owner:self];
    Note *note = [[arrayController arrangedObjects] objectAtIndex:row];
    view.note = note;
    view.contentPreview.delegate = self.tableView;
    
    if ([NSApplication isRunningMavericksOrLower]) {
        view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
        view.contentPreview.autoresizingMask = NSViewMaxYMargin | NSViewWidthSizable;
    }
    
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
    
    /**
        NOTE:
        This is a horrible hack. NSSearchField is drawing an orange glow around the Search Text, once the control looses the focus.
        We'll apply the exact same text, with extra properties, so that there is no orange glow.
     */
    [self hackSearchFieldStyle];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hackSearchFieldStyle];
    });
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
    [self applyStatusStyle];
    [self applyTableStyle];
    [self applySearchFieldStyle];
}

- (void)applyTableStyle
{
    [self.tableView setBackgroundColor:[NSColor clearColor]];
}

- (void)applyStatusStyle
{
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    statusField.textColor = [theme colorForKey:@"emptyListViewFontColor"];
}

- (void)applySearchFieldStyle
{
/**
    NOTE:
    Switching NSSearchField Style(s) on the fly has proven to be near impossible:
 
    -   When the searchField has a rounded bezel style, it won't render a background. Toggling the bezelStyle property, on the fly,
        causes the instance not to properly redraw, even when calling explicitly *setNeedsDisplay*. (I promise, tried every single possible combination).
 
    -   Subclassing NSSearchFieldCell (as of OSX 10.10), and simply overriding 'drawWithFrame:inView:' (even just with a one line call to superview)
        breaks the Loupe animation.
 
    -   Furthermore, even when subclassing NSSearchFieldCell and reimplementing the whole draw logic (Loupe + Placeholder + Cancel button),
        whenever the control gains focus, the NSWindow's NSTextView instance takes over, and may draw itself on top of the loupe control.
 
    For the reasons outlined above, the solution that requires the less code delta (say: implementing our own NSSearchField from scratch) is to simply
    instantiate a new SearchField each time the theme changes (and replace the previous one).
 
    *Sorry*, this will be revisited in the future. Below we'll do the following:
 */

    // Setup Bindings with the NoteList-ArrayController
    NSSearchField *refreshedSearchField = [self newSearchField];

    // Update Bindings
    [self setupBindingsWithSearchField:refreshedSearchField arrayController:arrayController];
    [self removeBindingsForSearchField:self.searchField];
    
    // Replace SearchFields
    refreshedSearchField.frame = self.searchField.frame;
    [self.view replaceSubview:self.searchField with:refreshedSearchField];
    self.searchField = refreshedSearchField;
}


#pragma mark - Search Field Helpers

- (NSSearchField *)newSearchField
{
    VSTheme *theme                  = [[VSThemeManager sharedManager] theme];
    NSSearchField *newSearchField   = [[NSSearchField alloc] initWithFrame:NSZeroRect];
    
    if (theme.isDark) {
        newSearchField.drawsBackground  = YES;
        newSearchField.bordered     = YES;
        newSearchField.bezelStyle   = NSTextFieldSquareBezel;
    } else {
        newSearchField.bezelStyle   = NSTextFieldRoundedBezel;
        newSearchField.alphaValue   = 0.6f;
    }
    
    newSearchField.font             = [NSFont systemFontOfSize:13];
    newSearchField.backgroundColor  = [theme colorForKey:@"searchFieldBackgroundColor"];
    newSearchField.textColor        = [theme colorForKey:@"searchBarFontColor"];
    newSearchField.autoresizingMask = NSViewWidthSizable | NSViewMaxXMargin | NSViewMaxYMargin;
    
    // Note:
    // 'NSSearchFieldDelegate' was introduced in OSX 10.11. Before that, the delegate field expected a `NSTextFieldDelegate` conforming instance.
    // Hack to shut off the warning, we're all good!
    newSearchField.delegate         = (id)self;
    
    // Setup the Placeholder
    NSDictionary *colorAttribute    = @{
        NSForegroundColorAttributeName  : [theme colorForKey:@"searchBarFontColor"],
        NSStrokeWidthAttributeName      : @(-1.0),
        NSStrokeColorAttributeName      : [NSColor clearColor],
        NSFontAttributeName             : [NSFont systemFontOfSize:13]
    };
    
    NSString *searchPlaceholder     = NSLocalizedString(@"Search", @"Placeholder text in the search field.");
    
    if ([newSearchField respondsToSelector:@selector(setPlaceholderAttributedString:)]) {
        newSearchField.placeholderAttributedString = [[NSAttributedString alloc] initWithString:searchPlaceholder
                                                                                     attributes:colorAttribute];
    }
    
    return newSearchField;
}

- (void)setupBindingsWithSearchField:(NSSearchField *)searchField arrayController:(NSArrayController *)theArrayController
{
    NSDictionary *bindingOptions = @{
        NSPredicateFormatBindingOption : @"content contains[c] $value"
    };
    
    [searchField bind:NSPredicateBinding toObject:theArrayController withKeyPath:@"filterPredicate" options:bindingOptions];
}

- (void)removeBindingsForSearchField:(NSSearchField *)searchField
{
    [searchField unbind:NSPredicateBinding];
}

- (void)hackSearchFieldStyle
{
    NSString *value = self.searchField.stringValue;
    if (value == nil || value.length == 0) {
        self.searchField.stringValue = [NSString string];
        return;
    }

    NSDictionary *attributes = @{
        NSFontAttributeName             : self.searchField.font,
        NSBackgroundColorAttributeName  : self.searchField.backgroundColor,
        NSForegroundColorAttributeName  : self.searchField.textColor
    };

    self.searchField.attributedStringValue = [[NSAttributedString alloc] initWithString:value attributes:attributes];
}

@end
