//
//  NoteListViewController.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/28/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Note.h"

@class BackgroundView;
@class NotesListController;
@class SPTableView;


NS_ASSUME_NONNULL_BEGIN

@interface NoteListViewController : NSViewController <NSTextFieldDelegate, SimperiumDelegate, NSMenuDelegate>

@property (nonatomic, strong, readonly) IBOutlet NSBox                  *backgroundBox;
@property (nonatomic, strong, readonly) IBOutlet NSTextField            *titleLabel;
@property (nonatomic, strong, readonly) IBOutlet NSTextField            *statusField;
@property (nonatomic, strong, readonly) IBOutlet NSProgressIndicator    *progressIndicator;
@property (nonatomic, strong, readonly) IBOutlet NSScrollView           *scrollView;
@property (nonatomic, strong, readonly) IBOutlet NSClipView             *clipView;
@property (nonatomic, strong, readonly) IBOutlet SPTableView            *tableView;
@property (nonatomic, strong, readonly) IBOutlet NSVisualEffectView     *headerEffectView;
@property (nonatomic, strong, readonly) IBOutlet NSButton               *addNoteButton;
@property (nonatomic, strong, readonly) IBOutlet NSMenu                 *noteListMenu;
@property (nonatomic, strong, readonly) IBOutlet NSMenu                 *trashListMenu;

@property (nonatomic, strong, nonnull) NotesListController              *listController;
@property (nonatomic, strong, nullable) NSLayoutConstraint              *titleSemaphoreLeadingConstraint;
@property (nonatomic, assign, readonly) BOOL                            viewingTrash;

- (void)setWaitingForIndex:(BOOL)waiting;
- (void)deleteNote:(Note *)note;
- (IBAction)deleteAction:(id)sender;
- (void)noteKeysWillChange:(NSSet *)keys;
- (void)noteKeyDidChange:(NSString *)key memberNames:(NSArray *)memberNames;

@end

NS_ASSUME_NONNULL_END
