//
//  SPTableView.m
//  Simplenote
//
//  Created by Michael Johnston on 7/26/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPTableView.h"

@implementation SPTableView

- (void)awakeFromNib
{
    validFirstResponders = [NSMutableArray arrayWithCapacity:3];
}

- (void)addValidFirstResponder:(NSResponder *)responder
{
    [validFirstResponders addObject:responder];
}

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event
{
    // By default you can't click through to first responders in a table view; allow
    // this behavior to be overridden
    if ([validFirstResponders containsObject:responder]) {
        return YES;
    }
    
    return [super validateProposedFirstResponder:responder forEvent:event];
}

- (void)keyDown:(NSEvent *)theEvent
{
    // Intercept the delete key and make it delete the currently selected note
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (key == NSDeleteCharacter) {
        if ([self.delegate respondsToSelector:@selector(deleteAction:)]) {
            [self.delegate performSelector:@selector(deleteAction:) withObject:self];
            return;
        }
    }
    
    [super keyDown:theEvent];
}

- (void)didClickTextView:(id)sender
{
    // User clicked a text view. Select its underlying row.
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:[self rowForView:sender]] byExtendingSelection:NO];
}

- (NSMenu *)menuForEvent:(NSEvent*)theEvent
{
    NSMenu *menu = [super menuForEvent:theEvent];
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:mousePoint];
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    return menu;
}

@end
