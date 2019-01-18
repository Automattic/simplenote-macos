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
#import "NSImage+Colorize.h"
#import "VSThemeManager.h"
#import "Simplenote-Swift.h"

#define kMaxEditorWidth 750 // Note: This matches the Electron apps max editor width
NSString *const MarkdownUnchecked = @"- [ ]";
NSString *const MarkdownChecked = @"- [x]";
NSString *const TextAttachmentCharacterCode = @"\U0000fffc"; // Represents the glyph of an NSTextAttachment

// One unicode character plus a space
NSInteger const ChecklistCursorAdjustment = 2;

@implementation SPTextView

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
    
    NSColor *checklistColor = [theme colorForKey:@"secondaryTextColor"];
    if (@available(macOS 10.14, *)) {
        if (![[VSThemeManager sharedManager] isDarkMode]) {
            // Workaround for wrong checklist color in overridden light theme on mojave
            checklistColor = [NSColor secondaryLabelColor];
        }
    }
    [[NSUserDefaults standardUserDefaults] objectForKey:VSThemeManagerThemePrefKey];
    
    [self.textStorage addChecklistAttachmentsForHeight:self.font.pointSize andColor:checklistColor andVerticalOffset:-4.0f];
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
    NSRange lineRange = [self.string lineRangeForRange:self.selectedRange];
    NSUInteger cursorPosition = self.selectedRange.location;
    NSUInteger selectionLength = self.selectedRange.length;
    
    // Check if cursor is at a checkbox, if so we won't adjust cursor position
    BOOL cursorIsAtCheckbox = NO;
    if (self.string.length >= self.selectedRange.location + 1) {
        NSString *characterAtCursor = [self.string substringWithRange:NSMakeRange(self.selectedRange.location, 1)];
        cursorIsAtCheckbox = [characterAtCursor isEqualToString:TextAttachmentCharacterCode];
    }
    
    NSString *lineString = [self.string substringWithRange:lineRange];
    BOOL didInsertCheckbox = NO;
    NSString *resultString = @"";
    
    int addedCheckboxCount = 0;
    if ([lineString containsString:TextAttachmentCharacterCode] && [lineString length] >= ChecklistCursorAdjustment) {
        // Remove the checkboxes in the selection
        NSString *codeAndSpace = [TextAttachmentCharacterCode stringByAppendingString:@" "];
        resultString = [lineString stringByReplacingOccurrencesOfString:codeAndSpace withString:@""];
    } else {
        // Add checkboxes to the selection
        NSString *checkboxString = [MarkdownUnchecked stringByAppendingString:@" "];
        NSArray *stringLines = [lineString componentsSeparatedByString:@"\n"];
        for (int i=0; i < [stringLines count]; i++) {
            NSString *line = stringLines[i];
            // Skip the last line if it is empty
            if (i != 0 && i == [stringLines count] - 1 && [line length] == 0) {
                continue;
            }
            
            NSString *prefixedWhitespace = [self getLeadingWhiteSpaceForString:line];
            resultString = [[resultString
                             stringByAppendingString:prefixedWhitespace]
                             stringByAppendingString:[checkboxString
                             stringByAppendingString:line]];
            // Skip adding newline to the last line
            if (i != [stringLines count] - 1) {
                resultString = [resultString stringByAppendingString:@"\n"];
            }
            addedCheckboxCount++;
        }
        
        didInsertCheckbox = YES;
    }
    
    NSTextStorage *storage = self.textStorage;
    [storage beginEditing];
    [storage replaceCharactersInRange:lineRange withString:resultString];
    [storage endEditing];
    
    [self processChecklists];
    NSNotification *note = [NSNotification notificationWithName:NSTextDidChangeNotification object:nil];
    [self.delegate textDidChange:note];
    
    // Update the cursor position
    NSUInteger cursorAdjustment = 0;
    if (!cursorIsAtCheckbox) {
        if (selectionLength > 0 && didInsertCheckbox) {
            // Places cursor at end of insertion when text was selected
            cursorAdjustment = selectionLength + (ChecklistCursorAdjustment * addedCheckboxCount);
        } else {
            cursorAdjustment = didInsertCheckbox ? ChecklistCursorAdjustment : -ChecklistCursorAdjustment;
        }
    }
    [self setSelectedRange:NSMakeRange(cursorPosition + cursorAdjustment, 0)];
}

// Returns a NSString of any whitespace characters found at the start of a string
- (NSString *)getLeadingWhiteSpaceForString: (NSString *)string
{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^\\s*" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return [string substringWithRange:match.range];
}

@end
