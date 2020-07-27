//
//  SPTableView.m
//  Simplenote
//
//  Created by Michael Johnston on 7/26/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPTableView.h"

@implementation SPTableView

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
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:mousePoint];
    NSInteger column = [self columnAtPoint:mousePoint];
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

    if ([self.delegate respondsToSelector:@selector(tableView:menuForTableColumn:row:)] == false) {
        return [super menuForEvent:theEvent];
    }

    return [(id<SPTableViewDelegate>)self.delegate tableView:self menuForTableColumn:column row:row];
}

@end
