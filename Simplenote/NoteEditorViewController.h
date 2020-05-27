//
//  NoteEditorViewController.h
//  Simplenote
//
//  Created by Rainieri Ventura on 2/2/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Note.h"
#import "SPTextView.h"
@import Simperium_OSX;

@class BackgroundView;
@class NoteListViewController;
@class NoteEditorBottomBar;
@class MarkdownViewController;
@class ToolbarView;

typedef NS_ENUM(NSInteger, NoteFontSize) {
    NoteFontSizeMinimum = 10,
    NoteFontSizeNormal = 15,
    NoteFontSizeMaximum = 30
};


#pragma mark ====================================================================================
#pragma mark Notifications
#pragma mark ====================================================================================

extern NSString * const SPTagAddedFromEditorNotificationName;
extern NSString * const SPWillAddNewNoteNotificationName;


#pragma mark ====================================================================================
#pragma mark NoteEditorViewController
#pragma mark ====================================================================================

@interface NoteEditorViewController : NSViewController <NSSharingServicePickerDelegate>
{
    IBOutlet NSTableView *tableView;
    IBOutlet NSArrayController *notesArrayController;
    IBOutlet NSTokenField *tagTokenField;
    IBOutlet NSMenu *lineLengthMenu;
    IBOutlet NSMenuItem *wordCountItem;
    IBOutlet NSMenuItem *characterCountItem;
    IBOutlet NSMenuItem *modifiedItem;
    IBOutlet NSMenuItem *pinnedItem;
    IBOutlet NSMenuItem *markdownItem;
    IBOutlet NSMenuItem *newItem;
    IBOutlet NSMenuItem *deleteItem;
    IBOutlet NSMenuItem *printItem;
    IBOutlet NSMenuItem *collaborateItem;
}

@property (nonatomic, strong) IBOutlet NSMenu                   *detailsMenu;
@property (nonatomic, strong) IBOutlet BackgroundView           *backgroundView;
@property (nonatomic, strong) IBOutlet BackgroundView           *topDividerView;
@property (nonatomic, strong) IBOutlet ToolbarView              *toolbarView;
@property (nonatomic, strong) IBOutlet NSImageView              *statusImageView;
@property (nonatomic, strong) IBOutlet NSTextField              *statusTextField;
@property (nonatomic,   weak) IBOutlet SPTextView               *noteEditor;
@property (nonatomic,   weak) IBOutlet NSScrollView             *scrollView;
@property (nonatomic,   weak) IBOutlet NoteEditorBottomBar      *bottomBar;
@property (nonatomic, strong, readonly) MarkdownViewController  *markdownViewController;
@property (nonatomic, strong, readonly) NSArray<Note *>         *selectedNotes;
@property (nonatomic, assign, readonly) BOOL                    viewingTrash;
@property (nonatomic,   weak) Note                              *note;

- (void)save;
- (void)displayNote:(Note *)selectedNote;
- (void)displayNotes:(NSArray *)selectedNotes;
- (void)didReceiveNewContent;
- (void)updateTagField;
- (void)willReceiveNewContent;
- (void)didReceiveVersion:(NSString *)version data:(NSDictionary *)data;
- (void)applyStyle;
- (void)showPublishPopover;
- (void)fixChecklistColoring;
- (NSUInteger)wordCount;
- (NSUInteger)charCount;
- (NSUInteger)newCursorLocation:(NSString *)newText oldText:(NSString *)oldText currentLocation:(NSUInteger)cursorLocation;
- (IBAction)deleteAction:(id)sender;
- (IBAction)adjustFontSizeAction:(id)sender;
- (IBAction)markdownAction:(id)sender;
- (IBAction)showSharePopover:(id)sender;
- (IBAction)showVersionPopover:(id)sender;
- (IBAction)toggleMarkdownView:(id)sender;
- (IBAction)toggleEditorWidth:(id)sender;
- (IBAction)insertChecklistAction:(id)sender;

@end
