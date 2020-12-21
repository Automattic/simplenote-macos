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
#import "SPTableView.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"

@import Simperium_OSX;


@interface NoteListViewController () <NSTableViewDelegate>
@property (nonatomic, strong) IBOutlet NSBox                *backgroundBox;
@property (nonatomic, strong) IBOutlet NSTextField          *titleLabel;
@property (nonatomic, strong) IBOutlet NSTextField          *statusField;
@property (nonatomic, strong) IBOutlet NSProgressIndicator  *progressIndicator;
@property (nonatomic, strong) IBOutlet NSScrollView         *scrollView;
@property (nonatomic, strong) IBOutlet NSClipView           *clipView;
@property (nonatomic, strong) IBOutlet SPTableView          *tableView;
@property (nonatomic, strong) IBOutlet NSVisualEffectView   *headerEffectView;
@property (nonatomic, strong) IBOutlet NSButton             *addNoteButton;
@property (nonatomic, strong) IBOutlet NSMenu               *noteListMenu;
@property (nonatomic, strong) IBOutlet NSMenu               *trashListMenu;
@property (nonatomic, strong) NSString                      *oldTags;
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

    [self setupResultsController];
    [self setupTableView];
    [self setupProgressIndicator];
    [self startListeningToScrollNotifications];
    [self startListeningToWindowNotifications];

    [self applyStyle];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    [self refreshScrollInsets];
    [self refreshHeaderState];
}

// TODO: Work in Progress. Decouple with a delegate please
//
- (NoteEditorViewController *)noteEditorViewController
{
    return [[SimplenoteAppDelegate sharedDelegate] noteEditorViewController];
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

- (void)notesArrayDidChange:(NSNotification *)notification
{
    NSUInteger numNotes = self.listController.numberOfNotes;
    
    // As soon as at least one note is added, select it
    if (numNotes > 0 && self.noteEditorViewController.note == nil) {
        [self selectFirstRow];
    }

    if (numNotes == 0) {
        [self.noteEditorViewController displayNote:nil];
    } else if (self.isSearching) {
        [self selectFirstRow];
    }
}

- (void)notesArraySelectionDidChange:(NSNotification *)notification
{
    // Check for empty list and clear editor contents if necessary
    if (self.listController.numberOfNotes == 0) {
        [self.noteEditorViewController displayNote:nil];
    }
    
    NSInteger selectedRow = [self.tableView selectedRow];
    
    if (selectedRow < 0) {
        return;
    }

    if ([self.tableView numberOfSelectedRows] == 1) {
        Note *note = [self.listController noteAtIndex:selectedRow];
        if (![note.simperiumKey isEqualToString: self.noteEditorViewController.note.simperiumKey]) {
            [SPTracker trackListNoteOpened];
            [self.noteEditorViewController displayNote:note];
        }
    } else {
        [self.noteEditorViewController displayNotes:self.selectedNotes];
    }
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
    if (self.listController.numberOfNotes != 0) {
        return;
    }

    [self.noteEditorViewController displayNote:nil];
}

- (void)selectedTaglistRowWasUpdated
{
    [self refreshEnabledActions];
    [self refreshListController];
    [self refreshTitle];
    [self selectFirstRow];
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
    for (Note *selectedNote in self.selectedNotes) {
        [self deleteNote:selectedNote];
    }
}

- (IBAction)newNoteWasPressed:(id)sender
{
    // TODO: Move the New Note Handler to a (New) NoteController!
    [self.noteEditorViewController newNoteWasPressed:sender];
}

@end
