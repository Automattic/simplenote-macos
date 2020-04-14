//
//  CustomToolbar.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/31/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NoteListViewController.h"

@interface SPToolbarView : NSView
{
    IBOutlet NSButton *addButton;
    IBOutlet NSButton *historyButton;
    IBOutlet NSButton *trashButton;
    IBOutlet NSButton *restoreButton;
    IBOutlet NSButton *shareButton;
    IBOutlet NSButton *previewButton;
    IBOutlet NSTextView *noteEditor;
    IBOutlet NSBox *searchBox;
    IBOutlet NSSearchField *searchField;
}

@property (nonatomic, strong) IBOutlet NSPopUpButton    *actionButton;
@property (nonatomic, assign) BOOL                      drawsSeparator;
@property (nonatomic, assign) BOOL                      drawsBackground;

- (void)setSplitPositionLeft:(CGFloat)left right:(CGFloat)right;
- (void)applyStyle;
- (void)configureForFocusMode:(BOOL)enabled;

@end
