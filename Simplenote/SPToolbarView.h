//
//  CustomToolbar.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/31/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SPToolbarView : NSView
{
    IBOutlet NSButton *historyButton;
    IBOutlet NSButton *trashButton;
    IBOutlet NSButton *restoreButton;
    IBOutlet NSButton *shareButton;
    IBOutlet NSButton *previewButton;
}

@property (nonatomic, strong) IBOutlet NSPopUpButton    *actionButton;

@end
