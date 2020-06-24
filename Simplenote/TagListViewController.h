//
//  TagListViewController.h
//  Simplenote
//
//  Created by Michael Johnston on 7/2/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class ClipView;
@class NoteListViewController;

@interface TagListViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, NSTextDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, NSDraggingDestination>

@property (nonatomic, strong, readwrite) IBOutlet NSVisualEffectView    *visualEffectsView;
@property (nonatomic, strong, readwrite) IBOutlet ClipView              *clipView;
@property (nonatomic, strong, readwrite) IBOutlet NSTableView           *tableView;
@property (nonatomic, strong, readwrite) NSArray                        *tagArray;
@property (nonatomic, assign,  readonly) BOOL                           menuShowing;

extern NSString * const kTagUpdated;
extern NSString * const kDidBeginViewingTrash;
extern NSString * const kWillFinishViewingTrash;
extern NSString * const TagListDidBeginViewingTagNotification;
extern NSString * const TagListDidEmptyTrashNotification;

- (void)loadTags;
- (NSString *)selectedTagName;
- (void)selectAllNotesTag;
- (IBAction)deleteAction:(id)sender;
- (IBAction)renameAction:(id)sender;
- (IBAction)emptyTrashAction:(id)sender;
- (void)reset;
- (void)applyStyle;

@end
