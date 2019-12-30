//
//  CustomTagView.h
//  Simplenote
//
//  Created by Rainieri Ventura on 1/30/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <AppKit/AppKit.h>
@class SPButtonNoBackground;

@interface SPTagCellView : NSTableCellView

@property (nonatomic, assign) BOOL mouseInside;

- (void)setSelected:(BOOL)selected;
- (void)applyStyle;

@end
