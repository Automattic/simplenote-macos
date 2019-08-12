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

@property (nonatomic, strong) IBOutlet NSTextField *contentPreview;
@property (nonatomic, strong) IBOutlet NSImageView *accessoryImageView;
@property (nonatomic, strong) Note *note;

- (void)updatePreview;

@end
