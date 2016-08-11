//
//  CustomCellView.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/30/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <AppKit/AppKit.h>

@class Note;

@interface SPNoteCellView : NSTableCellView
{
    IBOutlet NSTextField *dateField;
    IBOutlet NSTextField *contentPreview;
    IBOutlet NSTextField *titleField;
    IBOutlet NSView *pinView;
    BOOL highlighted;
}

@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) NSTextField *contentPreview;

- (void)updatePreview;

@end
