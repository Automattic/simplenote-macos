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
    IBOutlet NSMenu *findMenu;
    IBOutlet NSMenuItem *tagSortMenuItem;
}

@property (nonatomic, strong) IBOutlet NSBox                *tagBox;
@property (nonatomic, strong) IBOutlet NSTableView          *tableView;
@property (nonatomic, strong) IBOutlet NSArrayController    *notesArrayController;
@property (nonatomic, strong) NSArray                       *tagArray;

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
