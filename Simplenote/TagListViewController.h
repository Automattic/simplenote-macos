//
//  TagListViewController.h
//  Simplenote
//
//  Created by Michael Johnston on 7/2/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SPTableView;
@class NoteListViewController;

@interface TagListViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, NSTextDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, NSDraggingDestination> {
    IBOutlet NoteListViewController *noteListViewController;
    IBOutlet NSBox *tagBox;
    IBOutlet NSMenu *tagMenu;
    IBOutlet NSMenu *tagDropdownMenu;
    IBOutlet NSMenu *trashDropdownMenu;
    IBOutlet NSMenu *findMenu;
    IBOutlet NSArrayController *notesArrayController;
}

@property (strong) IBOutlet SPTableView *tableView;
@property (strong) NSArray *tagArray;

extern NSString * const kTagsDidLoad;
extern NSString * const kTagDeleted;
extern NSString * const kDidBeginViewingTrash;
extern NSString * const kWillFinishViewingTrash;
extern NSString * const kDidEmptyTrash;

- (void)loadTags;
- (NSString *)selectedTagName;
- (void)selectAllNotesTag;
- (IBAction)deleteAction:(id)sender;
- (IBAction)renameAction:(id)sender;
- (IBAction)emptyTrashAction:(id)sender;
- (void)reset;
- (void)applyStyle;

@end
