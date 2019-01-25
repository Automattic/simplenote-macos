//
//  CustomCellView.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/30/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPNoteCellView.h"
#import "Note.h"
#import "NSMutableAttributedString+Styling.h"
#import "SPGradientView.h"
#import "NSString+Condensing.h"
#import "NSString+Styling.h"
#import "NSString+Simplenote.h"
#import "NSImage+Colorize.h"
#import "VSThemeManager.h"
#import "SPTableRowView.h"

#define kHighlightColor [NSColor colorWithCalibratedRed:65.f/255.f green:132.f/255.f blue:191.f/255.f alpha:1.0]
#define kHeadlineColor [NSColor colorWithCalibratedRed:21.f/255.f green:21.f/255.f blue:21.f/255.f alpha:1.0]
#define kPreviewColor [NSColor colorWithCalibratedRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:1.0]

static NSImage *pinImage;
static NSImage *pinImageHighlighted;

@implementation SPNoteCellView
@synthesize note;
@synthesize contentPreview;

- (VSTheme *)theme
{
    return [[VSThemeManager sharedManager] theme];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    // This will cause every displayed note to have its preview set manually, which is inefficient
    // because it's also being done via a binding. But ensures all fonts and colors are set appropriately.
    if (self.superview && [self.superview isKindOfClass:[NSTableRowView class]]) {
        NSTableRowView *row = (NSTableRowView*)self.superview;
        highlighted = row.isSelected;
    }

    [self updatePreview];
}

- (void)updatePreview
{
    NSColor *headlineColor = highlighted ? [self.theme colorForKey:@"tintColor"] : [self.theme colorForKey:@"noteHeadlineFontColor"];
    NSColor *previewColor = highlighted ? [self.theme colorForKey:@"tintColor"] : [self.theme colorForKey:@"noteBodyFontPreviewColor"];
    NSString *preview = [note.content length] == 0 ? @"New note..." : [note.content stringByGeneratingPreview];
    
    NSAttributedString *noteSummary = [preview headlinedAttributedStringWithHeadlineFont:[self noteTitleFont] headlineColor:headlineColor bodyFont:[self notePreviewFont] bodyColor:previewColor];

    if (note.pinned) {
        // Add a pin image
        noteSummary = [self pinnedPreviewForNoteSummary:noteSummary];
    }

    [contentPreview setAttributedStringValue:noteSummary];
}

- (NSMutableAttributedString *)pinnedPreviewForNoteSummary:(NSAttributedString *)noteSummary
{
    // Update image if theme has changed
    if (!pinImage || ([self.theme boolForKey:@"dark"] && ![pinImage.name sp_containsString:@"dark"]) ||
        (![self.theme boolForKey:@"dark"] && [pinImage.name sp_containsString:@"dark"])) {
        NSString *imageName = [self.theme boolForKey:@"dark"] ? @"icon_pin_dark" : @"icon_pin";
        pinImage = [NSImage imageNamed:imageName];
        pinImageHighlighted = [NSImage imageNamed:@"icon_pin_highlighted"];
    }
    
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:highlighted ? pinImageHighlighted : pinImage];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell:attachmentCell];
    
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    [titleStyle setLineSpacing:0.0];
    [titleStyle setParagraphSpacing:8];
    [titleStyle setMinimumLineHeight:0];
    [titleStyle setMaximumLineHeight:20];
    
    NSMutableAttributedString *attachmentString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [attachmentString addAttribute:NSParagraphStyleAttributeName value:titleStyle range:NSMakeRange(0, attachmentString.length)];
    NSMutableAttributedString *spaceString = [[NSMutableAttributedString alloc] initWithString:@"  "];
    
    NSMutableAttributedString *combinedString = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    [combinedString appendAttributedString:spaceString];
    [combinedString appendAttributedString:noteSummary];
    
    return combinedString;
}


#pragma mark - Fonts

- (NSFont *)noteTitleSelectedFont
{
    return [NSFont systemFontOfSize:15.0];
}

- (NSFont *)noteTitleFont
{
    return [NSFont systemFontOfSize:15.0];
}

- (NSFont *)notePreviewFont
{
    return [NSFont systemFontOfSize:13.0];
}

@end
