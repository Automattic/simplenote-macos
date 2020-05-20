//
//  TagListViewController.h
//  Simplenote
//
//  Created by Michael Johnston on 7/2/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class NoteListViewController;

@interface TagListViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, NSTextDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, NSDraggingDestination> {
    IBOutlet NSMenu *tagDropdownMenu;
    IBOutlet NSMenu *trashDropdownMenu;
}

@property (nonatomic, strong, readwrite) IBOutlet NSVisualEffectView    *visualEffectsView;
@property (nonatomic, strong, readwrite) IBOutlet NSTableView           *tableView;
@property (nonatomic, strong, readwrite) IBOutlet NSArrayController     *notesArrayController;
@property (nonatomic, strong, readwrite) NSArray                        *tagArray;
@property (nonatomic, assign,  readonly) BOOL                           menuShowing;

extern NSString * const kTagsDidLoad;
extern NSString * const kTagUpdated;
extern NSString * const kDidBeginViewingTrash;
extern NSString * const kWillFinishViewingTrash;
extern NSString * const kDidEmptyTrash;

- (void)loadTags;
- (NSString *)selectedTagName;
- (void)selectAllNotesTag;
- (IBAction)deleteAction:(id)sender;
- (IBAction)renameAction:(id)sender;
- (IBAction)emptyTrashAction:(id)sender;
- (IBAction)sortAction:(id)sender;
- (void)reset;
- (void)applyStyle;

@end
