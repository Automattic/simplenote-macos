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
@class InterlinkWindowController;
@class NoteEditorViewController;
@class NoteListViewController;
@class MarkdownViewController;
@class Storage;
@class TagsField;
@class ToolbarView;


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NoteFontSize) {
    NoteFontSizeMinimum = 10,
    NoteFontSizeNormal = 14,
    NoteFontSizeMaximum = 30
};



#pragma mark - NoteEditorControllerDelegate

@protocol EditorControllerNoteActionsDelegate <NSObject>
- (void)editorController:(NoteEditorViewController *)controller addedNoteWithSimperiumKey:(NSString *)simperiumKey;
- (void)editorController:(NoteEditorViewController *)controller pinnedNoteWithSimperiumKey:(NSString *)simperiumKey;
- (void)editorController:(NoteEditorViewController *)controller restoredNoteWithSimperiumKey:(NSString *)simperiumKey;
- (void)editorController:(NoteEditorViewController *)controller updatedNoteWithSimperiumKey:(NSString *)simperiumKey;
- (void)editorController:(NoteEditorViewController *)controller deletedNoteWithSimperiumKey:(NSString *)simperiumKey;
@end

@protocol EditorControllerTagActionsDelegate <NSObject>
- (void)editorController:(NoteEditorViewController *)controller didAddNewTag:(NSString *)tag;
@end

@protocol EditorControllerSearchDelegate <NSObject>
- (void)editorControllerDidBeginSearch:(NoteEditorViewController *)controller;
- (void)editorControllerDidEndSearch:(NoteEditorViewController *)controller;
- (void)editorController:(NoteEditorViewController *)controller didSearchKeyword:(NSString *)keyword;
@end



#pragma mark - NoteEditorViewController

@interface NoteEditorViewController : NSViewController

@property (nonatomic, strong) IBOutlet NSMenu                                   *moreActionsMenu;
@property (nonatomic, strong) IBOutlet BackgroundView                           *backgroundView;
@property (nonatomic, strong) IBOutlet NSVisualEffectView                       *headerEffectView;
@property (nonatomic, strong) IBOutlet BackgroundView                           *bottomDividerView;
@property (nonatomic, strong) IBOutlet ToolbarView                              *toolbarView;
@property (nonatomic, strong) IBOutlet NSSearchField                            *searchField;
@property (nonatomic, strong) IBOutlet NSImageView                              *statusImageView;
@property (nonatomic, strong) IBOutlet NSTextField                              *statusTextField;
@property (nonatomic, strong) IBOutlet SPTextView                               *noteEditor;
@property (nonatomic, strong) IBOutlet NSScrollView                             *scrollView;
@property (nonatomic, strong) IBOutlet NSClipView                               *clipView;
@property (nonatomic, strong) IBOutlet TagsField                                *tagsField;

@property (nonatomic, strong, readonly) MarkdownViewController                  *markdownViewController;
@property (nonatomic, strong, readonly) Storage                                 *storage;
@property (nonatomic, strong, readonly) NSArray<Note *>                         *selectedNotes;
@property (nonatomic, assign, readonly) BOOL                                    viewingTrash;
@property (nonatomic, strong, nullable) NSLayoutConstraint                      *sidebarSemaphoreLeadingConstraint;
@property (nonatomic, strong, nullable) InterlinkWindowController               *interlinkWindowController;
@property (nonatomic,   weak) Note                                              *note;
@property (nonatomic,   weak) id<EditorControllerNoteActionsDelegate>           noteActionsDelegate;
@property (nonatomic,   weak) id<EditorControllerTagActionsDelegate>            tagActionsDelegate;
@property (nonatomic,   weak) id<EditorControllerSearchDelegate>                searchDelegate;

- (IBAction)newNoteWasPressed:(id)sender;
- (void)save;
- (void)displayNote:(nullable Note *)selectedNote;
- (void)displayNotes:(NSArray<Note *> *)selectedNotes;
- (void)didReceiveNewContent;
- (void)willReceiveNewContent;
- (void)fixChecklistColoring;
- (void)updateTagsWithTokens:(NSArray<NSString *> *)tokens;
- (NSUInteger)newCursorLocation:(NSString *)newText oldText:(NSString *)oldText currentLocation:(NSUInteger)cursorLocation;
- (IBAction)deleteAction:(id)sender;
- (IBAction)printAction:(id)sender;
- (IBAction)adjustFontSizeAction:(id)sender;
- (IBAction)markdownAction:(id)sender;
- (IBAction)toggleMarkdownView:(id)sender;
- (IBAction)insertChecklistAction:(id)sender;

@end

NS_ASSUME_NONNULL_END

