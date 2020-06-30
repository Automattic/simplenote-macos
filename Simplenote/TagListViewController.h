//
//  TagListViewController.h
//  Simplenote
//
//  Created by Michael Johnston on 7/2/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class ClipView;
@class Tag;
@class TagListState;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TagListDidBeginViewingTagNotification;
extern NSString * const TagListDidBeginViewingTrashNotification;
extern NSString * const TagListDidUpdateTagNotification;
extern NSString * const TagListDidEmptyTrashNotification;

@interface TagListViewController : NSViewController <NSMenuDelegate, NSTextDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, NSDraggingDestination>

@property (nonatomic, strong, readwrite) IBOutlet NSVisualEffectView    *visualEffectsView;
@property (nonatomic, strong, readwrite) IBOutlet ClipView              *clipView;
@property (nonatomic, strong, readwrite) IBOutlet NSTableView           *tableView;
@property (nonatomic, strong,  readonly) NSMenu                         *tagDropdownMenu;
@property (nonatomic, strong,  readonly) NSMenu                         *trashDropdownMenu;
@property (nonatomic, strong, readwrite) TagListState                   *state;
@property (nonatomic, strong,  readonly) NSArray<Tag *>                 *tagArray;
@property (nonatomic, assign,  readonly) BOOL                           menuShowing;

- (void)loadTags;
- (NSString *)selectedTagName;
- (void)selectAllNotesTag;
- (IBAction)deleteAction:(id)sender;
- (IBAction)renameAction:(id)sender;
- (IBAction)emptyTrashAction:(id)sender;
- (void)reset;
- (void)applyStyle;

@end

NS_ASSUME_NONNULL_END
