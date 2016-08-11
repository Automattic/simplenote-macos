//
//  NoteEditorBottomBar.h
//  Simplenote
//
//  Created by Michael Johnston on 7/15/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPGradientView.h"

@class SPTokenField;

@interface NoteEditorBottomBar : NSView {
    BOOL enabled;
    NSMutableAttributedString *tagFieldPlaceholder;
    NSImageView *tagImageView;
    SPGradientView *bottomBorder;
}

@property (strong) SPTokenField *tokenField;

- (SPTokenField *)addTagField;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
- (void)applyStyle;

@end
