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
@class MarkdownViewController;
@class TagsField;
@class ToolbarView;


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NoteFontSize) {
    NoteFontSizeMinimum = 10,
    NoteFontSizeNormal = 14,
    NoteFontSizeMaximum = 30
};



#pragma mark - Notifications

extern NSString * const SPTagAddedFromEditorNotificationName;
extern NSString * const SPWillAddNewNoteNotificationName;


#pragma mark - NoteEditorViewController

@interface NoteEditorViewController : NSViewController
{
    IBOutlet NSTableView *tableView;
    IBOutlet NSArrayController *notesArrayController;
    IBOutlet NSMenu *lineLengthMenu;
}

@property (nonatomic, strong) IBOutlet NSMenu                                   *moreActionsMenu;
@property (nonatomic, strong) IBOutlet BackgroundView                           *backgroundView;
@property (nonatomic, strong) IBOutlet BackgroundView                           *topDividerView;
@property (nonatomic, strong) IBOutlet BackgroundView                           *bottomDividerView;
@property (nonatomic, strong) IBOutlet ToolbarView                              *toolbarView;
@property (nonatomic, strong) IBOutlet NSImageView                              *statusImageView;
@property (nonatomic, strong) IBOutlet NSTextField                              *statusTextField;
@property (nonatomic, strong) IBOutlet SPTextView                               *noteEditor;
@property (nonatomic, strong) IBOutlet NSScrollView                             *scrollView;
@property (nonatomic, strong) IBOutlet TagsField                                *tagsField;

@property (nonatomic, strong, readonly) MarkdownViewController                  *markdownViewController;
@property (nonatomic, strong, readonly) NSArray<Note *>                         *selectedNotes;
@property (nonatomic, assign, readonly) BOOL                                    viewingTrash;
@property (nonatomic, strong, nullable) NSLayoutConstraint                      *toolbarViewTopConstraint;
@property (nonatomic,   weak) Note                                              *note;

- (void)save;
- (void)displayNote:(nullable Note *)selectedNote;
- (void)displayNotes:(NSArray<Note *> *)selectedNotes;
- (void)didReceiveNewContent;
- (void)willReceiveNewContent;
- (void)applyStyle;
- (void)fixChecklistColoring;
- (void)updateTagsWithTokens:(NSArray<NSString *> *)tokens;
- (NSUInteger)newCursorLocation:(NSString *)newText oldText:(NSString *)oldText currentLocation:(NSUInteger)cursorLocation;
- (IBAction)deleteAction:(id)sender;
- (IBAction)adjustFontSizeAction:(id)sender;
- (IBAction)markdownAction:(id)sender;
- (IBAction)toggleMarkdownView:(id)sender;
- (IBAction)toggleEditorWidth:(id)sender;
- (IBAction)insertChecklistAction:(id)sender;

@end

NS_ASSUME_NONNULL_END

