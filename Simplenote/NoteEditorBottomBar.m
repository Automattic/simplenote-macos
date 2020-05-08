//
//  NoteEditorBottomBar.m
//  Simplenote
//
//  Created by Michael Johnston on 7/15/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "NoteEditorBottomBar.h"
#import "SPGradientView.h"
#import "SPTokenField.h"
#import "Simplenote-Swift.h"


@implementation NoteEditorBottomBar
@synthesize tokenField;

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (SPTokenField *)addTagField
{
    if (!self.tokenField) {
        self.tokenField = [[SPTokenField alloc] initWithFrame:NSMakeRect(23, 9, self.frame.size.width-43, 20)];
        [self applyStyle];
        [self addSubview:self.tokenField];
    }

    bottomBorder = [SPGradientView horizontalDividerWithWidth:self.frame.size.width paddingX:20 locationY:self.frame.size.height-2];
    [self addSubview:bottomBorder];
    
    return self.tokenField;
}

- (void)refreshTagField:(BOOL)showPlaceholder
{
    NSString *tagPlaceholder = NSLocalizedString(@"Add a tag...", @"Placeholder text in the text field where you need to tap in order to add a tag");
    NSDictionary *colorAttribute = @{
        NSForegroundColorAttributeName: [NSColor simplenoteSecondaryTextColor]
    };
    NSString *placeholderText = showPlaceholder ? tagPlaceholder : @"";
    [[self.tokenField cell] setPlaceholderAttributedString:[[NSAttributedString alloc] initWithString:placeholderText attributes:colorAttribute]];
    [tagImageView setHidden:!showPlaceholder];
}

- (void)setEnabled:(BOOL)on
{
    enabled = on;
    [self refreshTagField:on];
}

- (BOOL)isEnabled
{
    return enabled;
}

- (void)applyStyle
{
    self.tokenField.textColor = [NSColor simplenoteTextColor];
    self.tokenField.backgroundColor = [NSColor simplenoteBackgroundColor];
    [bottomBorder applyStyle];
    [bottomBorder setNeedsDisplay:YES];
}

@end
