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

@property (nonatomic, strong) IBOutlet NSPopUpButton *actionButton;

- (void)applyStyle;

@end
