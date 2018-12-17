//
//  SPTextView.m
//  Simplenote
//
//  Created by Michael Johnston on 8/7/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPTextView.h"
#import "NSImage+Colorize.h"
#import "NSMutableAttributedString+Styling.h"
#import "VSThemeManager.h"
#import "Simplenote-Swift.h"

#define kMaxEditorWidth 750 // Note: This matches the Electron apps max editor width
NSString *const CheckListRegExPattern = @"^- (\\[([ |x])\\])";
NSString *const MarkdownUnchecked = @"- [ ]";
NSString *const MarkdownChecked = @"- [x]";

// One unicode character plus a space and a newline
NSInteger const ChecklistCursorAdjustment = 3;

@implementation SPTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    /*SPClickGestureRecognizer *clickGestureRecognizer = [[SPClickGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(onTextTapped:)];
    [self addGestureRecognizer:clickGestureRecognizer];*/
}

// Workaround NSTextView not allowing clicks
// http://stackoverflow.com/a/10308359/1379066
- (void)mouseDown:(NSEvent *)theEvent
{
    // Notify delegate that this text view was clicked and then
    // handled the click natively as well.
    [[self textViewDelegate] didClickTextView:self];
    
    if ([self checkForChecklistClick:theEvent]) {
        return;
    }
    
    [super mouseDown:theEvent];
}

- (id<SPTextViewDelegate>)textViewDelegate
{
    return [self.delegate conformsToProtocol:@protocol(SPTextViewDelegate)] ? (id<SPTextViewDelegate>)self.delegate : nil;
}

- (void)drawRect:(NSRect)dirtyRect {
    CGFloat viewWidth = self.frame.size.width;
    CGFloat insetX = [self shouldCalculateInset:viewWidth] ? [self getAdjustedInsetX:viewWidth] : kMinEditorPadding;
    [self setTextContainerInset: NSMakeSize(insetX, kMinEditorPadding)];
    
    [super drawRect:dirtyRect];
}

- (BOOL)shouldCalculateInset: (CGFloat)viewWidth {
    return viewWidth > kMaxEditorWidth && ![[NSUserDefaults standardUserDefaults] boolForKey:kEditorWidthPreferencesKey];
}

- (CGFloat)getAdjustedInsetX: (CGFloat)viewWidth {
    CGFloat adjustedInset = (viewWidth - kMaxEditorWidth) / 2;
    
    return lroundf(adjustedInset) + kMinEditorPadding;
}

- (void)processChecklists {
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    if (self.attributedString.length == 0) {
        return;
    }
    
    [self.textStorage addChecklistAttachmentsForHeight:self.font.pointSize andColor:[theme colorForKey:@"textColor"] andVerticalOffset:-4.0f];
}

// Processes content of note editor, and replaces special string attachments with their plain
// text counterparts. Currently supports markdown checklists.
- (NSString *)getPlainTextContent {
    NSMutableAttributedString *adjustedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedString];
    // Replace checkbox images with their markdown syntax equivalent
    [adjustedString enumerateAttribute:NSAttachmentAttributeName inRange:[adjustedString.string rangeOfString:adjustedString.string] options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[SPTextAttachment class]]) {
            SPTextAttachment *attachment = (SPTextAttachment *)value;
            NSString *checkboxMarkdown = attachment.isChecked ? MarkdownChecked : MarkdownUnchecked;
            [adjustedString replaceCharactersInRange:range withString:checkboxMarkdown];
        }
    }];
    
    return adjustedString.string;
}

- (BOOL)checkForChecklistClick:(NSEvent *)event
{
    // Location of the tap in text-container coordinates
    NSLayoutManager *layoutManager = self.layoutManager;
    CGPoint location = [event locationInWindow];
    NSPoint viewPoint = [self convertPoint:location fromView:nil];
    viewPoint.x -= self.textContainerInset.width;
    viewPoint.y -= self.textContainerInset.height;
    
    // Find the character that's been tapped on
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:viewPoint
                                           inTextContainer:self.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < self.textStorage.length) {
        NSRange range;
        if ([self.attributedString attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&range]) {
            id value = [self.attributedString attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&range];
            // A checkbox was tapped!
            SPTextAttachment *attachment = (SPTextAttachment *)value;
            BOOL wasChecked = attachment.isChecked;
            [attachment setIsChecked:!wasChecked];
     
            NSNotification *note = [NSNotification notificationWithName:NSTextDidChangeNotification object:nil];
            [self.delegate textDidChange:note];
            [self setNeedsLayout:YES];
            [self.layoutManager invalidateDisplayForCharacterRange:range];
            
            return YES;
        }
    }
    
    return NO;
}

- (void)insertNewChecklist {
    NSString *checkboxText = [MarkdownUnchecked stringByAppendingString:@" "];
    if (self.selectedRange.location > 0) {
        checkboxText = [@"\n" stringByAppendingString:checkboxText];
    }
    
    NSTextStorage *storage = self.textStorage;
    [storage beginEditing];
    [storage replaceCharactersInRange:self.selectedRange withString:checkboxText];
    [storage endEditing];
    
    // Update the cursor position
    [self setSelectedRange:NSMakeRange(self.selectedRange.location + ChecklistCursorAdjustment, self.selectedRange.length)];
    
    [self processChecklists];
    NSNotification *note = [NSNotification notificationWithName:NSTextDidChangeNotification object:nil];
    [self.delegate textDidChange:note];
}

@end
