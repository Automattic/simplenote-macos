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
#import "VSThemeManager.h"
#import "Simplenote-Swift.h"


static NSImage *pinImage;

@implementation SPNoteCellView

- (VSTheme *)theme
{
    return [[VSThemeManager sharedManager] theme];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [self updatePreview];
}

- (void)updatePreview
{
    NSColor *headlineColor = [self.theme colorForKey:@"noteHeadlineFontColor"];
    NSColor *previewColor = [self.theme colorForKey:@"noteBodyFontPreviewColor"];
    NSString *preview = [_note.content length] == 0
                            ? NSLocalizedString(@"New note...", @"Empty Note Preview Text")
                            : [_note.content stringByGeneratingPreview];
    
    NSAttributedString *noteSummary = [preview headlinedAttributedStringWithHeadlineFont:[self noteTitleFont] headlineColor:headlineColor bodyFont:[self notePreviewFont] bodyColor:previewColor];

    if (_note.pinned) {
        // Add a pin image
        noteSummary = [self pinnedPreviewForNoteSummary:noteSummary];
    }

    _contentPreview.attributedStringValue = noteSummary;
    _accessoryImageView.image = [_accessoryImageView.image tintedWithColor:previewColor];
}

- (NSMutableAttributedString *)pinnedPreviewForNoteSummary:(NSAttributedString *)noteSummary
{
    if (!pinImage) {
        NSString *imageName = SPUserInterface.isDark ? @"icon_pin_dark" : @"icon_pin";
        pinImage = [NSImage imageNamed:imageName];
    }
    
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:pinImage];
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
