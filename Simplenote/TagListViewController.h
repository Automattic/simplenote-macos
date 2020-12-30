//
//  TagListViewController.h
//  Simplenote
//
//  Created by Michael Johnston on 7/2/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NoteEditorViewController.h"


@class Tag;
@class TagListState;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TagListDidBeginViewingTagNotification;
extern NSString * const TagListDidBeginViewingTrashNotification;
extern NSString * const TagListDidUpdateTagNotification;
extern NSString * const TagListDidEmptyTrashNotification;

@interface TagListViewController : NSViewController <NSMenuDelegate,
                                                     NSTextDelegate,
                                                     NSTextFieldDelegate,
                                                     NSControlTextEditingDelegate,
                                                     NSDraggingDestination,
                                                     EditorControllerTagActionsDelegate>

@property (nonatomic, strong, readwrite) IBOutlet NSVisualEffectView    *backgroundVisualEffectsView;
@property (nonatomic, strong, readwrite) IBOutlet NSVisualEffectView    *headerVisualEffectsView;
@property (nonatomic, strong, readwrite) IBOutlet BackgroundView        *headerSeparatorView;
@property (nonatomic, strong, readwrite) IBOutlet NSScrollView          *scrollView;
@property (nonatomic, strong, readwrite) IBOutlet NSClipView            *clipView;
@property (nonatomic, strong, readwrite) IBOutlet NSTableView           *tableView;
@property (nonatomic, strong,  readonly) NSMenu                         *tagDropdownMenu;
@property (nonatomic, strong,  readonly) NSMenu                         *trashDropdownMenu;
@property (nonatomic, strong, readwrite) TagListState                   *state;
@property (nonatomic, strong,  readonly) NSArray<Tag *>                 *tagArray;
@property (nonatomic, assign,  readonly) BOOL                           menuShowing;
@property (nonatomic, assign, readwrite) BOOL                           mustSkipSelectionDidChange;
@property (nonatomic, strong,  readonly) Simperium                      *simperium;

- (void)loadTags;
- (NSString *)selectedTagName;
- (void)selectAllNotesTag;
- (IBAction)deleteAction:(id)sender;
- (IBAction)renameAction:(id)sender;
- (void)reset;
- (void)applyStyle;

@end

NS_ASSUME_NONNULL_END
